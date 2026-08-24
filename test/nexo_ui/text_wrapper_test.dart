import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  testWidgets('text создаёт Text с параметрами', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: 'привет'.text(
            style: const TextStyle(fontSize: 20),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('привет'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.style?.fontSize, 20);
  });
}
