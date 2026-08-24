import 'package:flutter/material.dart';

/// Вариант отображения [NexoButton]: залитая, контурная или текстовая.
enum NexoButtonVariant { filled, outlined, text }

/// Кнопка с состоянием загрузки и опциональной иконкой.
///
/// ```dart
/// NexoButton(label: 'Войти', onPressed: () {}, isLoading: loading)
/// ```
class NexoButton extends StatelessWidget {
  const NexoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = NexoButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.expand = false,
    this.style,
  });

  /// Текст кнопки.
  final String label;

  /// Колбэк нажатия; `null` отключает кнопку.
  final VoidCallback? onPressed;

  /// Вариант отображения.
  final NexoButtonVariant variant;

  /// Показывает прогресс-индикатор и блокирует нажатия.
  final bool isLoading;

  /// Иконка слева от текста.
  final IconData? icon;

  /// Растягивает кнопку на всю ширину родителя.
  final bool expand;

  /// Переопределение стиля базовой Material-кнопки.
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading || onPressed == null
        ? null
        : onPressed;

    Widget content = Text(label);
    if (isLoading) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          content,
        ],
      );
    } else if (icon != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon), const SizedBox(width: 8), content],
      );
    }

    final Widget button = switch (variant) {
      NexoButtonVariant.filled => FilledButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: content,
      ),
      NexoButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: content,
      ),
      NexoButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: style,
        child: content,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
