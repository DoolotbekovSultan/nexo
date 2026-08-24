import 'package:flutter/material.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_presenter.dart';

/// Показывает [failure] снекбаром; текст — [FailurePresenter.snackbarMessage].
///
/// Текущий снекбар заменяется новым (`hideCurrentSnackBar`), чтобы ошибки
/// не выстраивались в очередь.
///
/// ```dart
/// onFailure: (failure) => showFailureSnackBar(
///   context,
///   failure,
///   actionLabel: 'Повторить',
///   onAction: () => cubit.retry(),
/// ),
/// ```
void showFailureSnackBar(
  BuildContext context,
  Failure failure, {
  String? actionLabel,
  VoidCallback? onAction,
  bool floating = true,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(FailurePresenter.snackbarMessage(failure)),
        behavior: floating ? SnackBarBehavior.floating : null,
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
}

/// Диалог ошибки: заголовок и текст из [FailurePresenter].
///
/// [onRetry] добавляет кнопку повтора; диалог закрывается до вызова колбэка.
///
/// ```dart
/// await showFailureDialog(context, failure, onRetry: () => cubit.retry());
/// ```
Future<void> showFailureDialog(
  BuildContext context,
  Failure failure, {
  VoidCallback? onRetry,
  String retryLabel = 'Повторить',
  String dismissLabel = 'Понятно',
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(FailurePresenter.dialogTitle(failure)),
      content: Text(FailurePresenter.dialogBody(failure)),
      actions: [
        if (onRetry != null)
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onRetry();
            },
            child: Text(retryLabel),
          ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(dismissLabel),
        ),
      ],
    ),
  );
}
