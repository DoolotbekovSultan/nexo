import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  testWidgets('рендерит ребёнка с отступами по умолчанию', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: const NexoCard(child: Text('content')),
      ),
    );

    expect(find.text('content'), findsOneWidget);
    final padding = tester.widget<Padding>(find.byType(Padding));
    expect(padding.padding, const EdgeInsets.all(16));
  });

  testWidgets('onTap обрабатывает нажатие', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NexoCard(onTap: () => tapped = true, child: const Text('tap')),
      ),
    );

    await tester.tap(find.text('tap'));
    expect(tapped, isTrue);
  });

  testWidgets('параметры пробрасываются в Material', (tester) async {
    const color = Color(0xFF112233);
    const radius = BorderRadius.all(Radius.circular(20));
    const side = BorderSide(color: Colors.black);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NexoCard(
          color: color,
          borderRadius: radius,
          side: side,
          elevation: 4,
          margin: const EdgeInsets.all(8),
          child: const Text('styled'),
        ),
      ),
    );

    final material = tester.widget<Material>(find.byType(Material));
    expect(material.color, color);
    expect(material.elevation, 4);
    final shape = material.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, radius);
    expect(shape.side, side);

    expect(
      find.ancestor(of: find.text('styled'), matching: find.byType(Padding)),
      findsAtLeast(2),
    );
  });
}
