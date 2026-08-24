import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  testWidgets('NexoSkeletonLoader анимируется и держит размеры', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: NexoSkeletonLoader(width: 120, height: 24)),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(NexoSkeletonLoader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('NexoSkeletonList рисует itemCount элементов', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: NexoSkeletonList(itemCount: 5))),
    );

    expect(find.byType(NexoSkeletonLoader), findsNWidgets(5));
  });
}
