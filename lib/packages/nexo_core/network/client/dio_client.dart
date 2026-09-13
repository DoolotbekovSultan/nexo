import 'package:dio/dio.dart';
import 'package:nexo/packages/nexo_core/network/client/http_methods/http_method.dart';

/// Обёртка над [Dio] с типизированными методами HTTP-запросов.
///
/// Предоставляет удобный API для выполнения GET, POST, PUT, PATCH, DELETE,
/// HEAD, OPTIONS запросов, а также загрузки файлов и отправки FormData.
///
/// ## Пример использования
///
/// ```dart
/// final client = DioClient(
///   Dio(BaseOptions(
///     baseUrl: 'https://api.example.com',
///     connectTimeout: Duration(seconds: 10),
///   )),
/// );
///
/// final response = await client.get<List<dynamic>>('/users');
/// ```
///
/// См. также: [HttpMethod], [NexoAuthInterceptor].
class DioClient {
  final Dio _dio;

  /// Создаёт экземпляр [DioClient] с указанным [Dio]-клиентом.
  DioClient(this._dio);

  /// Низкоуровневый доступ к [Dio] для кастомных запросов.
  Dio get dio => _dio;

  /// Выполняет HTTP-запрос по относительному пути.
  ///
  /// [path] — относительный путь (например, `/users`).
  /// [method] — HTTP-метод.
  /// [data] — тело запроса (опционально).
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] —回调 прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: method.value),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет HTTP-запрос по абсолютному URI.
  ///
  /// [uri] — абсолютный URI (должен содержать схему http/https).
  /// [method] — HTTP-метод.
  /// [data] — тело запроса (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] — callback прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Бросает:** [ArgumentError], если URI не содержит схемы.
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> requestUri<T>(
    Uri uri, {
    required HttpMethod method,
    dynamic data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    if (!uri.hasScheme) {
      throw ArgumentError.value(
        uri,
        'uri',
        'requestUri requires an absolute URI. Use request() for relative paths.',
      );
    }

    return _dio.requestUri<T>(
      uri,
      data: data,
      options: (options ?? Options()).copyWith(method: method.value),
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет GET-запрос.
  ///
  /// [path] — относительный путь.
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path,
      method: HttpMethod.get,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет POST-запрос.
  ///
  /// [path] — относительный путь.
  /// [data] — тело запроса (опционально).
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] — callback прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path,
      method: HttpMethod.post,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет PUT-запрос.
  ///
  /// [path] — относительный путь.
  /// [data] — тело запроса (опционально).
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] — callback прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path,
      method: HttpMethod.put,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет PATCH-запрос.
  ///
  /// [path] — относительный путь.
  /// [data] — тело запроса (опционально).
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] — callback прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return request<T>(
      path,
      method: HttpMethod.patch,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет DELETE-запрос.
  ///
  /// [path] — относительный путь.
  /// [data] — тело запроса (опционально).
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      path,
      method: HttpMethod.delete,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Выполняет HEAD-запрос.
  ///
  /// [path] — относительный путь.
  /// [data] — тело запроса (опционально).
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> head<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      path,
      method: HttpMethod.head,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Выполняет OPTIONS-запрос.
  ///
  /// [path] — относительный путь.
  /// [data] — тело запроса (опционально).
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> options<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return request<T>(
      path,
      method: HttpMethod.options,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Выполняет POST-запрос с отправкой FormData.
  ///
  /// [path] — относительный путь.
  /// [data] — FormData с полями и файлами.
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] — callback прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> postFormData<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет PUT-запрос с отправкой FormData.
  ///
  /// [path] — относительный путь.
  /// [data] — FormData с полями и файлами.
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] — callback прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> putFormData<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Выполняет PATCH-запрос с отправкой FormData.
  ///
  /// [path] — относительный путь.
  /// [data] — FormData с полями и файлами.
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onSendProgress] — callback прогресса отправки (опционально).
  /// [onReceiveProgress] — callback прогресса получения (опционально).
  ///
  /// **Возвращает:** [Future<Response<T>>] с ответом сервера.
  Future<Response<T>> patchFormData<T>(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Загружает файл по URL и сохраняет по указанному пути.
  ///
  /// [urlPath] — URL файла для загрузки.
  /// [savePath] — локальный путь для сохранения файла.
  /// [queryParameters] — query-параметры (опционально).
  /// [options] — дополнительные опции Dio (опционально).
  /// [cancelToken] — токен отмены запроса (опционально).
  /// [onReceiveProgress] — callback прогресса загрузки (опционально).
  ///
  /// **Возвращает:** [Future<Response<dynamic>>] с результатом загрузки.
  Future<Response<dynamic>> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.download(
      urlPath,
      savePath,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Текущая конфигурация Dio (baseUrl, timeouts, headers).
  Map<String, dynamic> get config => {
    'baseUrl': _dio.options.baseUrl,
    'connectTimeout': _dio.options.connectTimeout?.inSeconds,
    'receiveTimeout': _dio.options.receiveTimeout?.inSeconds,
    'sendTimeout': _dio.options.sendTimeout?.inSeconds,
    'headers': Map<String, dynamic>.from(_dio.options.headers),
  };
}
