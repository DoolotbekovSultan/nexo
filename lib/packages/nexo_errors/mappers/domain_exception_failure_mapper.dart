import '../exceptions/app_exceptions.dart';
import '../failure.dart';
import 'failure_sub_mapper.dart';

final class DomainExceptionFailureMapper implements FailureSubMapper {
  const DomainExceptionFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    return switch (error) {
      AuthAppException e => Failure.auth(type: e.type, message: e.message),
      ValidationAppException e => Failure.validation(
        type: e.type,
        field: e.field,
        message: e.message,
        fieldErrors: e.fieldErrors,
      ),
      StorageAppException e => Failure.storage(
        type: e.type,
        key: e.key,
        message: e.message,
      ),
      DatabaseAppException e => Failure.database(
        type: e.type,
        message: e.message,
      ),
      CacheAppException e => Failure.cache(type: e.type, key: e.key),
      ParseAppException e => Failure.parse(
        type: e.type,
        field: e.field,
        message: e.message,
      ),
      PermissionAppException e => Failure.permission(
        type: e.type,
        permission: e.permission,
      ),
      PlatformAppException e => Failure.platform(
        type: e.type,
        details: e.details,
      ),
      FileAppException e => Failure.file(
        type: e.type,
        path: e.path,
        message: e.message,
      ),
      LocationAppException e => Failure.location(
        type: e.type,
        message: e.message,
      ),
      NotificationAppException e => Failure.notification(
        type: e.type,
        message: e.message,
      ),
      PaymentAppException e => Failure.payment(
        type: e.type,
        message: e.message,
        transactionId: e.transactionId,
      ),
      SyncAppException e => Failure.sync(type: e.type, message: e.message),
      _ => null,
    };
  }
}
