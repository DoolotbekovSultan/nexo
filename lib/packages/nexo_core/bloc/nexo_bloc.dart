import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

import 'failure_support.dart';

abstract class NexoBloc<Event, S> extends Bloc<Event, S> with FailureSupport {
  NexoBloc(super.initialState);

  Future<void> execute<T>({
    required Emitter<S> emit,
    required Future<T> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
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
    required Emitter<S> emit,
    required Future<Result<T>> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
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
    required Emitter<S> emit,
    required Stream<T> Function() stream,
    S Function()? onLoading,
    required S Function(T data) onData,
    required S Function(Failure failure) onError,
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
    required Emitter<S> emit,
    required Stream<Result<T>> Function() stream,
    S Function()? onLoading,
    required S Function(T data) onData,
    required S Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !emit.isDone) {
      emit(onLoading());
    }

    try {
      await emit.forEach<Result<T>>(
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
