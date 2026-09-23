import 'package:nexo_errors/nexo_errors.dart';

/// Специализированный маппер ошибок Hive.
///
/// Преобразует ошибки Hive (отсутствие бокса, повреждение данных,
/// нехватка места, ошибки шифрования/расшифровки и т.д.) в
/// соответствующие [Failure]. Определяет тип ошибки по stackTrace
/// и ключевым словам в сообщении исключения.
///
/// Используется в цепочке [FailureSubMapper] как часть [FailureMapper].
///
/// См. также: [FailureSubMapper], [CommonFailureMapper].
final class HiveFailureMapper implements FailureSubMapper {
  const HiveFailureMapper();

  /// Пытается преобразовать [error] в [Failure], если это ошибка Hive.
  ///
  /// Анализирует stackTrace и сообщение ошибки для определения категории:
  /// - Отсутствие/закрытие бокса → [CacheFailure.miss]
  /// - Повреждение данных → [StorageFailure.corrupted]
  /// - Нехватка места → [StorageFailure.outOfSpace]
  /// - Ошибки шифрования → [StorageFailure.encryptionError] / [decryptionError]
  /// - Ошибки версии → [StorageFailure.versionMismatch]
  ///
  /// **Возвращает:** [Failure] или `null`, если ошибка не является ошибкой Hive.
  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    final traceStr = stackTrace?.toString() ?? '';
    final errorStr = error.toString();

    // Проверяем по stackTrace — есть ли package:hive в frame
    final isHiveError =
        traceStr.contains('package:hive') ||
        errorStr.contains('HiveError') ||
        errorStr.contains('HiveImpl') ||
        errorStr.contains('BoxCaptureError') ||
        errorStr.contains('LazyBox');

    if (!isHiveError) return null;

    // Box не найден / не открыт / не инициализирован
    if (_containsAny(errorStr, const [
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
    if (_containsAny(errorStr, const [
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
    if (_containsAny(errorStr, const [
      'disk full',
      'no space left',
      'space left on device',
      'database or disk is full',
    ])) {
      return const Failure.storage(type: StorageFailure.outOfSpace);
    }

    // Нет доступа
    if (_containsAny(errorStr, const [
      'permission denied',
      'access denied',
      'operation not permitted',
      'read-only file system',
    ])) {
      return const Failure.storage(type: StorageFailure.permissionDenied);
    }

    // Хранилище недоступно
    if (_containsAny(errorStr, const [
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
    if (_containsAny(errorStr, const [
      'encrypt',
      'encryption',
      'cipher',
      'crypto',
    ])) {
      return const Failure.storage(type: StorageFailure.encryptionError);
    }

    if (_containsAny(errorStr, const [
      'decrypt',
      'decryption',
      'invalid key',
      'wrong key',
    ])) {
      return const Failure.storage(type: StorageFailure.decryptionError);
    }

    // Несовместимая версия / адаптер
    if (_containsAny(errorStr, const [
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
    if (_containsAny(errorStr, const [
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
    if (_containsAny(errorStr, const [
      'clear',
      'clearing box',
      'failed to clear',
    ])) {
      return const Failure.storage(type: StorageFailure.clearError);
    }

    // Удаление
    if (_containsAny(errorStr, const [
      'delete',
      'remove',
      'failed to delete',
    ])) {
      return const Failure.storage(type: StorageFailure.deleteError);
    }

    // Запись
    if (_containsAny(errorStr, const [
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
    if (_containsAny(errorStr, const [
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
