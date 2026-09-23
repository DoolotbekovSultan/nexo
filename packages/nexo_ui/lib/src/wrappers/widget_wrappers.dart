import 'package:flutter/widgets.dart';

/// Цепочки обёрток над виджетами.
///
/// Пример:
/// ```dart
/// Text('Привет').pad(16).center()
/// ```
extension NexoWidgetX on Widget {
  /// Оборачивает в [Padding] со всеми сторонами [all].
  Widget pad(double all) => Padding(padding: EdgeInsets.all(all), child: this);

  /// Симметричные отступы по горизонтали и вертикали.
  Widget padSymmetric({double horizontal = 0, double vertical = 0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  /// Отступы по отдельным сторонам (нулевые по умолчанию).
  Widget padOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );

  /// Центрирует виджет.
  Widget center() => Center(child: this);

  /// Выравнивает виджет внутри родителя.
  Widget align(AlignmentGeometry alignment) =>
      Align(alignment: alignment, child: this);

  /// Растягивает внутри [Row]/[Column]; требует предка [Flex].
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Гибкое место внутри [Row]/[Column]; требует предка [Flex].
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);

  /// Фиксированный размер.
  Widget sized({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);

  /// Соотношение сторон.
  Widget aspectRatio(double aspectRatio) =>
      AspectRatio(aspectRatio: aspectRatio, child: this);

  /// Полупрозрачность.
  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Отступ от системных элементов экрана (чёлка, системные жесты).
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) =>
      SafeArea(top: top, bottom: bottom, left: left, right: right, child: this);

  /// Скруглённая обрезка с радиусом [radius].
  Widget clipRRect(double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);

  /// Произвольный декор (фон, градиент, рамка, тень) под содержимым.
  Widget decorated(Decoration decoration) =>
      DecoratedBox(decoration: decoration, child: this);

  /// Обработка тапа; [behavior] управляет областью приёма касаний.
  Widget onTap(
    VoidCallback? onTap, {
    HitTestBehavior behavior = HitTestBehavior.opaque,
  }) => GestureDetector(onTap: onTap, behavior: behavior, child: this);
}
