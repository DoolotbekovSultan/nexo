import 'dart:async';
import 'dart:math';

import 'package:nexo/packages/nexo_core/usecase/nexo_usecase.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

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
      if (last.isRight()) return last;

      final failure = last.fold<Failure>(
        (l) => l,
        (_) => throw StateError('expected Left'),
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
