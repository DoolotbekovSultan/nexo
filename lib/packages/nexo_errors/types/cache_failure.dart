enum CacheFailure {
  /// Данных нет в кэше
  miss,

  /// Кэш устарел
  expired,

  /// Ошибка чтения кэша
  readError,

  /// Ошибка записи в кэш
  writeError,

  /// Ошибка удаления из кэша
  deleteError,

  /// Ошибка очистки кэша
  clearError,

  /// Кэш переполнен
  outOfSpace,

  /// Данные кэша повреждены
  corrupted,

  /// Кэш инвалидирован
  invalidated,
}