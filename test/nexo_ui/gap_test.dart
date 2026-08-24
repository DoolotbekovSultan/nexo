import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  testWidgets('gapH и gapW создают SizedBox с заданными размерами', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Column(children: [8.gapH, 12.gapW])),
      ),
    );

    final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();

    expect(
      boxes.any((b) => b.height == 8),
      isTrue,
      reason: '8.gapH должен дать высоту 8',
    );
    expect(
      boxes.any((b) => b.width == 12),
      isTrue,
      reason: '12.gapW должен дать ширину 12',
    );
  });
}
