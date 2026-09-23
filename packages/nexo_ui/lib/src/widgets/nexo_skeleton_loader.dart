import 'package:flutter/material.dart';

/// Пульсирующая заглушка под элемент интерфейса во время загрузки.
///
/// ```dart
/// NexoSkeletonLoader(width: 120, height: 16)
/// ```
class NexoSkeletonLoader extends StatefulWidget {
  const NexoSkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  /// Ширина; `null` — растягивается по родителю.
  final double? width;

  /// Высота заглушки.
  final double height;

  /// Радиус скругления.
  final double borderRadius;

  @override
  State<NexoSkeletonLoader> createState() => _NexoSkeletonLoaderState();
}

class _NexoSkeletonLoaderState extends State<NexoSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.35,
    end: 1,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Вертикальный список скелетонов — типовая заглушка экрана списка.
///
/// ```dart
/// NexoSkeletonList(itemCount: 5, itemHeight: 64)
/// ```
class NexoSkeletonList extends StatelessWidget {
  const NexoSkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 64,
    this.spacing = 12,
    this.padding = const EdgeInsets.all(16),
  });

  /// Количество элементов-заглушек.
  final int itemCount;

  /// Высота одного элемента.
  final double itemHeight;

  /// Отступ между элементами.
  final double spacing;

  /// Внешние отступы.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(itemCount, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == itemCount - 1 ? 0 : spacing,
            ),
            child: NexoSkeletonLoader(height: itemHeight),
          );
        }),
      ),
    );
  }
}
