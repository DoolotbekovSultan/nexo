import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

import 'bloc_execute_helper.dart';
import 'failure_support.dart';
import 'subscription_mixin.dart';

/// Абстрактный базовый класс Cubit с поддержкой обработки ошибок и управлением подписками.
///
/// Наследует [Cubit] и миксины [FailureSupport] и [SubscriptionMixin].
/// Предоставляет вспомогательные методы для выполнения асинхронных операций
/// с маппингом состояний и автоматическим управлением подписками на потоки.
///
/// ## Пример использования
///
/// ```dart
/// class CounterCubit extends NexoCubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
///
///   void fetchAndIncrement(int userId) async {
///     await executeEither(
///       action: () => useCase(userId),
///       onLoading: () => state,
///       onSuccess: (data) => data,
///       onError: (failure) => state,
///     );
///   }
/// }
/// ```
///
/// См. также: [NexoBloc], [FailureSupport], [SubscriptionMixin].
abstract class NexoCubit<S> extends Cubit<S>
    with FailureSupport, SubscriptionMixin {
  /// Создаёт экземпляр [NexoCubit] с начальным состоянием [initialState].
  NexoCubit(super.initialState);

  /// Выполняет асинхронную операцию и маппит результат в состояние Cubit.
  Future<void> execute<T>({
    required Future<T> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
  }) => nexoExecute(
    emit: emit,
    isDone: isClosed,
    action: action,
    onLoading: onLoading,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Выполняет асинхронную операцию, возвращающую [Result], и маппит результат.
  Future<void> executeEither<T>({
    required Future<Result<T>> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
  }) => nexoExecuteEither(
    emit: emit,
    isDone: isClosed,
    action: action,
    onLoading: onLoading,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Подписывается на [Stream] с управлением подписками через [SubscriptionMixin].
  Future<void> subscribe<T>({
    required Object subscriptionKey,
    required Stream<T> Function() stream,
    S Function()? onLoading,
    required S Function(T data) onData,
    required S Function(Failure failure) onError,
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

  /// Подписывается на [Stream<Result>] с управлением подписками.
  Future<void> subscribeEither<T>({
    required Object subscriptionKey,
    required Stream<Result<T>> Function() stream,
    S Function()? onLoading,
    required S Function(T data) onData,
    required S Function(Failure failure) onError,
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
            onFailure: (failure) => emit(onError(failure)),
            onSuccess: (data) => emit(onData(data)),
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

  /// Закрывает Cubit и отменяет все активные подписки.
  @override
  Future<void> close() async {
    await cancelSubscriptions();
    return super.close();
  }
}
