import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';

class OptimisticUpdateResult<TState> {
  final TState state;
  final Failure? failure;

  const OptimisticUpdateResult({required this.state, this.failure});
}

Future<OptimisticUpdateResult<TState>> performOptimistic<TState, TResult>({
  required TState optimisticState,
  required TState rollbackState,
  required Future<TResult> Function() action,
  required TState Function(TResult result) onSuccess,
}) async {
  try {
    final result = await action();
    return OptimisticUpdateResult<TState>(state: onSuccess(result));
  } catch (e, s) {
    return OptimisticUpdateResult<TState>(
      state: rollbackState,
      failure: e is Failure ? e : e.toFailure(s),
    );
  }
}
