import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexo/packages/nexo_errors/failure_codes.dart';
import 'package:nexo/packages/nexo_errors/localization/failure_user_messages_ru.dart';
import 'package:nexo/packages/nexo_errors/types/file_failure.dart';
import 'package:nexo/packages/nexo_errors/types/auth_failure.dart';
import 'package:nexo/packages/nexo_errors/types/cache_failure.dart';
import 'package:nexo/packages/nexo_errors/types/database_failure.dart';
import 'package:nexo/packages/nexo_errors/types/http_failure.dart';
import 'package:nexo/packages/nexo_errors/types/location_failure.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';
import 'package:nexo/packages/nexo_errors/types/notification_failure.dart';
import 'package:nexo/packages/nexo_errors/types/parse_failure.dart';
import 'package:nexo/packages/nexo_errors/types/payment_failure.dart';
import 'package:nexo/packages/nexo_errors/types/permission_failure.dart';
import 'package:nexo/packages/nexo_errors/types/platform_failure.dart';
import 'package:nexo/packages/nexo_errors/types/storage_failure.dart';
import 'package:nexo/packages/nexo_errors/types/sync_failure.dart';
import 'package:nexo/packages/nexo_errors/types/validation_failure.dart';

part 'failure.freezed.dart';

/// Система ошибок приложения
///
/// Иерархия:
/// Failure
/// ├── NetworkFailure      — проблемы соединения
/// ├── HttpFailure         — HTTP-ответы с ошибками (4xx / 5xx)
/// ├── AuthFailure         — аутентификация / авторизация
/// ├── ValidationFailure   — валидация данных
/// ├── StorageFailure      — SharedPreferences / SecureStorage / FileSystem
/// ├── DatabaseFailure     — локальная БД (Drift, Isar, SQLite)
/// ├── CacheFailure        — кэш
/// ├── ParseFailure        — парсинг / сериализация
/// ├── PermissionFailure   — разрешения ОС
/// ├── PlatformFailure     — MethodChannel / плагины / ОС
/// ├── FileFailure         — работа с файлами
/// ├── LocationFailure     — геолокация
/// ├── NotificationFailure — push-уведомления
/// ├── PaymentFailure      — платежи
/// ├── SyncFailure         — синхронизация данных
/// └── UnknownFailure      — непредвиденные ошибки
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Проблемы соединения
  const factory Failure.network({required NetworkFailure type}) =
      NetworkAppFailure;

  /// HTTP-ошибки (4xx / 5xx)
  const factory Failure.http({
    required HttpFailure type,
    int? statusCode,
    String? message,
    @Default({}) Map<String, List<String>> fieldErrors,
  }) = HttpAppFailure;

  /// Ошибки аутентификации и авторизации
  const factory Failure.auth({required AuthFailure type, String? message}) =
      AuthAppFailure;

  /// Ошибки валидации данных
  const factory Failure.validation({
    required ValidationFailure type,
    String? field,
    String? message,
    @Default({}) Map<String, List<String>> fieldErrors,
  }) = ValidationAppFailure;

  /// Ошибки локального хранилища
  const factory Failure.storage({
    required StorageFailure type,
    String? key,
    String? message,
  }) = StorageAppFailure;

  /// Ошибки локальной базы данных
  const factory Failure.database({
    required DatabaseFailure type,
    String? message,
  }) = DatabaseAppFailure;

  /// Ошибки кэша
  const factory Failure.cache({required CacheFailure type, String? key}) =
      CacheAppFailure;

  /// Ошибки парсинга / сериализации
  const factory Failure.parse({
    required ParseFailure type,
    String? field,
    String? message,
  }) = ParseAppFailure;

  /// Ошибки разрешений ОС
  const factory Failure.permission({
    required PermissionFailure type,
    String? permission,
  }) = PermissionAppFailure;

  /// Ошибки платформы (MethodChannel, плагины, ОС)
  const factory Failure.platform({
    required PlatformFailure type,
    String? details,
  }) = PlatformAppFailure;

  /// Ошибки работы с файлами
  const factory Failure.file({
    required FileFailure type,
    String? path,
    String? message,
  }) = FileAppFailure;

  /// Ошибки геолокации
  const factory Failure.location({
    required LocationFailure type,
    String? message,
  }) = LocationAppFailure;

  /// Ошибки push-уведомлений
  const factory Failure.notification({
    required NotificationFailure type,
    String? message,
  }) = NotificationAppFailure;

  /// Ошибки платежей
  const factory Failure.payment({
    required PaymentFailure type,
    String? message,
    String? transactionId,
  }) = PaymentAppFailure;

  /// Ошибки синхронизации данных
  const factory Failure.sync({required SyncFailure type, String? message}) =
      SyncAppFailure;

  /// Непредвиденная ошибка
  const factory Failure.unknown({
    Object? error,
    StackTrace? stackTrace,
    String? message,
  }) = UnknownAppFailure;

  /// Человеко-читаемое сообщение для UI (русский по умолчанию).
  ///
  /// Для другого языка: [FailureUserMessageX.localizedMessage] с
  /// [EnFailureUserMessages] или своим [FailureUserMessageCatalog].
  String get userMessage => const RuFailureUserMessages().forFailure(this);

  /// Стабильный код (`network.no_internet`, `http.unauthorized`, …) для аналитики и crash-репортов.
  String get code => failureCode(this);

  /// Можно ли повторить запрос автоматически?
  bool get isRetryable => switch (this) {
    NetworkAppFailure(type: NetworkFailure.noInternet) => true,
    NetworkAppFailure(type: NetworkFailure.timeout) => true,
    NetworkAppFailure(type: NetworkFailure.connectionReset) => true,
    HttpAppFailure(type: HttpFailure.internalServerError) => true,
    HttpAppFailure(type: HttpFailure.badGateway) => true,
    HttpAppFailure(type: HttpFailure.serviceUnavailable) => true,
    HttpAppFailure(type: HttpFailure.gatewayTimeout) => true,
    HttpAppFailure(type: HttpFailure.tooManyRequests) => true,
    HttpAppFailure(type: HttpFailure.requestTimeout) => true,
    SyncAppFailure(type: SyncFailure.timeout) => true,
    SyncAppFailure(type: SyncFailure.serverUnavailable) => true,
    _ => false,
  };

  /// Требует ли выхода из аккаунта?
  bool get requiresLogout => switch (this) {
    AuthAppFailure(type: AuthFailure.tokenExpired) => true,
    AuthAppFailure(type: AuthFailure.tokenInvalid) => true,
    AuthAppFailure(type: AuthFailure.refreshTokenExpired) => true,
    AuthAppFailure(type: AuthFailure.refreshTokenInvalid) => true,
    AuthAppFailure(type: AuthFailure.sessionRevoked) => true,
    AuthAppFailure(type: AuthFailure.sessionNotFound) => true,
    HttpAppFailure(type: HttpFailure.unauthorized) => true,
    _ => false,
  };

  /// Требует ли открытия настроек устройства?
  bool get requiresSettings => switch (this) {
    PermissionAppFailure(type: PermissionFailure.permanentlyDenied) => true,
    PermissionAppFailure(type: PermissionFailure.cameraDenied) => true,
    PermissionAppFailure(type: PermissionFailure.microphoneDenied) => true,
    PermissionAppFailure(type: PermissionFailure.locationDenied) => true,
    PermissionAppFailure(type: PermissionFailure.notificationDenied) => true,
    LocationAppFailure(type: LocationFailure.permissionPermanentlyDenied) =>
      true,
    _ => false,
  };

  /// Категория для логирования / аналитики
  String get logCategory => switch (this) {
    NetworkAppFailure() => 'network',
    HttpAppFailure() => 'http',
    AuthAppFailure() => 'auth',
    ValidationAppFailure() => 'validation',
    StorageAppFailure() => 'storage',
    DatabaseAppFailure() => 'database',
    CacheAppFailure() => 'cache',
    ParseAppFailure() => 'parse',
    PermissionAppFailure() => 'permission',
    PlatformAppFailure() => 'platform',
    FileAppFailure() => 'file',
    LocationAppFailure() => 'location',
    NotificationAppFailure() => 'notification',
    PaymentAppFailure() => 'payment',
    SyncAppFailure() => 'sync',
    UnknownAppFailure() => 'unknown',
  };
}
