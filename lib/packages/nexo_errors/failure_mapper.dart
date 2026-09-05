import 'package:nexo/packages/nexo_errors/mappers/platform_failure_mapper.dart';

import 'failure.dart';
import 'mappers/common_failure_mapper.dart';
import 'mappers/dio_failure_mapper.dart';
import 'mappers/domain_exception_failure_mapper.dart';
import 'mappers/drift_failure_mapper.dart';
import 'mappers/failure_sub_mapper.dart';
import 'mappers/file_system_failure_mapper.dart';
import 'mappers/firebase_auth_failure_mapper.dart';
import 'mappers/firebase_messaging_failure_mapper.dart';
import 'mappers/hive_failure_mapper.dart';
import 'mappers/isar_failure_mapper.dart';

/// Централизованный маппер ошибок в [Failure].
///
/// Пробует зарегистрированные мапперы по очереди и возвращает первый
/// успешный результат. Если ни один мапpper не распознал ошибку,
/// возвращается [Failure.unknown].
///
/// ## Порядок мапперов
///
/// 1. [DomainExceptionFailureMapper] — кастомные исключения приложения.
/// 2. [FirebaseAuthFailureMapper] — ошибки Firebase Auth.
/// 3. [FirebaseMessagingFailureMapper] — ошибки Firebase Messaging.
/// 4. [DioFailureMapper] — ошибки HTTP-клиента Dio.
/// 5. [PlatformFailureMapper] — ошибки платформенных плагинов.
/// 6. [HiveFailureMapper] — ошибки Hive.
/// 7. [IsarFailureMapper] — ошибки Isar.
/// 8. [DriftFailureMapper] — ошибки Drift/SQLite.
/// 9. [FileSystemFailureMapper] — ошибки файловой системы.
/// 10. [CommonFailureMapper] — универсальный catch-all.
///
/// ## Пример
///
/// ```dart
/// try {
///   final response = await dio.get('/api/data');
/// } catch (e, s) {
///   final failure = FailureMapper.from(e, s);
///   showSnackBar(failure.userMessage);
/// }
/// ```
final class FailureMapper {
  const FailureMapper._();

  static const List<FailureSubMapper> _mappers = [
    DomainExceptionFailureMapper(),
    FirebaseAuthFailureMapper(),
    FirebaseMessagingFailureMapper(),
    DioFailureMapper(),
    PlatformFailureMapper(),
    HiveFailureMapper(),
    IsarFailureMapper(),
    DriftFailureMapper(),
    FileSystemFailureMapper(),
    CommonFailureMapper(),
  ];

  /// Преобразует произвольный [error] в [Failure].
  ///
  /// [error] — исключение или объект ошибки.
  /// [stackTrace] — стек вызовов (опционален, передаётся для логирования).
  ///
  /// **Возвращает:** [Failure] — результат маппинга.
  /// Если [error] уже является [Failure], возвращается как есть.
  static Failure from(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    for (final mapper in _mappers) {
      final failure = mapper.tryMap(error, stackTrace);
      if (failure != null) return failure;
    }

    return Failure.unknown(
      error: error,
      stackTrace: stackTrace,
      message: error.toString(),
    );
  }
}
