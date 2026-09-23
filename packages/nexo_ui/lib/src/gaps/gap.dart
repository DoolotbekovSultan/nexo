import 'package:flutter/widgets.dart';

/// Спейсеры для детей [Column], [Row] и других [Flex]-контейнеров.
///
/// Использует стандартные пиксели. Для адаптивности с рамкой дизайна под Mobile-First
/// подразумевайте настройку через свой слой проксирования, например `ScreenUtil`
/// или `ResponsiveWrapper`, прямо в проекте-приложенте — модуль не подключает
/// Flutter-полученные веса автоматически, оставляя выбор вам.
///
/// ```dart
/// Column(children: [Text('A'), 16.gapH, Text('B')])
/// ```
extension NexoGapX on num {
  /// Вертикальный спейсер высотой `this` пикселей.
  ///
  /// Базовый спейсер. Для адаптивной рамки дизайна под Mobile-First
  /// проксируйте вызов через свой механизм (например `ScreenUtil` или `ResponsiveWrapper`).
  SizedBox get gapH => SizedBox(height: toDouble());

  /// Горизонтальный спейсер шириной `this` пикселей.
  ///
  /// Аналогично `gapH`, предназначен для горизонтальных макетов.
  SizedBox get gapW => SizedBox(width: toDouble());
}
