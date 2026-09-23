import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo_errors/nexo_errors.dart';

import 'package:nexo_bloc/src/bloc_execute_helper.dart';
import 'package:nexo_bloc/src/failure_support.dart';
import 'package:nexo_bloc/src/subscription_mixin.dart';

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

  /// Выполняет мутацию (create/update/delete) с обработкой ошибок.
  ///
  /// Принимает [Future<Result<T>>] — если результат [Right], вызывает
  /// [onSuccess] с данными; если [Left] — [onError] с ошибкой.
  ///
  /// ```dart
  /// await executeMutation(
  ///   action: () => _repository.create(_token, payload),
  ///   onSuccess: (film) {
  ///     _emitReady(feedback: AdminFeedback.success('Создано'));
  ///     load();
  ///   },
  ///   onError: (f) {
  ///     _emitReady(feedback: AdminFeedback.error(f.userMessage));
  ///   },
  /// );
  /// ```
  Future<void> executeMutation<T>({
    required Future<Result<T>> Function() action,
    required void Function(T data) onSuccess,
    required void Function(Failure failure) onError,
  }) async {
    final result = await action();
    result.fold(
      onFailure: (f) => onError(f),
      onSuccess: (data) => onSuccess(data),
    );
  }

  /// Загружает данные с автоматическим loading/success/error.
  ///
  /// Принимает [Future<Result<T>>] — маппит в состояние через [toState]
  /// (успех) или [toError] (ошибка).
  ///
  /// ```dart
  /// await loadData<HomeFeedEntity>(
  ///   action: () => _loadFilmsUseCase(const NoParams()),
  ///   toState: (data) => State.ready(data: data),
  ///   toError: (f) => State.error(failure: f),
  ///   onLoading: () => const State.loading(),
  /// );
  /// ```
  Future<void> loadData<T>({
    required Future<Result<T>> Function() action,
    required S Function(T data) toState,
    required S Function(Failure failure) toError,
    S Function()? onLoading,
  }) async {
    if (onLoading != null && !isClosed) {
      emit(onLoading());
    }
    final result = await action();
    if (isClosed) return;
    result.fold(
      onFailure: (f) => emit(toError(f)),
      onSuccess: (data) => emit(toState(data)),
    );
  }

  /// Закрывает Cubit и отменяет все активные подписки.
  @override
  Future<void> close() async {
    await cancelSubscriptions();
    return super.close();
  }
}
