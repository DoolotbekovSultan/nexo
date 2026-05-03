import 'dart:async';

import 'package:dio/dio.dart';

typedef TokenGetter = Future<String?> Function();
typedef TokenRefresher = Future<String?> Function();
typedef TokenExpiredCallback = Future<void> Function();
typedef LoggerCallback = void Function(String message);

class NexoAuthInterceptor extends Interceptor {
  static const String skipAuthKey = 'skipAuth';
  static const String retriedKey = '_auth_retried';

  final Dio dio;
  final TokenGetter getToken;
  final TokenRefresher refreshToken;
  final TokenExpiredCallback onTokenExpired;

  final String authHeaderKey;
  final String bearerPrefix;
  final Set<int> refreshStatusCodes;

  final LoggerCallback? onLog;
  final LoggerCallback? onWarning;
  final void Function(String message, Object error, StackTrace stackTrace)?
  onErrorLog;

  Completer<String?>? _refreshCompleter;
  bool _isSessionExpired = false;

  NexoAuthInterceptor({
    required this.dio,
    required this.getToken,
    required this.refreshToken,
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

  bool _shouldRefresh(DioException err) {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[retriedKey] == true;
    final skipAuth = err.requestOptions.extra[skipAuthKey] == true;

    return statusCode != null &&
        refreshStatusCodes.contains(statusCode) &&
        !alreadyRetried &&
        !skipAuth;
  }

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

  Future<void> _handleTokenExpiredOnce() async {
    if (_isSessionExpired) return;

    _isSessionExpired = true;
    await onTokenExpired();
  }

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
