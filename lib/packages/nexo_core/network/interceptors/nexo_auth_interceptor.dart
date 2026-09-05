import 'dart:async';

import 'package:dio/dio.dart';

/// Функция получения текущего токена аутентификации.
///
/// Возвращает токен или `null`, если пользователь не авторизован.
typedef TokenGetter = Future<String?> Function();

/// Функция обновления токена аутентификации.
///
/// Вызывается при получении ошибки 401. Возвращает новый токен
/// или `null`, если обновление невозможно.
typedef TokenRefresher = Future<String?> Function();

/// Callback, вызываемый при истечении срока действия сессии.
///
/// Вызывается однократно при невозможности обновить токен.
typedef TokenExpiredCallback = Future<void> Function();

/// Callback для логирования событий интерсептора.
typedef LoggerCallback = void Function(String message);

/// Интерсептор для автоматической аутентификации запросов.
///
/// Добавляет заголовок `Authorization: Bearer <token>` к каждому запросу.
/// При получении ошибки 401 автоматически обновляет токен и повторяет запрос.
/// Обеспечивает однократный вызов [onTokenExpired] при истечении сессии.
///
/// ## Особенности
///
/// - Потокобезопасное обновление токена (через [Completer]).
/// - Пропуск аутентификации для запросов с `extra[skipAuthKey] = true`.
/// - Повтор запроса с новым токеном (не более одного раза).
///
/// ## Пример использования
///
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(
///   NexoAuthInterceptor(
///     dio: dio,
///     getToken: () => secureStorage.read('access_token'),
///     refreshToken: () => authRepository.refreshToken(),
///     onTokenExpired: () => navigator.pushReplacement('/login'),
///   ),
/// );
/// ```
///
/// См. также: [DioClient], [NexoLoggingInterceptor].
class NexoAuthInterceptor extends Interceptor {
  /// Ключ в [RequestOptions.extra] для пропуска аутентификации.
  static const String skipAuthKey = 'skipAuth';

  /// Ключ в [RequestOptions.extra] для отслеживания повторной попытки.
  static const String retriedKey = '_auth_retried';

  final Dio dio;
  final TokenGetter getToken;
  final TokenRefresher refreshToken;
  final TokenExpiredCallback onTokenExpired;

  /// Ключ заголовка аутентификации. По умолчанию: `Authorization`.
  final String authHeaderKey;

  /// Префикс токена. По умолчанию: `Bearer`.
  final String bearerPrefix;

  /// Коды статуса, при которых происходит обновление токена.
  /// По умолчанию: `{401}`.
  final Set<int> refreshStatusCodes;

  /// Callback для логирования успешных операций (опционально).
  final LoggerCallback? onLog;

  /// Callback для логирования предупреждений (опционально).
  final LoggerCallback? onWarning;

  /// Callback для логирования ошибок (опционально).
  final void Function(String message, Object error, StackTrace stackTrace)?
  onErrorLog;

  Completer<String?>? _refreshCompleter;
  bool _isSessionExpired = false;

  /// Создаёт экземпляр [NexoAuthInterceptor].
  ///
  /// [dio] — экземпляр Dio для повтора запросов.
  /// [getToken] — функция получения текущего токена.
  /// [refreshToken] — функция обновления токена.
  /// [onTokenExpired] — callback при истечении сессии.
  NexoAuthInterceptor({
    /// Экземпляр Dio для повтора запросов с новым токеном.
    required this.dio,

    /// Функция получения текущего токена аутентификации.
    required this.getToken,

    /// Функция обновления токена при ошибке 401.
    required this.refreshToken,

    /// Callback, вызываемый при невозможности обновить токен (однократно).
    required this.onTokenExpired,
    this.authHeaderKey = 'Authorization',
    this.bearerPrefix = 'Bearer',
    this.refreshStatusCodes = const {401},
    this.onLog,
    this.onWarning,
    this.onErrorLog,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] == true) {
      handler.next(options);
      return;
    }

    try {
      final token = await getToken();

      if (token != null && token.isNotEmpty) {
        options.headers[authHeaderKey] = '$bearerPrefix $token';
        onLog?.call('Token added: ${options.method} ${options.uri}');
      }
    } catch (e, st) {
      onErrorLog?.call('Failed to get token', e, st);
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh(err)) {
      handler.next(err);
      return;
    }

    onWarning?.call(
      'Auth error ${err.response?.statusCode}. Refreshing token...',
    );

    try {
      final newToken = await _refreshTokenSafely();

      if (newToken == null || newToken.isEmpty) {
        await _handleTokenExpiredOnce();
        handler.next(err);
        return;
      }

      _isSessionExpired = false;

      final response = await _retryRequest(err.requestOptions, newToken);

      handler.resolve(response);
    } catch (e, st) {
      onErrorLog?.call('Token refresh failed', e, st);
      await _handleTokenExpiredOnce();
      handler.next(err);
    }
  }

  /// Определяет, нужно ли обновлять токен для данной ошибки.
  bool _shouldRefresh(DioException err) {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[retriedKey] == true;
    final skipAuth = err.requestOptions.extra[skipAuthKey] == true;

    return statusCode != null &&
        refreshStatusCodes.contains(statusCode) &&
        !alreadyRetried &&
        !skipAuth;
  }

  /// Потокобезопасно обновляет токен.
  ///
  /// Если обновление уже выполняется, возвращает тот же Future.
  Future<String?> _refreshTokenSafely() {
    final activeRefresh = _refreshCompleter;
    if (activeRefresh != null) {
      return activeRefresh.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    () async {
      try {
        final token = await refreshToken();

        if (!completer.isCompleted) {
          completer.complete(token);
        }
      } catch (e, st) {
        if (!completer.isCompleted) {
          completer.completeError(e, st);
        }
      } finally {
        if (identical(_refreshCompleter, completer)) {
          _refreshCompleter = null;
        }
      }
    }();

    return completer.future;
  }

  /// Обрабатывает истечение сессии однократно.
  Future<void> _handleTokenExpiredOnce() async {
    if (_isSessionExpired) return;

    _isSessionExpired = true;
    await onTokenExpired();
  }

  /// Повторяет запрос с новым токеном.
  Future<Response<dynamic>> _retryRequest(
    RequestOptions options,
    String token,
  ) {
    if (options.cancelToken?.isCancelled == true) {
      return Future.error(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Request was cancelled',
        ),
      );
    }

    final headers = Map<String, dynamic>.from(options.headers)
      ..[authHeaderKey] = '$bearerPrefix $token';

    final extra = Map<String, dynamic>.from(options.extra)..[retriedKey] = true;

    onLog?.call('Retrying: ${options.method} ${options.uri}');

    return dio.requestUri<dynamic>(
      options.uri,
      data: options.data,
      options: Options(
        method: options.method,
        headers: headers,
        extra: extra,
        responseType: options.responseType,
        contentType: options.contentType,
        followRedirects: options.followRedirects,
        receiveDataWhenStatusError: options.receiveDataWhenStatusError,
        validateStatus: options.validateStatus,
        receiveTimeout: options.receiveTimeout,
        sendTimeout: options.sendTimeout,
      ),
      cancelToken: options.cancelToken,
      onReceiveProgress: options.onReceiveProgress,
      onSendProgress: options.onSendProgress,
    );
  }
}
