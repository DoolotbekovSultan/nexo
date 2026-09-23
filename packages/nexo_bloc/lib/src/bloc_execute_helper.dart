import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo_errors/nexo_errors.dart';

/// Преобразует ошибку [error] в [Failure].
Failure _toFailure(Object error, StackTrace stackTrace) {
  return error is Failure ? error : error.toFailure(stackTrace);
}

/// Выполняет асинхронную операцию и маппит результат в состояние.
Future<void> nexoExecute<T, S>({
  required void Function(S) emit,
  required bool isDone,
  required Future<T> Function() action,
  S Function()? onLoading,
  required S Function(T data) onSuccess,
  required S Function(Failure failure) onError,
}) async {
  if (onLoading != null && !isDone) {
    emit(onLoading());
  }

  try {
    final result = await action();
    if (!isDone) {
      emit(onSuccess(result));
    }
  } catch (e, s) {
    if (!isDone) {
      emit(onError(_toFailure(e, s)));
    }
  }
}

/// Выполняет асинхронную операцию, возвращающую [Result], и маппит результат.
Future<void> nexoExecuteEither<T, S>({
  required void Function(S) emit,
  required bool isDone,
  required Future<Result<T>> Function() action,
  S Function()? onLoading,
  required S Function(T data) onSuccess,
  required S Function(Failure failure) onError,
}) async {
  if (onLoading != null && !isDone) {
    emit(onLoading());
  }

  try {
    final result = await action();
    if (isDone) return;

    result.fold(
      onFailure: (failure) => emit(onError(failure)),
      onSuccess: (data) => emit(onSuccess(data)),
    );
  } catch (e, s) {
    if (!isDone) {
      emit(onError(_toFailure(e, s)));
    }
  }
}

/// Подписывается на [Stream] и маппит события в состояния.
///
/// Использует [Emitter.forEach] для подписки; применимо только к [Bloc].
Future<void> nexoSubscribe<T, S>({
  required Emitter<S> emit,
  required bool isDone,
  required Stream<T> Function() stream,
  S Function()? onLoading,
  required S Function(T data) onData,
  required S Function(Failure failure) onError,
}) async {
  if (onLoading != null && !isDone) {
    emit(onLoading());
  }

  try {
    await emit.forEach<T>(
      stream(),
      onData: onData,
      onError: (error, stackTrace) => onError(_toFailure(error, stackTrace)),
    );
  } catch (e, s) {
    if (!isDone) {
      emit(onError(_toFailure(e, s)));
    }
  }
}

/// Подписывается на [Stream<Result>] и маппит результаты в состояния.
///
/// Использует [Emitter.forEach] для подписки; применимо только к [Bloc].
Future<void> nexoSubscribeEither<T, S>({
  required Emitter<S> emit,
  required bool isDone,
  required Stream<Result<T>> Function() stream,
  S Function()? onLoading,
  required S Function(T data) onData,
  required S Function(Failure failure) onError,
}) async {
  if (onLoading != null && !isDone) {
    emit(onLoading());
  }

  try {
    await emit.forEach<Result<T>>(
      stream(),
      onData: (result) {
        return result.fold(
          onFailure: (failure) => onError(failure),
          onSuccess: (data) => onData(data),
        );
      },
      onError: (error, stackTrace) {
        return onError(_toFailure(error, stackTrace));
      },
    );
  } catch (e, s) {
    if (!isDone) {
      emit(onError(_toFailure(e, s)));
    }
  }
}
