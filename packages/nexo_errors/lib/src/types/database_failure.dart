enum DatabaseFailure {
  /// Ошибка чтения
  readError,

  /// Ошибка записи
  writeError,

  /// Ошибка удаления
  deleteError,

  /// Ошибка обновления
  updateError,

  /// Запись не найдена
  notFound,

  /// Нарушение уникальности (duplicate key)
  uniqueConstraintViolation,

  /// Нарушение внешнего ключа
  foreignKeyViolation,

  /// Нарушение ненулевого значения
  notNullViolation,

  /// Миграция провалилась
  migrationFailed,

  /// Транзакция провалилась
  transactionFailed,

  /// База данных повреждена
  corrupted,

  /// База данных заблокирована
  locked,

  /// Соединение с БД разорвано
  connectionLost,

  /// База данных переполнена
  outOfSpace,

  /// Таймаут запроса к БД
  queryTimeout,
}
