import 'package:flutter/material.dart';
import 'package:nexo/packages/nexo_core/state/nexo_async_state.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_ui/widgets/nexo_failure_view.dart';

/// Билдер данных внутри [NexoAsyncStateBuilder.success].
typedef NexoAsyncDataBuilder<T> = Widget Function(BuildContext context, T data);

/// Билдер ошибки внутри [NexoAsyncStateBuilder.failure].
typedef NexoAsyncFailureBuilder =
    Widget Function(BuildContext context, Failure failure);

/// Маппит [NexoAsyncState] на UI: idle / loading / success / failure.
///
/// Обязателен только [NexoAsyncStateBuilder.success]; остальные ветки имеют
/// готовые значения по умолчанию (пустой виджет, спиннер, [NexoFailureView]).
///
/// ```dart
/// NexoAsyncStateBuilder(
///   state: state,
///   success: (_, users) => UserList(users),
///   failure: (_, failure) => NexoFailureView(
///     failure: failure,
///     onRetry: () => context.read<UsersBloc>().add(const UsersStarted()),
///   ),
/// )
/// ```
class NexoAsyncStateBuilder<T> extends StatelessWidget {
  const NexoAsyncStateBuilder({
    super.key,
    required this.state,
    required this.success,
    this.idle,
    this.loading,
    this.failure,
  });

  /// Текущее состояние.
  final NexoAsyncState<T> state;

  /// Ветка с данными.
  final NexoAsyncDataBuilder<T> success;

  /// Ветка «не запущено»; по умолчанию — пустой виджет.
  final WidgetBuilder? idle;

  /// Ветка загрузки; по умолчанию — центрированный спиннер.
  final WidgetBuilder? loading;

  /// Ветка ошибки; по умолчанию — [NexoFailureView].
  final NexoAsyncFailureBuilder? failure;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      NexoAsyncIdle<T>() => idle?.call(context) ?? const SizedBox.shrink(),
      NexoAsyncLoading<T>() =>
        loading?.call(context) ??
            const Center(child: CircularProgressIndicator()),
      NexoAsyncSuccess<T>(:final data) => success(context, data),
      NexoAsyncFailure<T>(failure: final stateFailure) =>
        failure?.call(context, stateFailure) ??
            NexoFailureView(failure: stateFailure),
    };
  }
}
