import 'package:flutter/widgets.dart';

/// Строка как текст: `'Готово'.text(maxLines: 1)`.
extension NexoTextX on String {
  /// Создаёт [Text] из строки-приёмника.
  Text text({
    TextStyle? style,
    TextAlign? textAlign,
    bool? softWrap,
    TextOverflow? overflow,
    int? maxLines,
    TextScaler? textScaler,
    String? semanticsLabel,
  }) => Text(
    this,
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    overflow: overflow,
    maxLines: maxLines,
    textScaler: textScaler,
    semanticsLabel: semanticsLabel,
  );
}
