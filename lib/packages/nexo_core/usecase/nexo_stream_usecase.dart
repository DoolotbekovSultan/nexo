import 'dart:async';

import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';
import 'package:nexo/packages/nexo_errors/result.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

abstract class NexoStreamUseCase<T, Params> {
  final NexoLogger _logger;

  const NexoStreamUseCase(this._logger);

  Stream<T> build(Params params);

  Stream<Result<T>> call(Params params) async* {
    _logger.debug('StreamUseCase started: $runtimeType');

    try {
      await for (final value in build(params)) {
        yield Right(value);
      }

      _logger.debug('StreamUseCase completed: $runtimeType');
    } catch (e, s) {
      final failure = e is Failure ? e : e.toFailure(s);

      _logger.error(
        message:
            'StreamUseCase failed: $runtimeType, code: ${failure.code}, message: ${failure.userMessage}',
        error: e,
        stackTrace: s,
      );

      yield Left(failure);
    } finally {
      _logger.debug('StreamUseCase finished: $runtimeType');
    }
  }
}
