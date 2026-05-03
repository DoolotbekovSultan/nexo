import 'package:nexo/packages/nexo_errors/failure.dart';

/// Типичное состояние экрана / фичи: ожидание, загрузка, данные или [Failure].
sealed class NexoAsyncState<T> {
  const NexoAsyncState();

  bool get isIdle => this is NexoAsyncIdle<T>;
  bool get isLoading => this is NexoAsyncLoading<T>;
  bool get isSuccess => this is NexoAsyncSuccess<T>;
  bool get isFailure => this is NexoAsyncFailure<T>;
}

final class NexoAsyncIdle<T> extends NexoAsyncState<T> {
  const NexoAsyncIdle();
}

final class NexoAsyncLoading<T> extends NexoAsyncState<T> {
  const NexoAsyncLoading();
}

final class NexoAsyncSuccess<T> extends NexoAsyncState<T> {
  const NexoAsyncSuccess(this.data);
  final T data;
}

final class NexoAsyncFailure<T> extends NexoAsyncState<T> {
  const NexoAsyncFailure(this.failure);
  final Failure failure;
}

extension NexoAsyncStateDataX<T> on NexoAsyncState<T> {
  T? get dataOrNull => switch (this) {
    NexoAsyncSuccess(:final data) => data,
    _ => null,
  };

  Failure? get failureOrNull => switch (this) {
    NexoAsyncFailure(:final failure) => failure,
    _ => null,
  };
}
