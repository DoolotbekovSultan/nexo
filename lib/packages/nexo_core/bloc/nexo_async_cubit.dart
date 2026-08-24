import 'dart:async';

import 'package:nexo/packages/nexo_core/bloc/nexo_cubit.dart';
import 'package:nexo/packages/nexo_core/state/nexo_async_state.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/result.dart';

/// Готовый кубит типового экрана: источник данных [fetch] + [NexoAsyncState].
///
/// Наследуйтесь и реализуйте [fetch]; состояние отображайте через
/// [NexoAsyncStateBuilder], управление — методы [load] / [retry] / [refresh].
///
/// ```dart
/// class UsersCubit extends NexoAsyncCubit<List<User>> {
///   UsersCubit(this._getUsers);
///
///   final GetUsersUseCase _getUsers;
///
///   @override
///   Future<Result<List<User>>> fetch() => _getUsers(NoParams());
/// }
///
/// // Экран:
/// context.read<UsersCubit>().load();
/// ```
abstract class NexoAsyncCubit<T> extends NexoCubit<NexoAsyncState<T>> {
  NexoAsyncCubit() : super(const NexoAsyncIdle());

  /// Колбэк ошибки (например, для snackbar вне дерева билда).
  void Function(Failure failure)? onFailure;

  int _sequence = 0;

  /// Источник данных; вызывается [load] / [retry] / [refresh].
  Future<Result<T>> fetch();

  /// Полная загрузка: `-> Loading -> Success|Failure` из любого состояния.
  Future<void> load() => _run(showLoading: true);

  /// Повтор последней загрузки после ошибки.
  Future<void> retry() => load();

  /// Тихое обновление: без промежуточного `Loading`; при успехе данные
  /// подменяются на новые. Если данных ещё нет — работает как тихий [load].
  Future<void> refresh() => _run(showLoading: false);

  Future<void> _run({required bool showLoading}) async {
    if (isClosed) return;
    final requestId = ++_sequence;

    if (showLoading && state is! NexoAsyncLoading<T>) {
      emit(const NexoAsyncLoading());
    }

    try {
      final result = await fetch();
      if (isClosed || requestId != _sequence) return;

      switch (result) {
        case Left(:final failure):
          onFailure?.call(failure);
          emit(NexoAsyncFailure<T>(failure));
        case Right(:final value):
          emit(NexoAsyncSuccess<T>(value));
      }
    } catch (e, s) {
      if (isClosed || requestId != _sequence) return;
      emit(NexoAsyncFailure<T>(Failure.unknown(error: e, stackTrace: s)));
    }
  }
}
