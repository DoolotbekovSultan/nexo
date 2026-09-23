enum ParseFailure {
  /// Ошибка десериализации JSON
  jsonDecode,

  /// Ошибка сериализации в JSON
  jsonEncode,

  /// Ошибка парсинга XML
  xmlDecode,

  /// Ошибка парсинга CSV
  csvDecode,

  /// Неожиданный тип данных
  unexpectedType,

  /// Обязательное поле отсутствует в ответе
  missingField,

  /// Неверное значение enum
  invalidEnumValue,

  /// Пустой ответ от сервера
  emptyResponse,

  /// Null значение там где не ожидается
  nullValue,

  /// Неверный формат даты в ответе
  invalidDateFormat,

  /// Ответ не соответствует схеме
  schemaMismatch,
}
