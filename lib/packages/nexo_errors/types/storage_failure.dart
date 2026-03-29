enum StorageFailure {
  /// Ошибка чтения
  readError,

  /// Ошибка записи
  writeError,

  /// Ошибка удаления
  deleteError,

  /// Ошибка очистки
  clearError,

  /// Ключ / файл не найден
  notFound,

  /// Нет разрешения на доступ к хранилищу
  permissionDenied,

  /// Хранилище переполнено
  outOfSpace,

  /// Данные повреждены
  corrupted,

  /// Ошибка шифрования данных
  encryptionError,

  /// Ошибка расшифровки данных
  decryptionError,

  /// Хранилище недоступно (заблокировано системой)
  unavailable,

  /// Несовместимая версия данных
  versionMismatch,
}
