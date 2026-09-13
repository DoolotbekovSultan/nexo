import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

import 'bloc_execute_helper.dart';
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
  Future<void> execute<T>({
    required Emitter<S> emit,
    required Future<T> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
  }) => nexoExecute(
    emit: emit,
    isDone: emit.isDone,
    action: action,
    onLoading: onLoading,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Выполняет асинхронную операцию, возвращающую [Result], и маппит результат.
  Future<void> executeEither<T>({
    required Emitter<S> emit,
    required Future<Result<T>> Function() action,
    S Function()? onLoading,
    required S Function(T data) onSuccess,
    required S Function(Failure failure) onError,
  }) => nexoExecuteEither(
    emit: emit,
    isDone: emit.isDone,
    action: action,
    onLoading: onLoading,
    onSuccess: onSuccess,
    onError: onError,
  );

  /// Подписывается на [Stream] и маппит события в состояния BLoC.
  Future<void> subscribe<T>({
    required Emitter<S> emit,
    required Stream<T> Function() stream,
    S Function()? onLoading,
    required S Function(T data) onData,
    required S Function(Failure failure) onError,
  }) => nexoSubscribe(
    emit: emit,
    isDone: emit.isDone,
    stream: stream,
    onLoading: onLoading,
    onData: onData,
    onError: onError,
  );

  /// Подписывается на [Stream<Result>] и маппит результаты в состояния BLoC.
  Future<void> subscribeEither<T>({
    required Emitter<S> emit,
    required Stream<Result<T>> Function() stream,
    S Function()? onLoading,
    required S Function(T data) onData,
    required S Function(Failure failure) onError,
  }) => nexoSubscribeEither(
    emit: emit,
    isDone: emit.isDone,
    stream: stream,
    onLoading: onLoading,
    onData: onData,
    onError: onError,
  );
}
