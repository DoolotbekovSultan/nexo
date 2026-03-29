import '../failure.dart';
import '../types/database_failure.dart';
import '../types/parse_failure.dart';
import '../types/storage_failure.dart';
import 'failure_sub_mapper.dart';

final class IsarFailureMapper implements FailureSubMapper {
  const IsarFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    final runtime = error.runtimeType.toString().toLowerCase();
    final text = error.toString().toLowerCase();

    final looksLikeIsar = runtime.contains('isar') || text.contains('isar');
    if (!looksLikeIsar) return null;

    if (_containsAny(text, const [
      'schema',
      'serialization',
      'deserialize',
      'type mismatch',
      'invalid type',
    ])) {
      return const Failure.parse(type: ParseFailure.schemaMismatch);
    }

    if (_containsAny(text, const ['unique', 'duplicate', 'already exists'])) {
      return const Failure.database(
        type: DatabaseFailure.uniqueConstraintViolation,
      );
    }

    if (_containsAny(text, const [
      'transaction',
      'txn',
      'write txn',
      'read txn',
    ])) {
      return const Failure.database(type: DatabaseFailure.transactionFailed);
    }

    if (_containsAny(text, const ['not found', 'object not found'])) {
      return const Failure.database(type: DatabaseFailure.notFound);
    }

    if (_containsAny(text, const ['corrupt', 'corrupted', 'damaged'])) {
      return const Failure.database(type: DatabaseFailure.corrupted);
    }

    if (_containsAny(text, const ['disk full', 'no space left'])) {
      return const Failure.storage(type: StorageFailure.outOfSpace);
    }

    if (_containsAny(text, const ['timeout', 'timed out'])) {
      return const Failure.database(type: DatabaseFailure.queryTimeout);
    }

    if (_containsAny(text, const ['read', 'query', 'find', 'get'])) {
      return const Failure.database(type: DatabaseFailure.readError);
    }

    if (_containsAny(text, const [
      'write',
      'put',
      'insert',
      'upsert',
      'save',
    ])) {
      return const Failure.database(type: DatabaseFailure.writeError);
    }

    if (_containsAny(text, const ['update', 'modify'])) {
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
