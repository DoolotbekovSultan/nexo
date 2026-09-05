import 'package:dio/dio.dart';
import 'package:nexo/packages/nexo_core/network/client/dio_client.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Базовый класс для удалённых источников данных.
///
/// Оборачивает [DioClient] с автоматическим логированием ошибок.
/// Все HTTP-методы (GET, POST, PUT, PATCH, DELETE, download, postFormData)
/// проксируются через внутренний [_run] с перехватом и логированием исключений.
///
/// ## Пример использования
///
/// ```dart
/// class UsersRemoteDataSource extends BaseRemoteDataSource {
///   UsersRemoteDataSource(super.client, {required super.logger});
///
///   Future<List<User>> getUsers() async {
///     final response = await get<List<dynamic>>('/users');
///     return response.data!.map((e) => User.fromJson(e)).toList();
///   }
/// }
/// ```
///
/// См. также: [DioClient].
abstract class BaseRemoteDataSource {
  /// HTTP-клиент для выполнения запросов.
  final DioClient client;

  final NexoLogger _logger;

  /// Создаёт экземпляр [BaseRemoteDataSource].
  ///
  /// [client] — HTTP-клиент.
  /// [logger] — логгер для записи ошибок.
  const BaseRemoteDataSource(this.client, {required NexoLogger logger})
    : _logger = logger;

  String _tag(String message) => '[Remote] $message';

  Future<R> _run<R>(String action, Future<R> Function() operation) async {
    try {
      return await operation();
    } on DioException catch (error, stackTrace) {
      _logger.error(
        message: _tag(action),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } catch (error, stackTrace) {
      _logger.error(
        message: _tag(action),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
    return _run(
      'GET failed path=$path',
      () => client.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
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
    return _run(
      'POST failed path=$path',
      () => client.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
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
    return _run(
      'PUT failed path=$path',
      () => client.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
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
    return _run(
      'PATCH failed path=$path',
      () => client.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
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
    return _run(
      'DELETE failed path=$path',
      () => client.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
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
  /// **Возвращает:** [Future<Response>] с результатом загрузки.
  Future<Response> download(
    String urlPath,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _run(
      'DOWNLOAD failed url=$urlPath',
      () => client.download(
        urlPath,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      ),
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
    return _run(
      'POST FORM-DATA failed path=$path',
      () => client.postFormData<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }
}
