enum ValidationFailure {
  /// Обязательное поле пустое
  requiredField,

  /// Неверный формат поля
  invalidFormat,

  /// Неверный формат email
  invalidEmail,

  /// Неверный формат телефона
  invalidPhone,

  /// Неверный формат URL
  invalidUrl,

  /// Неверный формат даты
  invalidDate,

  /// Неверный формат времени
  invalidTime,

  /// Неверный формат числа
  invalidNumber,

  /// Неверный формат номера карты
  invalidCardNumber,

  /// Значение превышает максимальную длину
  tooLong,

  /// Значение меньше минимальной длины
  tooShort,

  /// Числовое значение выше максимума
  tooLarge,

  /// Числовое значение ниже минимума
  tooSmall,

  /// Значение вне допустимого диапазона
  outOfRange,

  /// Значение не уникально (уже существует)
  notUnique,

  /// Пароль слишком слабый
  passwordTooWeak,

  /// Пароли не совпадают
  passwordMismatch,

  /// Файл слишком большой
  fileTooLarge,

  /// Неверный тип файла
  invalidFileType,

  /// Неверный размер изображения
  invalidImageSize,

  /// Значение содержит недопустимые символы
  invalidCharacters,

  /// Несколько ошибок валидации от сервера
  serverValidation,
}
