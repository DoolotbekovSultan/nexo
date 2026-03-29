import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';

import 'failure_support.dart';
import 'subscription_mixin.dart';

abstract class BaseCubit<State> extends Cubit<State>
    with FailureSupport, SubscriptionMixin {
  BaseCubit(super.initialState);

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

  Future<void> subscribe<T>({
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
      await cancelSubscriptions();
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

      trackSubscription(subscription);
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
