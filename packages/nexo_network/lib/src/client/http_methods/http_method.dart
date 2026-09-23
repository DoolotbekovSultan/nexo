/// Перечисление HTTP-методов для запросов.
///
/// Используется в [DioClient] для указания метода запроса.
///
/// ## Пример
///
/// ```dart
/// final response = await client.request(
///   '/users',
///   method: HttpMethod.post,
///   data: {'name': 'John'},
/// );
/// ```
enum HttpMethod {
  /// HTTP GET — получение данных.
  get('GET'),

  /// HTTP POST — создание ресурса.
  post('POST'),

  /// HTTP PUT — полная замена ресурса.
  put('PUT'),

  /// HTTP PATCH — частичное обновление ресурса.
  patch('PATCH'),

  /// HTTP DELETE — удаление ресурса.
  delete('DELETE'),

  /// HTTP HEAD — получение заголовков без тела.
  head('HEAD'),

  /// HTTP OPTIONS — запрос доступных методов.
  options('OPTIONS');

  const HttpMethod(this.value);

  /// Строковое представление HTTP-метода в верхнем регистре.
  final String value;
}
