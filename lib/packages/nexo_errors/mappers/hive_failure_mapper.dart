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
        runtime.contains('box') ||
        text.contains('hive') ||
        text.contains('box') ||
        text.contains('lazybox') ||
        text.contains('hiveerror');

    if (!looksLikeHive) return null;

    // Box не найден / не открыт / не инициализирован
    if (_containsAny(text, const [
      'box not found',
      'not found',
      'no box',
      'box has not been opened',
      'box is not open',
      'is not initialized',
      'not initialized',
      'not opened',
      'was closed',
      'box is closed',
    ])) {
      return const Failure.cache(type: CacheFailure.miss);
    }

    // Повреждение данных
    if (_containsAny(text, const [
      'corrupt',
      'corrupted',
      'broken',
      'invalid hive file',
      'malformed',
      'bad state: cannot read',
      'failed to read frame',
    ])) {
      return const Failure.storage(type: StorageFailure.corrupted);
    }

    // Нет места
    if (_containsAny(text, const [
      'disk full',
      'no space left',
      'space left on device',
      'database or disk is full',
    ])) {
      return const Failure.storage(type: StorageFailure.outOfSpace);
    }

    // Нет доступа
    if (_containsAny(text, const [
      'permission denied',
      'access denied',
      'operation not permitted',
      'read-only file system',
    ])) {
      return const Failure.storage(type: StorageFailure.permissionDenied);
    }

    // Хранилище недоступно
    if (_containsAny(text, const [
      'unavailable',
      'temporarily unavailable',
      'resource busy',
      'file is locked',
      'locked',
      'cannot open file',
      'failed to open',
    ])) {
      return const Failure.storage(type: StorageFailure.unavailable);
    }

    // Шифрование / расшифровка
    if (_containsAny(text, const [
      'encrypt',
      'encryption',
      'cipher',
      'crypto',
    ])) {
      return const Failure.storage(type: StorageFailure.encryptionError);
    }

    if (_containsAny(text, const [
      'decrypt',
      'decryption',
      'invalid key',
      'wrong key',
    ])) {
      return const Failure.storage(type: StorageFailure.decryptionError);
    }

    // Несовместимая версия / адаптер
    if (_containsAny(text, const [
      'unknown typeid',
      'typeid',
      'type adapter',
      'adapter not found',
      'no adapter',
      'unsupported version',
      'version mismatch',
      'incompatible version',
    ])) {
      return const Failure.storage(type: StorageFailure.versionMismatch);
    }

    // Ошибки парсинга / схемы
    if (_containsAny(text, const [
      'type',
      'cast',
      'deserialize',
      'decode',
      'schema',
      'unexpected null value',
      'format exception',
    ])) {
      return const Failure.parse(type: ParseFailure.schemaMismatch);
    }

    // Очистка
    if (_containsAny(text, const [
      'clear',
      'clearing box',
      'failed to clear',
    ])) {
      return const Failure.storage(type: StorageFailure.clearError);
    }

    // Удаление
    if (_containsAny(text, const ['delete', 'remove', 'failed to delete'])) {
      return const Failure.storage(type: StorageFailure.deleteError);
    }

    // Запись
    if (_containsAny(text, const [
      'write',
      'put',
      'save',
      'compact',
      'flush',
      'append',
    ])) {
      return const Failure.storage(type: StorageFailure.writeError);
    }

    // Чтение
    if (_containsAny(text, const [
      'read',
      'load',
      'open box',
      'get',
      'watch',
    ])) {
      return const Failure.storage(type: StorageFailure.readError);
    }

    // Fallback для Hive-like ошибок
    return const Failure.database(type: DatabaseFailure.writeError);
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
