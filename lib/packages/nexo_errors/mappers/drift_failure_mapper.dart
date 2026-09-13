import '../failure.dart';
import '../types/database_failure.dart';
import '../types/storage_failure.dart';
import 'failure_sub_mapper.dart';

/// Специализированный маппер ошибок ORM Drift (SQLite).
///
/// Преобразует исключения Drift/SQLite в [Failure] категорий [DatabaseFailure]
/// и [StorageFailure]. Определяет тип ошибки по stackTrace и тексту сообщения:
/// нарушение уникальности, внешнего ключа, блокировка, повреждение, нехватка
/// места, таймаут, ошибка транзакции, миграция и операции CRUD.
///
/// Идентификация Drift-ошибок происходит по presence `package:drift` в stackTrace
/// и ключевым словам в имени типа/сообщении.
///
/// См. также: [FailureSubMapper], [IsarFailureMapper], [HiveFailureMapper].
final class DriftFailureMapper implements FailureSubMapper {
  const DriftFailureMapper();

  /// Пытается преобразовать [error] в [Failure], если ошибка связана с Drift/SQLite.
  ///
  /// Определяет принадлежность к Drift по stackTrace и тексту сообщения.
  /// Маппит ошибки на конкретные типы [DatabaseFailure] и [StorageFailure].
  ///
  /// **Возвращает:** [Failure] или `null`, если ошибка не связана с Drift.
  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    final traceStr = stackTrace?.toString() ?? '';
    final errorStr = error.toString();

    // Проверяем по stackTrace — есть ли package:drift в frame
    final isDriftError =
        traceStr.contains('package:drift') ||
        errorStr.contains('DriftError') ||
        errorStr.contains('SqliteError') ||
        errorStr.contains('SQLiteException');

    if (!isDriftError) return null;

    if (_containsAny(errorStr, const [
      'unique constraint failed',
      'duplicate',
      'already exists',
    ])) {
      return const Failure.database(
        type: DatabaseFailure.uniqueConstraintViolation,
      );
    }

    if (_containsAny(errorStr, const [
      'foreign key constraint failed',
      'foreign key',
    ])) {
      return const Failure.database(type: DatabaseFailure.foreignKeyViolation);
    }

    if (_containsAny(errorStr, const [
      'not null constraint failed',
      'null value',
    ])) {
      return const Failure.database(type: DatabaseFailure.notNullViolation);
    }

    if (_containsAny(errorStr, const [
      'database is locked',
      'locked',
      'busy',
    ])) {
      return const Failure.database(type: DatabaseFailure.locked);
    }

    if (_containsAny(errorStr, const [
      'malformed',
      'corrupt',
      'corrupted',
      'database disk image is malformed',
    ])) {
      return const Failure.database(type: DatabaseFailure.corrupted);
    }

    if (_containsAny(errorStr, const ['no space left', 'disk full'])) {
      return const Failure.storage(type: StorageFailure.outOfSpace);
    }

    if (_containsAny(errorStr, const ['timeout', 'timed out'])) {
      return const Failure.database(type: DatabaseFailure.queryTimeout);
    }

    if (_containsAny(errorStr, const ['transaction', 'rollback', 'commit'])) {
      return const Failure.database(type: DatabaseFailure.transactionFailed);
    }

    if (_containsAny(errorStr, const [
      'no such table',
      'migration',
      'schema version',
      'missing column',
      'no such column',
    ])) {
      return const Failure.database(type: DatabaseFailure.migrationFailed);
    }

    if (_containsAny(errorStr, const ['select', 'query', 'read'])) {
      return const Failure.database(type: DatabaseFailure.readError);
    }

    if (_containsAny(errorStr, const ['insert', 'write', 'save', 'upsert'])) {
      return const Failure.database(type: DatabaseFailure.writeError);
    }

    if (_containsAny(errorStr, const ['update'])) {
      return const Failure.database(type: DatabaseFailure.updateError);
    }

    if (_containsAny(errorStr, const ['delete', 'remove'])) {
      return const Failure.database(type: DatabaseFailure.deleteError);
    }

    return const Failure.database(type: DatabaseFailure.writeError);
  }

  /// Проверяет, содержит ли [source] хотя бы одну строку из [patterns].
  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
