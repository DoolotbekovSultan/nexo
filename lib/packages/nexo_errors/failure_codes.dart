import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/types/http_failure.dart';

/// Стабильный код вида `network.no_internet`, `http.unauthorized`, `unknown`.
///
/// Подходит для Sentry/Crashlytics, логов и бэкенд-аналитики.
String failureCode(Failure failure) {
  return switch (failure) {
    NetworkAppFailure(:final type) => 'network.${_snake(type.name)}',
    HttpAppFailure(:final type, :final statusCode) =>
      type == HttpFailure.unknown && statusCode != null
          ? 'http.status_$statusCode'
          : 'http.${_snake(type.name)}',
    AuthAppFailure(:final type) => 'auth.${_snake(type.name)}',
    ValidationAppFailure(:final type) => 'validation.${_snake(type.name)}',
    StorageAppFailure(:final type) => 'storage.${_snake(type.name)}',
    DatabaseAppFailure(:final type) => 'database.${_snake(type.name)}',
    CacheAppFailure(:final type) => 'cache.${_snake(type.name)}',
    ParseAppFailure(:final type) => 'parse.${_snake(type.name)}',
    PermissionAppFailure(:final type) => 'permission.${_snake(type.name)}',
    PlatformAppFailure(:final type) => 'platform.${_snake(type.name)}',
    FileAppFailure(:final type) => 'file.${_snake(type.name)}',
    LocationAppFailure(:final type) => 'location.${_snake(type.name)}',
    NotificationAppFailure(:final type) => 'notification.${_snake(type.name)}',
    PaymentAppFailure(:final type) => 'payment.${_snake(type.name)}',
    SyncAppFailure(:final type) => 'sync.${_snake(type.name)}',
    UnknownAppFailure() => 'unknown',
  };
}

String _snake(String camelCase) {
  return camelCase
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (m) => '${m[1]}_${m[2]!.toLowerCase()}',
      )
      .toLowerCase();
}
