import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

import 'failure_support.dart';

/// Абстрактный базовый класс BLoC с поддержкой обработки ошибок и [Result].
///
/// Наследует [Bloc] и миксин [FailureSupport] для единообразной обработки
/// ошибок через [Failure]. Предоставляет вспомогательные методы для выполнения
/// асинхронных операций с маппингом состояний: загрузка, успех, ошибка.
///
/// ## Пример использования
///
/// ```dart
/// class UserProfileBloc extends NexoBloc<UserProfileEvent, UserProfileState> {
///   UserProfileBloc() : super(const UserProfileState.initial());
///
///   @override
///   Future<void> onFetchProfile(FetchProfileEvent event, Emitter<UserProfileState> emit) async {
///     await executeEither(
///       emit: emit,
///       onLoading: () => const UserProfileState.loading(),
///       action: () => getProfileUseCase(event.userId),
///       onSuccess: (data) => UserProfileState.loaded(data),
///       onError: (failure) => UserProfileState.error(failure),
///     );
///   }
/// }
/// ```
///
/// См. также: [NexoCubit], [FailureSupport].
abstract class NexoBloc<Event, S> extends Bloc<Event, S> with FailureSupport {
  /// Создаёт экземпляр [NexoBloc] с начальным состоянием [initialState].
  NexoBloc(super.initialState);

  /// Выполняет асинхронную операцию и маппит результат в состояние BLoC.
  ///
  /// [emit] — эмиттер состояния BLoC.
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
  ///   emit: emit,
  ///   action: () => apiClient.fetchUsers(),
  ///   onLoading: () => State.loading(),
  ///   onSuccess: (users) => State.loaded(users),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
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

  /// Выполняет асинхронную операцию, возвращающую [Result], и маппит результат.
  ///
  /// Аналогично [execute], но принимает [action], возвращающий [Result<T>].
  /// Автоматически обрабатывает [Right] как успех и [Left] как ошибку.
  ///
  /// [emit] — эмиттер состояния BLoC.
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
  ///   emit: emit,
  ///   action: () => useCase(params),
  ///   onLoading: () => State.loading(),
  ///   onSuccess: (data) => State.loaded(data),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
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
        onFailure: (failure) => emit(onError(failure)),
        onSuccess: (data) => emit(onSuccess(data)),
      );
    } catch (e, s) {
      if (!emit.isDone) {
        emit(onError(toFailure(e, s)));
      }
    }
  }

  /// Подписывается на [Stream] и маппит события в состояния BLoC.
  ///
  /// Используется для обработки потоковых данных (например, WebSocket).
  /// Подписка активна до завершения потока или ошибки.
  ///
  /// [emit] — эмиттер состояния BLoC.
  /// [stream] — функция, возвращающая подписываемый [Stream<T>].
  /// [onLoading] — опциональное состояние загрузки.
  /// [onData] — функция маппинга данных из потока в состояние.
  /// [onError] — функция маппинга ошибки из потока в состояние.
  ///
  /// **Возвращает:** [Future], который завершается после завершения потока.
  ///
  /// ## Пример
  ///
  /// ```dart
  /// await subscribe(
  ///   emit: emit,
  ///   stream: () => webSocketStream,
  ///   onData: (message) => State.messageReceived(message),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
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

  /// Подписывается на [Stream<Result>] и маппит результаты в состояния BLoC.
  ///
  /// Аналогично [subscribe], но принимает поток, эмитящий [Result<T>].
  /// Автоматически обрабатывает [Right] как данные и [Left] как ошибку.
  ///
  /// [emit] — эмиттер состояния BLoC.
  /// [stream] — функция, возвращающая подписываемый [Stream<Result<T>>].
  /// [onLoading] — опциональное состояние загрузки.
  /// [onData] — функция маппинга данных из [Result] в состояние.
  /// [onError] — функция маппинга ошибки [Failure] в состояние.
  ///
  /// **Возвращает:** [Future], который завершается после завершения потока.
  ///
  /// ## Пример
  ///
  /// ```dart
  /// await subscribeEither(
  ///   emit: emit,
  ///   stream: () => dataSource.watchData(),
  ///   onData: (data) => State.loaded(data),
  ///   onError: (failure) => State.error(failure),
  /// );
  /// ```
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
            onFailure: (failure) => onError(failure),
            onSuccess: (data) => onData(data),
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
