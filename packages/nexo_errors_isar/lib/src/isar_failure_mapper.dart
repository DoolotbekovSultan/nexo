import 'package:nexo_errors/nexo_errors.dart';

/// Специализированный маппер ошибок Isar.
///
/// Преобразует ошибки Isar (нарушение схемы, уникальности, транзакций,
/// повреждение БД, нехватка места и т.д.) в соответствующие [Failure].
/// Определяет тип ошибки по stackTrace и ключевым словам в сообщении.
///
/// Используется в цепочке [FailureSubMapper] как часть [FailureMapper].
///
/// См. также: [FailureSubMapper], [CommonFailureMapper].
final class IsarFailureMapper implements FailureSubMapper {
  const IsarFailureMapper();

  /// Пытается преобразовать [error] в [Failure], если это ошибка Isar.
  ///
  /// Анализирует stackTrace и сообщение ошибки для определения категории:
  /// - Нарушение схемы → [ParseFailure.schemaMismatch]
  /// - Нарушение уникальности → [DatabaseFailure.uniqueConstraintViolation]
  /// - Ошибка транзакции → [DatabaseFailure.transactionFailed]
  /// - Повреждение БД → [DatabaseFailure.corrupted]
  ///
  /// **Возвращает:** [Failure] или `null`, если ошибка не является ошибкой Isar.
  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    final traceStr = stackTrace?.toString() ?? '';
    final errorStr = error.toString();

    // Проверяем по stackTrace — есть ли package:isar в frame
    final isIsarError =
        traceStr.contains('package:isar') ||
        errorStr.contains('IsarError') ||
        errorStr.contains('IsarImpl') ||
        errorStr.contains('IsarCollection');

    if (!isIsarError) return null;

    if (_containsAny(errorStr, const [
      'schema',
      'serialization',
      'deserialize',
      'type mismatch',
      'invalid type',
    ])) {
      return const Failure.parse(type: ParseFailure.schemaMismatch);
    }

    if (_containsAny(errorStr, const [
      'unique',
      'duplicate',
      'already exists',
    ])) {
      return const Failure.database(
        type: DatabaseFailure.uniqueConstraintViolation,
      );
    }

    if (_containsAny(errorStr, const [
      'transaction',
      'txn',
      'write txn',
      'read txn',
    ])) {
      return const Failure.database(type: DatabaseFailure.transactionFailed);
    }

    if (_containsAny(errorStr, const ['not found', 'object not found'])) {
      return const Failure.database(type: DatabaseFailure.notFound);
    }

    if (_containsAny(errorStr, const ['corrupt', 'corrupted', 'damaged'])) {
      return const Failure.database(type: DatabaseFailure.corrupted);
    }

    if (_containsAny(errorStr, const ['disk full', 'no space left'])) {
      return const Failure.storage(type: StorageFailure.outOfSpace);
    }

    if (_containsAny(errorStr, const ['timeout', 'timed out'])) {
      return const Failure.database(type: DatabaseFailure.queryTimeout);
    }

    if (_containsAny(errorStr, const ['read', 'query', 'find', 'get'])) {
      return const Failure.database(type: DatabaseFailure.readError);
    }

    if (_containsAny(errorStr, const [
      'write',
      'put',
      'insert',
      'upsert',
      'save',
    ])) {
      return const Failure.database(type: DatabaseFailure.writeError);
    }

    if (_containsAny(errorStr, const ['update', 'modify'])) {
      return const Failure.database(type: DatabaseFailure.updateError);
    }

    if (_containsAny(errorStr, const ['delete', 'remove'])) {
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
