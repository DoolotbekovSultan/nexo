import 'dart:async';
import 'dart:math';

import 'package:nexo_errors/nexo_errors.dart';
import 'package:nexo_usecase/nexo_usecase.dart';

extension NexoUseCaseRetryX<T, Params> on NexoUseCase<T, Params> {
  /// Повторяет [NexoUseCase.call] при [Failure.isRetryable] или по [retryIf].
  ///
  /// Задержка растёт как `baseDelay * backoffMultiplier^attempt`.
  Future<Result<T>> callWithRetry(
    Params params, {
    int maxAttempts = 3,
    Duration baseDelay = const Duration(milliseconds: 250),
    double backoffMultiplier = 2,
    bool Function(Failure failure)? retryIf,
  }) async {
    assert(maxAttempts >= 1);
    Result<T>? last;
    for (var i = 0; i < maxAttempts; i++) {
      last = await call(params);
      if (last.isSuccess) return last;

      final failure = last.fold<Failure>(
        onFailure: (f) => f,
        onSuccess: (_) => throw StateError('expected failure'),
      );
      final canRetry = retryIf?.call(failure) ?? failure.isRetryable;
      if (!canRetry || i == maxAttempts - 1) {
        return last;
      }

      final ms = (baseDelay.inMilliseconds * pow(backoffMultiplier, i)).round();
      await Future<void>.delayed(Duration(milliseconds: ms));
    }
    return last!;
  }
}
