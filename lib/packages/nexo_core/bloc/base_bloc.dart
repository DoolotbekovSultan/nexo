import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';

import 'failure_support.dart';

abstract class BaseBloc<Event, State> extends Bloc<Event, State>
    with FailureSupport {
  BaseBloc(super.initialState);

  Future<void> execute<T>({
    required Emitter<State> emit,
    required Future<T> Function() action,
    State Function()? onLoading,
    required State Function(T data) onSuccess,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null) {
      emit(onLoading());
    }

    try {
      final result = await action();
      emit(onSuccess(result));
    } catch (e, s) {
      emit(onError(toFailure(e, s)));
    }
  }

  Future<void> subscribe<T>({
    required Emitter<State> emit,
    required Stream<T> Function() stream,
    State Function()? onLoading,
    required State Function(T data) onData,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null) {
      emit(onLoading());
    }

    await emit.forEach<T>(
      stream(),
      onData: onData,
      onError: (error, stackTrace) => onError(toFailure(error, stackTrace)),
    );
  }
}
