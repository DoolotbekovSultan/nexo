enum FileFailure {
  /// Файл не найден
  notFound,

  /// Ошибка чтения файла
  readError,

  /// Ошибка записи файла
  writeError,

  /// Ошибка удаления файла
  deleteError,

  /// Ошибка копирования файла
  copyError,

  /// Ошибка перемещения файла
  moveError,

  /// Файл слишком большой
  tooLarge,

  /// Неверный тип / расширение файла
  invalidType,

  /// Файл повреждён
  corrupted,

  /// Нет доступа к файлу
  accessDenied,

  /// Директория не найдена
  directoryNotFound,

  /// Ошибка создания директории
  directoryCreationFailed,

  /// Недостаточно места для файла
  outOfSpace,

  /// Ошибка загрузки файла (upload)
  uploadFailed,

  /// Ошибка скачивания файла (download)
  downloadFailed,

  /// Загрузка отменена
  uploadCancelled,

  /// Скачивание отменено
  downloadCancelled,

  /// Таймаут загрузки
  uploadTimeout,

  /// Таймаут скачивания
  downloadTimeout,
}
