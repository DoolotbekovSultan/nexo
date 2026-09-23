import 'package:flutter/material.dart';
import 'package:nexo_errors/nexo_errors.dart';

/// Готовый виджет ошибки для [Failure]: иконка, сообщение и кнопка «Повторить».
///
/// Сообщение берётся из [Failure.userMessage], поэтому локализуется так же,
/// как и весь пакет (каталог сообщений / [FailurePresenter]).
///
/// ```dart
/// NexoFailureView(
///   failure: failure,
///   onRetry: () => context.read<ProfileBloc>().add(const ProfileStarted()),
/// )
/// ```
class NexoFailureView extends StatelessWidget {
  const NexoFailureView({
    super.key,
    required this.failure,
    this.onRetry,
    this.retryLabel = 'Повторить',
    this.showTechnicalCode = false,
    this.icon,
    this.padding = const EdgeInsets.all(24),
  });

  /// Ошибка для отображения.
  final Failure failure;

  /// Колбэк повтора; `null` скрывает кнопку.
  final VoidCallback? onRetry;

  /// Текст кнопки повтора.
  final String retryLabel;

  /// Показывать стабильный код ошибки ([Failure.code]) под сообщением.
  final bool showTechnicalCode;

  /// Иконка вместо стандартной [Icons.error_outline].
  final IconData? icon;

  /// Внутренние отступы.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            failure.userMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          if (showTechnicalCode) ...[
            const SizedBox(height: 8),
            Text(
              failure.code,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ],
      ),
    );
  }
}
