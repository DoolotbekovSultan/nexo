import '../types/auth_failure.dart';
import '../types/cache_failure.dart';
import '../types/database_failure.dart';
import '../types/file_failure.dart';
import '../types/location_failure.dart';
import '../types/notification_failure.dart';
import '../types/parse_failure.dart';
import '../types/payment_failure.dart';
import '../types/permission_failure.dart';
import '../types/platform_failure.dart';
import '../types/storage_failure.dart';
import '../types/sync_failure.dart';
import '../types/validation_failure.dart';

final class AuthAppException implements Exception {
  final AuthFailure type;
  final String? message;

  const AuthAppException(this.type, {this.message});

  @override
  String toString() => 'AuthAppException(type: $type, message: $message)';
}

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

final class StorageAppException implements Exception {
  final StorageFailure type;
  final String? key;
  final String? message;

  const StorageAppException(this.type, {this.key, this.message});

  @override
  String toString() =>
      'StorageAppException(type: $type, key: $key, message: $message)';
}

final class DatabaseAppException implements Exception {
  final DatabaseFailure type;
  final String? message;

  const DatabaseAppException(this.type, {this.message});

  @override
  String toString() => 'DatabaseAppException(type: $type, message: $message)';
}

final class CacheAppException implements Exception {
  final CacheFailure type;
  final String? key;

  const CacheAppException(this.type, {this.key});

  @override
  String toString() => 'CacheAppException(type: $type, key: $key)';
}

final class ParseAppException implements Exception {
  final ParseFailure type;
  final String? field;
  final String? message;

  const ParseAppException(this.type, {this.field, this.message});

  @override
  String toString() =>
      'ParseAppException(type: $type, field: $field, message: $message)';
}

final class PermissionAppException implements Exception {
  final PermissionFailure type;
  final String? permission;

  const PermissionAppException(this.type, {this.permission});

  @override
  String toString() =>
      'PermissionAppException(type: $type, permission: $permission)';
}

final class PlatformAppException implements Exception {
  final PlatformFailure type;
  final String? details;

  const PlatformAppException(this.type, {this.details});

  @override
  String toString() => 'PlatformAppException(type: $type, details: $details)';
}

final class FileAppException implements Exception {
  final FileFailure type;
  final String? path;
  final String? message;

  const FileAppException(this.type, {this.path, this.message});

  @override
  String toString() =>
      'FileAppException(type: $type, path: $path, message: $message)';
}

final class LocationAppException implements Exception {
  final LocationFailure type;
  final String? message;

  const LocationAppException(this.type, {this.message});

  @override
  String toString() => 'LocationAppException(type: $type, message: $message)';
}

final class NotificationAppException implements Exception {
  final NotificationFailure type;
  final String? message;

  const NotificationAppException(this.type, {this.message});

  @override
  String toString() =>
      'NotificationAppException(type: $type, message: $message)';
}

final class PaymentAppException implements Exception {
  final PaymentFailure type;
  final String? message;
  final String? transactionId;

  const PaymentAppException(this.type, {this.message, this.transactionId});

  @override
  String toString() =>
      'PaymentAppException(type: $type, transactionId: $transactionId, message: $message)';
}

final class SyncAppException implements Exception {
  final SyncFailure type;
  final String? message;

  const SyncAppException(this.type, {this.message});

  @override
  String toString() => 'SyncAppException(type: $type, message: $message)';
}
