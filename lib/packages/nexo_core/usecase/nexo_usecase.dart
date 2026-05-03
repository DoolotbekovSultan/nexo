import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';
import 'package:nexo/packages/nexo_errors/result.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

abstract class NexoUseCase<T, Params> {
  final NexoLogger _logger;
  const NexoUseCase(this._logger);

  Future<T> execute(Params params);

  Future<Result<T>> call(Params params) async {
    _logger.debug('UseCase started: $runtimeType');

    try {
      final result = await execute(params);
      _logger.debug('UseCase succeeded: $runtimeType');
      return Right(result);
    } catch (e, s) {
      final failure = e is Failure ? e : e.toFailure(s);
      _logger.error(
        message:
            'UseCase failed: $runtimeType, code: ${failure.code}, message: ${failure.userMessage}',
        error: e,
        stackTrace: s,
      );
      return Left(failure);
    } finally {
      _logger.debug('UseCase finished: $runtimeType');
    }
  }
}
