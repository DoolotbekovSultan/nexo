import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';

/// Результат выполнения оптимистичного обновления.
///
/// Содержит либо обновлённое состояние [state], либо состояние отката
/// [rollbackState] с ошибкой [failure].
///
/// ## Пример
///
/// ```dart
/// final result = await performOptimistic(
///   optimisticState: state.copyWith(isLoading: true),
///   rollbackState: state,
///   action: () => api.likePost(postId),
///   onSuccess: (likes) => state.copyWith(likes: likes),
/// );
///
/// if (result.failure != null) {
///   showError(result.failure!.userMessage);
/// }
/// emit(result.state);
/// ```
class OptimisticUpdateResult<TState> {
  /// Результирующее состояние (успех или откат).
  final TState state;

  /// Ошибка, если произошёл откат; `null` при успешном обновлении.
  final Failure? failure;

  /// Создаёт результат оптимистичного обновления.
  const OptimisticUpdateResult({required this.state, this.failure});
}

/// Выполняет оптимистичное обновление состояния.
///
/// 1. Мгновенно применяет [optimisticState] к UI.
/// 2. Выполняет [action] в фоне.
/// 3. При успехе — обновляет состояние через [onSuccess].
/// 4. При ошибке — откатывает на [rollbackState] и возвращает [Failure].
///
/// [optimisticState] — состояние, применяемое сразу (оптимистичный апдейт).
/// [rollbackState] — состояние для отката при ошибке.
/// [action] — асинхронная операция, которая может завершиться ошибкой.
/// [onSuccess] — функция маппинга результата операции в новое состояние.
///
/// **Возвращает:** [Future] с [OptimisticUpdateResult], содержащим
/// финальное состояние и опциональную ошибку.
Future<OptimisticUpdateResult<TState>> performOptimistic<TState, TResult>({
  required TState optimisticState,
  required TState rollbackState,
  required Future<TResult> Function() action,
  required TState Function(TResult result) onSuccess,
}) async {
  try {
    final result = await action();
    return OptimisticUpdateResult<TState>(state: onSuccess(result));
  } catch (e, s) {
    return OptimisticUpdateResult<TState>(
      state: rollbackState,
      failure: e is Failure ? e : e.toFailure(s),
    );
  }
}
