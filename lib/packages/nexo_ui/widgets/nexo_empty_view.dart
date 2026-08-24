import 'package:flutter/material.dart';

/// Экран «данных нет»: иконка, заголовок, пояснение и опциональное действие.
///
/// ```dart
/// NexoEmptyView(
///   title: 'Пока ничего нет',
///   subtitle: 'Создайте первую запись',
///   actionLabel: 'Создать',
///   onAction: () => cubit.create(),
/// )
/// ```
class NexoEmptyView extends StatelessWidget {
  const NexoEmptyView({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.all(24),
  });

  /// Заголовок.
  final String title;

  /// Пояснение под заголовком.
  final String? subtitle;

  /// Иконка сверху.
  final IconData icon;

  /// Текст кнопки действия; `null` скрывает кнопку (вместе с [onAction]).
  final String? actionLabel;

  /// Колбэк действия.
  final VoidCallback? onAction;

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
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
