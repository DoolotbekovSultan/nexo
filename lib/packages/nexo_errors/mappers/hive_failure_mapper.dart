import '../failure.dart';
import '../types/cache_failure.dart';
import '../types/database_failure.dart';
import '../types/parse_failure.dart';
import '../types/storage_failure.dart';
import 'failure_sub_mapper.dart';

final class HiveFailureMapper implements FailureSubMapper {
  const HiveFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    final runtime = error.runtimeType.toString().toLowerCase();
    final text = error.toString().toLowerCase();

    final looksLikeHive =
        runtime.contains('hive') ||
        text.contains('hive') ||
        text.contains('box');

    if (!looksLikeHive) return null;

    if (_containsAny(text, const [
      'box not found',
      'not found',
      'no box',
      'box has not been opened',
    ])) {
      return const Failure.cache(type: CacheFailure.miss);
    }

    if (_containsAny(text, const [
      'corrupt',
      'corrupted',
      'broken',
      'invalid hive file',
    ])) {
      return const Failure.storage(type: StorageFailure.corrupted);
    }

    if (_containsAny(text, const [
      'disk full',
      'no space left',
      'space left on device',
    ])) {
      return const Failure.storage(type: StorageFailure.outOfSpace);
    }

    if (_containsAny(text, const [
      'permission denied',
      'access denied',
      'operation not permitted',
    ])) {
      return const Failure.storage(type: StorageFailure.permissionDenied);
    }

    if (_containsAny(text, const [
      'type',
      'cast',
      'cannot read',
      'deserialize',
      'decode',
      'adapter',
    ])) {
      return const Failure.parse(type: ParseFailure.schemaMismatch);
    }

    if (_containsAny(text, const ['read', 'open box', 'load'])) {
      return const Failure.storage(type: StorageFailure.readError);
    }

    if (_containsAny(text, const ['write', 'put', 'save', 'compact'])) {
      return const Failure.storage(type: StorageFailure.writeError);
    }

    if (_containsAny(text, const ['delete', 'remove', 'clear'])) {
      return const Failure.storage(type: StorageFailure.deleteError);
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
