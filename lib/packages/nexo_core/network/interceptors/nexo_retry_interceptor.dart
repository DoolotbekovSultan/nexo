import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import 'clone_request_options.dart';

/// Функция определения условия повторной попытки.
///
/// Принимает [error] и номер попытки [retryAttempt] (начиная с 1).
/// Возвращает `true`, если запрос следует повторить.
typedef RetryCondition = bool Function(DioException error, int retryAttempt);

/// Функция расчёта задержки между попытками.
///
/// Принимает номер попытки [retryAttempt] (начиная с 1).
/// Возвращает [Duration] до следующей попытки.
typedef RetryDelayCalculator = Duration Function(int retryAttempt);

/// Интерсептор для автоматических повторных попыток при ошибках сети.
///
/// Поддерживает экспоненциальную задержку с джиттером, настраиваемые
/// условия повтора и лимит попыток.
///
/// ## Алгоритм
///
/// 1. При ошибке проверяет условия повтора (тип ошибки, код статуса, метод).
/// 2. Вычисляет задержку: `baseDelay * backoffMultiplier^(attempt-1) + jitter`.
/// 3. Ограничивает задержку значением [maxDelay].
/// 4. Повторяет запрос до достижения [maxRetries] или успешного ответа.
///
/// ## Пример использования
///
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(
///   NexoRetryInterceptor(
///     dio: dio,
///     maxRetries: 3,
///     baseDelay: Duration(milliseconds: 500),
///     backoffMultiplier: 2.0,
///     onRetry: (attempt, delay, error) {
///       log('Retry $attempt after ${delay.inMilliseconds}ms');
///     },
///   ),
/// );
/// ```
///
/// См. также: [NexoAuthInterceptor], [NexoLoggingInterceptor].
class NexoRetryInterceptor extends Interceptor {
  /// Ключ в [RequestOptions.extra] для пропуска повторных попыток.
  static const String skipRetryKey = '_nexo_skip_retry';

  /// Ключ в [RequestOptions.extra] для хранения количества попыток.
  static const String retryAttemptsKey = '_nexo_retry_attempts';

  final Dio dio;

  /// Максимальное количество повторных попыток. По умолчанию: 3.
  final int maxRetries;

  /// Базовая задержка перед первой повторной попыткой.
  /// По умолчанию: 500мс.
  final Duration baseDelay;

  /// Множитель экспоненциальной задержки. По умолчанию: 2.0.
  final double backoffMultiplier;

  /// Максимальная задержка между попытками. По умолчанию: 10с.
  final Duration maxDelay;

  /// Фактор джиттера (0.0 - 1.0). По умолчанию: 0.2.
  final double jitterFactor;

  /// Типы ошибок Dio, при которых выполняется повтор.
  /// По умолчанию: connectionTimeout, sendTimeout, receiveTimeout, connectionError.
  final Set<DioExceptionType> retryableErrorTypes;

  /// Коды статуса, при которых выполняется повтор.
  /// По умолчанию: 408, 429, 500, 502, 503, 504.
  final Set<int> retryableStatusCodes;

  /// HTTP-методы, для которых выполняется повтор.
  /// По умолчанию: GET, HEAD, DELETE, OPTIONS.
  final Set<String> retryableMethods;

  /// Пользовательское условие повтора (опционально).
  final RetryCondition? customRetryCondition;

  /// Пользовательский калькулятор задержки (опционально).
  final RetryDelayCalculator? customDelayCalculator;

  /// Callback, вызываемый перед каждой повторной попыткой.
  final void Function(int retryAttempt, Duration delay, DioException error)?
  onRetry;

  /// Callback, вызываемый при исчерпании попыток.
  final void Function(int retryAttempts, DioException error)? onRetryFailed;

  /// Создаёт экземпляр [NexoRetryInterceptor].
  ///
  /// [dio] — экземпляр Dio для повторных запросов.
  /// [maxRetries] — максимум попыток. По умолчанию: 3.
  /// [baseDelay] — базовая задержка. По умолчанию: 500мс.
  /// [backoffMultiplier] — множитель задержки. По умолчанию: 2.0.
  /// [maxDelay] — макс. задержка. По умолчанию: 10с.
  /// [jitterFactor] — фактор джиттера (0.0–1.0). По умолчанию: 0.2.
  /// [retryableErrorTypes] — типы ошибок для повтора.
  /// [retryableStatusCodes] — коды статуса для повтора.
  /// [retryableMethods] — методы для повтора.
  /// [customRetryCondition] — пользовательское условие повтора (опционально).
  /// [customDelayCalculator] — кастомный калькулятор задержки (опционально).
  /// [onRetry] — callback перед каждой попыткой (опционально).
  /// [onRetryFailed] — callback при исчерпании попыток (опционально).
  const NexoRetryInterceptor({
    /// Экземпляр Dio для выполнения повторных запросов.
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
    return dio.requestUri<dynamic>(
      options.uri,
      data: options.data,
      options: cloneRequestOptions(options),
      cancelToken: options.cancelToken,
      onReceiveProgress: options.onReceiveProgress,
      onSendProgress: options.onSendProgress,
    );
  }

  void _clearRetryState(RequestOptions options) {
    options.extra.remove(retryAttemptsKey);
  }
}
