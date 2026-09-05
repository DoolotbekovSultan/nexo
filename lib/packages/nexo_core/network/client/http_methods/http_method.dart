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
///
/// См. также: [DioClient], [HttpMethodExtension].
enum HttpMethod {
  /// HTTP GET — получение данных.
  get,

  /// HTTP POST — создание ресурса.
  post,

  /// HTTP PUT — полная замена ресурса.
  put,

  /// HTTP PATCH — частичное обновление ресурса.
  patch,

  /// HTTP DELETE — удаление ресурса.
  delete,

  /// HTTP HEAD — получение заголовков без тела.
  head,

  /// HTTP OPTIONS — запрос доступных методов.
  options,
}
