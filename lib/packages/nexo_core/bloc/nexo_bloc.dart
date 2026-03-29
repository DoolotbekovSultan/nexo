import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';

import 'failure_support.dart';

abstract class NexoBloc<Event, State> extends Bloc<Event, State>
    with FailureSupport {
  NexoBloc(super.initialState);

  Future<void> execute<T>({
    required Emitter<State> emit,
    required Future<T> Function() action,
    State Function()? onLoading,
    required State Function(T data) onSuccess,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !emit.isDone) {
      emit(onLoading());
    }

    try {
      final result = await action();
      if (!emit.isDone) {
        emit(onSuccess(result));
      }
    } catch (e, s) {
      if (!emit.isDone) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  Future<void> executeEither<T>({
    required Emitter<State> emit,
    required Future<Either<Failure, T>> Function() action,
    State Function()? onLoading,
    required State Function(T data) onSuccess,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !emit.isDone) {
      emit(onLoading());
    }

    try {
      final result = await action();

      if (emit.isDone) return;

      result.fold(
        (failure) => emit(onError(failure)),
        (data) => emit(onSuccess(data)),
      );
    } catch (e, s) {
      if (!emit.isDone) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  Future<void> subscribe<T>({
    required Emitter<State> emit,
    required Stream<T> Function() stream,
    State Function()? onLoading,
    required State Function(T data) onData,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !emit.isDone) {
      emit(onLoading());
    }

    try {
      await emit.forEach<T>(
        stream(),
        onData: onData,
        onError: (error, stackTrace) => onError(toFailure(error, stackTrace)),
      );
    } catch (e, s) {
      if (!emit.isDone) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  Future<void> subscribeEither<T>({
    required Emitter<State> emit,
    required Stream<Either<Failure, T>> Function() stream,
    State Function()? onLoading,
    required State Function(T data) onData,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !emit.isDone) {
      emit(onLoading());
    }

    try {
      await emit.forEach<Either<Failure, T>>(
        stream(),
        onData: (result) {
          return result.fold(
            (failure) => onError(failure),
            (data) => onData(data),
          );
        },
        onError: (error, stackTrace) {
          return onError(toFailure(error, stackTrace));
        },
      );
    } catch (e, s) {
      if (!emit.isDone) {
        emit(onError(toFailure(e, s)));
      }
    }
  }
}
