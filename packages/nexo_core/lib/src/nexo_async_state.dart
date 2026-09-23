import 'package:nexo_errors/failure.dart';

/// Типичное состояние экрана / фичи: ожидание, загрузка, данные или [Failure].
///
/// Используется совместно с [NexoAsyncCubit] и [NexoAsyncStateBuilder]
/// для единообразного представления асинхронных состояний в UI.
///
/// См. также: [NexoAsyncCubit], [NexoAsyncStateBuilder].
sealed class NexoAsyncState<T> {
  const NexoAsyncState();

  /// `true`, если состояние — ожидание (данные ещё не запрашивались).
  bool get isIdle => this is NexoAsyncIdle<T>;

  /// `true`, если состояние — загрузка.
  bool get isLoading => this is NexoAsyncLoading<T>;

  /// `true`, если состояние — успешная загрузка данных.
  bool get isSuccess => this is NexoAsyncSuccess<T>;

  /// `true`, если состояние — ошибка.
  bool get isFailure => this is NexoAsyncFailure<T>;
}

/// Состояние ожидания: данные ещё не запрашивались.
///
/// Используется как начальное состояние по умолчанию.
final class NexoAsyncIdle<T> extends NexoAsyncState<T> {
  const NexoAsyncIdle();
}

/// Состояние загрузки: данные запрошены, но ещё не получены.
final class NexoAsyncLoading<T> extends NexoAsyncState<T> {
  const NexoAsyncLoading();
}

/// Состояние успешной загрузки: данные получены.
///
/// [data] — загруженные данные типа [T].
final class NexoAsyncSuccess<T> extends NexoAsyncState<T> {
  const NexoAsyncSuccess(this.data);

  /// Загруженные данные.
  final T data;
}

/// Состояние ошибки: загрузка завершилась неудачно.
///
/// [failure] — описание ошибки.
final class NexoAsyncFailure<T> extends NexoAsyncState<T> {
  const NexoAsyncFailure(this.failure);

  /// Описание ошибки.
  final Failure failure;
}

/// Расширение для удобного извлечения данных из [NexoAsyncState].
extension NexoAsyncStateDataX<T> on NexoAsyncState<T> {
  /// Возвращает данные, если состояние — [NexoAsyncSuccess], иначе `null`.
  T? get dataOrNull => switch (this) {
    NexoAsyncSuccess(:final data) => data,
    _ => null,
  };

  /// Возвращает ошибку, если состояние — [NexoAsyncFailure], иначе `null`.
  Failure? get failureOrNull => switch (this) {
    NexoAsyncFailure(:final failure) => failure,
    _ => null,
  };

  /// Сопоставляет состояние с четырьмя ветками.
  R map<R>({
    required R Function() onIdle,
    required R Function() onLoading,
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    NexoAsyncIdle() => onIdle(),
    NexoAsyncLoading() => onLoading(),
    NexoAsyncSuccess(:final data) => onSuccess(data),
    NexoAsyncFailure(:final failure) => onFailure(failure),
  };
}
