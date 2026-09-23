import 'package:flutter/material.dart';

/// Карточка: скруглённая панель с опциональной рамкой, тенью и нажатием.
///
/// Без [Material] предка не полагается: сама является [Material], поэтому
/// всплеск [InkWell] работает в любом приложении на Material.
class NexoCard extends StatelessWidget {
  const NexoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.side,
    this.elevation = 0,
  });

  /// Содержимое карточки.
  final Widget child;

  /// Колбэк нажатия; без него жесты не обрабатываются.
  final VoidCallback? onTap;

  /// Внутренние отступы.
  final EdgeInsetsGeometry padding;

  /// Внешний отступ вокруг карточки.
  final EdgeInsetsGeometry? margin;

  /// Цвет фона; по умолчанию прозрачный. Для видимой тени задайте непрозрачный
  /// цвет вместе с [elevation].
  final Color? color;

  /// Скругление углов.
  final BorderRadius borderRadius;

  /// Рамка вокруг карточки.
  final BorderSide? side;

  /// Тень (Material elevation).
  final double elevation;

  @override
  Widget build(BuildContext context) {
    Widget card = Material(
      color: color ?? Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: side ?? BorderSide.none,
      ),
      elevation: elevation,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );

    final EdgeInsetsGeometry? margin = this.margin;
    if (margin != null) {
      card = Padding(padding: margin, child: card);
    }
    return card;
  }
}
