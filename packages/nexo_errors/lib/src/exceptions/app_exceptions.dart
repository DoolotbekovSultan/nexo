import 'package:nexo_errors/src/types/auth_failure.dart';
import 'package:nexo_errors/src/types/cache_failure.dart';
import 'package:nexo_errors/src/types/database_failure.dart';
import 'package:nexo_errors/src/types/file_failure.dart';
import 'package:nexo_errors/src/types/location_failure.dart';
import 'package:nexo_errors/src/types/notification_failure.dart';
import 'package:nexo_errors/src/types/parse_failure.dart';
import 'package:nexo_errors/src/types/payment_failure.dart';
import 'package:nexo_errors/src/types/permission_failure.dart';
import 'package:nexo_errors/src/types/platform_failure.dart';
import 'package:nexo_errors/src/types/storage_failure.dart';
import 'package:nexo_errors/src/types/sync_failure.dart';
import 'package:nexo_errors/src/types/validation_failure.dart';

/// Исключение аутентификации.
///
/// Бросается при ошибках входа, регистрации, обновления токена и т.д.
/// Маппится в [Failure.auth] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки аутентификации.
/// [message] — описание ошибки (опционально).
final class AuthAppException implements Exception {
  final AuthFailure type;
  final String? message;

  const AuthAppException(this.type, {this.message});

  @override
  String toString() => 'AuthAppException(type: $type, message: $message)';
}

/// Исключение валидации.
///
/// Бросается при нарушении правил валидации данных.
/// Маппится в [Failure.validation] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки валидации.
/// [field] — имя поля с ошибкой (опционально).
/// [message] — описание ошибки (опционально).
/// [fieldErrors] — ошибки по полям (опционально).
final class ValidationAppException implements Exception {
  final ValidationFailure type;
  final String? field;
  final String? message;
  final Map<String, List<String>> fieldErrors;

  const ValidationAppException(
    this.type, {
    this.field,
    this.message,
    this.fieldErrors = const {},
  });

  @override
  String toString() =>
      'ValidationAppException(type: $type, field: $field, message: $message)';
}

/// Исключение хранилища данных.
///
/// Бросается при ошибках чтения/записи в локальное хранилище.
/// Маппится в [Failure.storage] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки хранилища.
/// [key] — ключ, с которым связана ошибка (опционально).
/// [message] — описание ошибки (опционально).
final class StorageAppException implements Exception {
  final StorageFailure type;
  final String? key;
  final String? message;

  const StorageAppException(this.type, {this.key, this.message});

  @override
  String toString() =>
      'StorageAppException(type: $type, key: $key, message: $message)';
}

/// Исключение базы данных.
///
/// Бросается при ошибках работы с SQLite, Isar, Drift и т.д.
/// Маппится в [Failure.database] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки БД.
/// [message] — описание ошибки (опционально).
final class DatabaseAppException implements Exception {
  final DatabaseFailure type;
  final String? message;

  const DatabaseAppException(this.type, {this.message});

  @override
  String toString() => 'DatabaseAppException(type: $type, message: $message)';
}

/// Исключение кэша.
///
/// Бросается при ошибках чтения/записи в кэш.
/// Маппится в [Failure.cache] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки кэша.
/// [key] — ключ кэша (опционально).
final class CacheAppException implements Exception {
  final CacheFailure type;
  final String? key;

  const CacheAppException(this.type, {this.key});

  @override
  String toString() => 'CacheAppException(type: $type, key: $key)';
}

/// Исключение парсинга данных.
///
/// Бросается при ошибках разбора JSON, дат, типов и т.д.
/// Маппится в [Failure.parse] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки парсинга.
/// [field] — поле с ошибкой (опционально).
/// [message] — описание ошибки (опционально).
final class ParseAppException implements Exception {
  final ParseFailure type;
  final String? field;
  final String? message;

  const ParseAppException(this.type, {this.field, this.message});

  @override
  String toString() =>
      'ParseAppException(type: $type, field: $field, message: $message)';
}

/// Исключение разрешений.
///
/// Бросается при отсутствии или запрете разрешений ОС.
/// Маппится в [Failure.permission] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки разрешения.
/// [permission] — имя разрешения (опционально).
final class PermissionAppException implements Exception {
  final PermissionFailure type;
  final String? permission;

  const PermissionAppException(this.type, {this.permission});

  @override
  String toString() =>
      'PermissionAppException(type: $type, permission: $permission)';
}

/// Исключение платформы.
///
/// Бросается при ошибках платформенных плагинов.
/// Маппится в [Failure.platform] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки платформы.
/// [details] — дополнительные детали (опционально).
final class PlatformAppException implements Exception {
  final PlatformFailure type;
  final String? details;

  const PlatformAppException(this.type, {this.details});

  @override
  String toString() => 'PlatformAppException(type: $type, details: $details)';
}

/// Исключение работы с файлами.
///
/// Бросается при ошибках чтения, записи, удаления файлов.
/// Маппится в [Failure.file] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки файла.
/// [path] — путь к файлу (опционально).
/// [message] — описание ошибки (опционально).
final class FileAppException implements Exception {
  final FileFailure type;
  final String? path;
  final String? message;

  const FileAppException(this.type, {this.path, this.message});

  @override
  String toString() =>
      'FileAppException(type: $type, path: $path, message: $message)';
}

/// Исключение геолокации.
///
/// Бросается при ошибках определения местоположения.
/// Маппится в [Failure.location] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки локации.
/// [message] — описание ошибки (опционально).
final class LocationAppException implements Exception {
  final LocationFailure type;
  final String? message;

  const LocationAppException(this.type, {this.message});

  @override
  String toString() => 'LocationAppException(type: $type, message: $message)';
}

/// Исключение push-уведомлений.
///
/// Бросается при ошибках регистрации или отправки уведомлений.
/// Маппится в [Failure.notification] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки уведомлений.
/// [message] — описание ошибки (опционально).
final class NotificationAppException implements Exception {
  final NotificationFailure type;
  final String? message;

  const NotificationAppException(this.type, {this.message});

  @override
  String toString() =>
      'NotificationAppException(type: $type, message: $message)';
}

/// Исключение платежей.
///
/// Бросается при ошибках оплаты, возврата, подтверждения транзакций.
/// Маппится в [Failure.payment] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки платежа.
/// [message] — описание ошибки (опционально).
/// [transactionId] — идентификатор транзакции (опционально).
final class PaymentAppException implements Exception {
  final PaymentFailure type;
  final String? message;
  final String? transactionId;

  const PaymentAppException(this.type, {this.message, this.transactionId});

  @override
  String toString() =>
      'PaymentAppException(type: $type, transactionId: $transactionId, message: $message)';
}

/// Исключение синхронизации.
///
/// Бросается при ошибках синхронизации данных с сервером.
/// Маппится в [Failure.sync] через [DomainExceptionFailureMapper].
///
/// [type] — тип ошибки синхронизации.
/// [message] — описание ошибки (опционально).
final class SyncAppException implements Exception {
  final SyncFailure type;
  final String? message;

  const SyncAppException(this.type, {this.message});

  @override
  String toString() => 'SyncAppException(type: $type, message: $message)';
}
