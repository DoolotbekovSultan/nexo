import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

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
  ///
  /// [action] — асинхронная операция, возвращающая результат типа [T].
  /// [onLoading] — опциональная функция, возвращающая состояние загрузки.
  ///   Если указана, состояние загрузки будет испущено перед выполнением [action].
  /// [onSuccess] — функция маппинга успешного результата в состояние.
  /// [onError] — функция маппинга ошибки [Failure] в состояние.
  ///
  /// **Возвращает:** [Future], который завершается после испускания конечного состояния.
  ///
  /// ## Пример
  ///
  /// ```dart
  /// await execute(
  ///   action: () => apiClient.fetchUsers(),
  ///   onLoading: () => State.loading(),
  ///   onSuccess: (users) => State.loaded(users),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
  Future<void> execute<T>({
    required Future<T> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
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

  /// Выполняет асинхронную операцию, возвращающую [Result], и маппит результат.
  ///
  /// Аналогично [execute], но принимает [action], возвращающий [Result<T>].
  /// Автоматически обрабатывает [Right] как успех и [Left] как ошибку.
  ///
  /// [action] — асинхронная операция, возвращающая [Result<T>].
  /// [onLoading] — опциональное состояние загрузки.
  /// [onSuccess] — функция маппинга успешного результата в состояние.
  /// [onError] — функция маппинга ошибки [Failure] в состояние.
  ///
  /// **Возвращает:** [Future], который завершается после испускания конечного состояния.
  ///
  /// ## Пример
  ///
  /// ```dart
  /// await executeEither(
  ///   action: () => useCase(params),
  ///   onLoading: () => State.loading(),
  ///   onSuccess: (data) => State.loaded(data),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
  Future<void> executeEither<T>({
    required Future<Result<T>> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
  }) async {
    if (onLoading != null && !isClosed) {
      emit(onLoading());
    }

    try {
      final result = await action();
      if (!isClosed) {
        result.fold(
          onFailure: (failure) => emit(onError(failure)),
          onSuccess: (data) => emit(onSuccess(data)),
        );
      }
    } catch (e, s) {
      if (!isClosed) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  /// Подписывается на [Stream] с управлением подписками через [SubscriptionMixin].
  ///
  /// Подписка автоматически отменяется при повторном вызове с тем же [subscriptionKey]
  /// (если [cancelPrevious] равен `true`). Используется для обработки потоковых данных.
  ///
  /// [subscriptionKey] — уникальный ключ подписки для идентификации и управления.
  /// [stream] — функция, возвращающая подписываемый [Stream<T>].
  /// [onLoading] — опциональное состояние загрузки.
  /// [onData] — функция маппинга данных из потока в состояние.
  /// [onError] — функция маппинга ошибки из потока в состояние.
  /// [cancelPrevious] — если `true`, предыдущая подписка с тем же ключом будет отменена.
  ///   По умолчанию: `true`.
  ///
  /// **Возвращает:** [Future], который завершается после подписки на поток.
  ///
  /// ## Пример
  ///
  /// ```dart
  /// await subscribe(
  ///   subscriptionKey: 'user_stream',
  ///   stream: () => webSocketStream,
  ///   onData: (message) => State.messageReceived(message),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
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
  ///
  /// Аналогично [subscribe], но принимает поток, эмитящий [Result<T>].
  /// Автоматически обрабатывает [Right] как данные и [Left] как ошибку.
  /// Подписка автоматически отменяется при повторном вызове с тем же ключом.
  ///
  /// [subscriptionKey] — уникальный ключ подписки.
  /// [stream] — функция, возвращающая подписываемый [Stream<Result<T>>].
  /// [onLoading] — опциональное состояние загрузки.
  /// [onData] — функция маппинга данных из [Result] в состояние.
  /// [onError] — функция маппинга ошибки [Failure] в состояние.
  /// [cancelPrevious] — если `true`, предыдущая подписка с тем же ключом будет отменена.
  ///   По умолчанию: `true`.
  ///
  /// **Возвращает:** [Future], который завершается после подписки на поток.
  ///
  /// ## Пример
  ///
  /// ```dart
  /// await subscribeEither(
  ///   subscriptionKey: 'data_stream',
  ///   stream: () => dataSource.watchData(),
  ///   onData: (data) => State.loaded(data),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
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
  ///
  /// Вызывается автоматически при уничтожении Cubit.
  /// Отменяет все подписки, управляемые через [SubscriptionMixin].
  @override
  Future<void> close() async {
    await cancelSubscriptions();
    return super.close();
  }
}
