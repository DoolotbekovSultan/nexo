import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

typedef RetryCondition = bool Function(DioException error, int retryAttempt);
typedef RetryDelayCalculator = Duration Function(int retryAttempt);

class NexoRetryInterceptor extends Interceptor {
  static const String skipRetryKey = '_nexo_skip_retry';
  static const String retryAttemptsKey = '_nexo_retry_attempts';

  final Dio dio;

  final int maxRetries;

  final Duration baseDelay;
  final double backoffMultiplier;
  final Duration maxDelay;
  final double jitterFactor;

  final Set<DioExceptionType> retryableErrorTypes;
  final Set<int> retryableStatusCodes;
  final Set<String> retryableMethods;

  final RetryCondition? customRetryCondition;
  final RetryDelayCalculator? customDelayCalculator;

  final void Function(int retryAttempt, Duration delay, DioException error)?
  onRetry;
  final void Function(int retryAttempts, DioException error)? onRetryFailed;

  const NexoRetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
    this.jitterFactor = 0.2,
    this.retryableErrorTypes = const {
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    },
    this.retryableStatusCodes = const {408, 429, 500, 502, 503, 504},
    this.retryableMethods = const {'GET', 'HEAD', 'DELETE', 'OPTIONS'},
    this.customRetryCondition,
    this.customDelayCalculator,
    this.onRetry,
    this.onRetryFailed,
  }) : assert(maxRetries >= 0),
       assert(backoffMultiplier >= 1),
       assert(jitterFactor >= 0 && jitterFactor <= 1);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    var currentError = err;
    final options = err.requestOptions;

    while (true) {
      if (_shouldSkipRetry(options)) {
        handler.next(currentError);
        return;
      }

      if (options.cancelToken?.isCancelled == true) {
        handler.next(currentError);
        return;
      }

      final attempts = _getRetryAttempts(options);

      if (!_shouldRetry(currentError, attempts)) {
        if (attempts >= maxRetries) {
          onRetryFailed?.call(attempts, currentError);
        }

        handler.next(currentError);
        return;
      }

      final nextAttempt = attempts + 1;
      options.extra[retryAttemptsKey] = nextAttempt;

      final delay = _calculateDelay(nextAttempt);
      onRetry?.call(nextAttempt, delay, currentError);

      await Future.delayed(delay);

      if (options.cancelToken?.isCancelled == true) {
        handler.next(currentError);
        return;
      }

      try {
        final response = await _retry(options);
        _clearRetryState(options);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        currentError = e;
      } catch (e, st) {
        currentError = DioException(
          requestOptions: options,
          error: e,
          stackTrace: st,
          type: DioExceptionType.unknown,
        );
      }
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _clearRetryState(response.requestOptions);
    handler.next(response);
  }

  bool _shouldSkipRetry(RequestOptions options) {
    return options.extra[skipRetryKey] == true;
  }

  int _getRetryAttempts(RequestOptions options) {
    return (options.extra[retryAttemptsKey] as int?) ?? 0;
  }

  bool _shouldRetry(DioException error, int attempts) {
    if (attempts >= maxRetries) return false;

    final method = error.requestOptions.method.toUpperCase();
    if (!retryableMethods.contains(method)) return false;

    if (customRetryCondition != null) {
      return customRetryCondition!(error, attempts + 1);
    }

    if (retryableErrorTypes.contains(error.type)) {
      return true;
    }

    final statusCode = error.response?.statusCode;
    return statusCode != null && retryableStatusCodes.contains(statusCode);
  }

  Duration _calculateDelay(int retryAttempt) {
    final customDelay = customDelayCalculator?.call(retryAttempt);

    if (customDelay != null) {
      return _capDelay(customDelay);
    }

    final exponentialMs =
        baseDelay.inMilliseconds * pow(backoffMultiplier, retryAttempt - 1);

    final cappedMs = min(exponentialMs, maxDelay.inMilliseconds.toDouble());

    final jitterRange = cappedMs * jitterFactor;
    final jitter = jitterRange == 0
        ? 0
        : Random().nextDouble() * jitterRange * 2 - jitterRange;

    final finalMs = max(0, cappedMs + jitter).round();

    return Duration(milliseconds: finalMs);
  }

  Duration _capDelay(Duration delay) {
    if (delay > maxDelay) return maxDelay;
    if (delay.isNegative) return Duration.zero;
    return delay;
  }

  Future<Response<dynamic>> _retry(RequestOptions options) {
    final headers = Map<String, dynamic>.from(options.headers);
    final extra = Map<String, dynamic>.from(options.extra);

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

  void _clearRetryState(RequestOptions options) {
    options.extra.remove(retryAttemptsKey);
  }
}
