import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';

import 'failure_support.dart';
import 'subscription_mixin.dart';

abstract class NexoCubit<State> extends Cubit<State>
    with FailureSupport, SubscriptionMixin {
  NexoCubit(super.initialState);

  Future<void> execute<T>({
    required Future<T> Function() action,
    State Function()? onLoading,
    required State Function(T data) onSuccess,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !isClosed) {
      emit(onLoading());
    }

    try {
      final result = await action();
      if (!isClosed) {
        emit(onSuccess(result));
      }
    } catch (e, s) {
      if (!isClosed) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  Future<void> executeEither<T>({
    required Future<Either<Failure, T>> Function() action,
    State Function()? onLoading,
    required State Function(T data) onSuccess,
    required State Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !isClosed) {
      emit(onLoading());
    }

    try {
      final result = await action();
      if (!isClosed) {
        result.fold(
          (failure) => emit(onError(failure)),
          (data) => emit(onSuccess(data)),
        );
      }
    } catch (e, s) {
      if (!isClosed) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  Future<void> subscribe<T>({
    required Object subscriptionKey,
    required Stream<T> Function() stream,
    State Function()? onLoading,
    required State Function(T data) onData,
    required State Function(Failure failure) onError,
    bool cancelPrevious = true,
  }) async {
    if (onLoading != null && !isClosed) {
      emit(onLoading());
    }

    if (cancelPrevious) {
      await cancelSubscription(subscriptionKey);
    }

    try {
      final subscription = stream().listen(
        (data) {
          if (!isClosed) {
            emit(onData(data));
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!isClosed) {
            emit(onError(toFailure(error, stackTrace)));
          }
        },
      );

      await trackSubscription(subscriptionKey, subscription);
    } catch (e, s) {
      if (!isClosed) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  Future<void> subscribeEither<T>({
    required Object subscriptionKey,
    required Stream<Either<Failure, T>> Function() stream,
    State Function()? onLoading,
    required State Function(T data) onData,
    required State Function(Failure failure) onError,
    bool cancelPrevious = true,
  }) async {
    if (onLoading != null && !isClosed) {
      emit(onLoading());
    }

    if (cancelPrevious) {
      await cancelSubscription(subscriptionKey);
    }

    try {
      final subscription = stream().listen(
        (result) {
          if (isClosed) return;

          result.fold(
            (failure) => emit(onError(failure)),
            (data) => emit(onData(data)),
          );
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!isClosed) {
            emit(onError(toFailure(error, stackTrace)));
          }
        },
      );

      await trackSubscription(subscriptionKey, subscription);
    } catch (e, s) {
      if (!isClosed) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  @override
  Future<void> close() async {
    await cancelSubscriptions();
    return super.close();
  }
}
