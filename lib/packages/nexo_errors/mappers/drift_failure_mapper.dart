import '../failure.dart';
import '../types/database_failure.dart';
import '../types/storage_failure.dart';
import 'failure_sub_mapper.dart';

final class DriftFailureMapper implements FailureSubMapper {
  const DriftFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    final runtime = error.runtimeType.toString().toLowerCase();
    final text = error.toString().toLowerCase();

    final looksLikeDrift =
        runtime.contains('drift') ||
        runtime.contains('sqlite') ||
        text.contains('sqlite') ||
        text.contains('sql error');

    if (!looksLikeDrift) return null;

    if (_containsAny(text, const [
      'unique constraint failed',
      'duplicate',
      'already exists',
    ])) {
      return const Failure.database(
        type: DatabaseFailure.uniqueConstraintViolation,
      );
    }

    if (_containsAny(text, const [
      'foreign key constraint failed',
      'foreign key',
    ])) {
      return const Failure.database(type: DatabaseFailure.foreignKeyViolation);
    }

    if (_containsAny(text, const [
      'not null constraint failed',
      'null value',
    ])) {
      return const Failure.database(type: DatabaseFailure.notNullViolation);
    }

    if (_containsAny(text, const ['database is locked', 'locked', 'busy'])) {
      return const Failure.database(type: DatabaseFailure.locked);
    }

    if (_containsAny(text, const [
      'malformed',
      'corrupt',
      'corrupted',
      'database disk image is malformed',
    ])) {
      return const Failure.database(type: DatabaseFailure.corrupted);
    }

    if (_containsAny(text, const ['no space left', 'disk full'])) {
      return const Failure.storage(type: StorageFailure.outOfSpace);
    }

    if (_containsAny(text, const ['timeout', 'timed out'])) {
      return const Failure.database(type: DatabaseFailure.queryTimeout);
    }

    if (_containsAny(text, const ['transaction', 'rollback', 'commit'])) {
      return const Failure.database(type: DatabaseFailure.transactionFailed);
    }

    if (_containsAny(text, const [
      'no such table',
      'migration',
      'schema version',
      'missing column',
      'no such column',
    ])) {
      return const Failure.database(type: DatabaseFailure.migrationFailed);
    }

    if (_containsAny(text, const ['select', 'query', 'read'])) {
      return const Failure.database(type: DatabaseFailure.readError);
    }

    if (_containsAny(text, const ['insert', 'write', 'save', 'upsert'])) {
      return const Failure.database(type: DatabaseFailure.writeError);
    }

    if (_containsAny(text, const ['update'])) {
      return const Failure.database(type: DatabaseFailure.updateError);
    }

    if (_containsAny(text, const ['delete', 'remove'])) {
      return const Failure.database(type: DatabaseFailure.deleteError);
    }

    return const Failure.database(type: DatabaseFailure.writeError);
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
