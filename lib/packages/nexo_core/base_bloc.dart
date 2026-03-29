// BASE BLOC
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Базовый класс для всех BLoC компонентов приложения.
///
/// Отвечает за:
/// - Единое логирование событий и состояний
/// - Централизованную обработку ошибок
/// - Утилиты для работы с асинхронными операциями
/// - Индикаторы загрузки
///
/// Параметры типа:
/// - [Event] - тип событий BLoC
/// - [State] - тип состояния BLoC
///
/// Пример использования:
/// ```dart
/// class UserBloc extends BaseBloc<UserEvent, UserState> {
///   UserBloc() : super(UserState.initial());
///
///   @override
///   Stream<UserState> mapEventToState(UserEvent event) async* {
///     yield* event.map(
///       loadUser: (event) => _loadUser(event.userId),
///       updateUser: (event) => _updateUser(event.user),
///     );
///   }
/// }
/// ```
abstract class BaseBloc<Event, State> extends Bloc<Event, State> {
  final NexoLogger _logger;
  String get blocName => runtimeType.toString();

  BaseBloc(super.initialState, this._logger) {
    _logger.debug(_tag('Initialized'));
  }

  @override
  void onEvent(Event event) {
    logEvent(event);
    super.onEvent(event);
  }

  @override
  void onChange(Change<State> change) {
    logState(change);
    super.onChange(change);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    handleError(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  Future<void> close() {
    _logger.debug(_tag('Closed'));
    return super.close();
  }

  /// Логирует получение события
  ///
  /// Пример использования:
  /// ```dart
  /// // Автоматически вызывается при получении события
  /// ```
  void logEvent(Event event) {
    _logger.info(_tag('Event: $event'));
  }

  /// Логирует изменение состояния
  ///
  /// Пример использования:
  /// ```dart
  /// // Автоматически вызывается при изменении состояния
  /// ```
  void logState(Change<State> change) {
    if (change.currentState == change.nextState) return;
    _logger.debug(
      _tag('State: from ${change.currentState} to ${change.nextState}'),
    );
  }

  /// Обрабатывает ошибки в BLoC
  ///
  /// Параметры:
  /// - [error] - пойманная ошибка
  /// - [stackTrace] - стек вызовов
  ///
  /// Пример использования:
  /// ```dart
  /// // Автоматически вызывается при возникновении ошибки
  /// ```
  void handleError(Object error, StackTrace stackTrace) {
    final failure = _convertToFailure(error, stackTrace);

    _logger.error(
      message: _tag('Error: ${failure.userMessage}'),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Создает поток состояния с обработкой ошибок
  ///
  /// Параметры:
  /// - [action] - асинхронное действие для выполнения
  /// - [onSuccess] - колбэк при успешном выполнении
  /// - [onError] - колбэк при ошибке
  ///
  /// Возвращает [Stream] с состояниями
  ///
  /// Пример использования:
  /// ```dart
  /// Stream<UserState> _loadUser(String userId) async* {
  ///   yield* executeWithErrorHandling(
  ///     () => userRepository.getById(userId),
  ///     onSuccess: (user) => UserState.loaded(user),
  ///     onError: (failure) => UserState.error(failure),
  ///   );
  /// }
  /// ```
  Stream<State> executeWithErrorHandling<T>(
    Future<T> Function() action, {
    required State Function(T data) onSuccess,
    required State Function(Failure failure) onError,
  }) async* {
    _logger.debug(_tag('Async action started'));

    try {
      final result = await action();

      _logger.info(_tag('Async action success: ${result.runtimeType}'));

      yield onSuccess(result);
    } catch (e, s) {
      final failure = _convertToFailure(e, s);

      _logger.error(
        message: _tag('Async action failed: ${failure.userMessage}'),
        error: e,
        stackTrace: s,
      );

      yield onError(failure);
    }
  }

  Failure _convertToFailure(Object error, StackTrace stackTrace) {
    if (error is Failure) return error;

    return Failure.unknown(message: error.toString(), stackTrace: stackTrace);
  }

  /// Обновляет состояние с индикатором загрузки
  ///
  /// Параметры:
  /// - [action] - асинхронное действие
  /// - [updateLoading] - функция обновления состояния загрузки
  ///
  /// Возвращает [Stream] с состояниями
  ///
  /// Пример использования:
  /// ```dart
  /// Stream<UserState> _loadUser(String userId) async* {
  ///   yield* withLoading(
  ///     () => userRepository.getById(userId),
  ///     updateLoading: (isLoading) => state.copyWith(isLoading: isLoading),
  ///   );
  /// }
  /// ```
  Stream<State> withLoading(
    Future<void> Function() action, {
    required State Function(bool isLoading) updateLoading,
  }) async* {
    _logger.debug(_tag('Loading started'));
    yield updateLoading(true);
    try {
      await action();
    } catch (e, s) {
      _logger.error(message: _tag('Loading failed'), error: e, stackTrace: s);
    } finally {
      _logger.debug(_tag('Loading finished'));
      yield updateLoading(false);
    }
  }

  String _tag(String message) => '[$blocName] $message';
}
