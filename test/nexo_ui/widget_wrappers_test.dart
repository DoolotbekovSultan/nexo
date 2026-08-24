import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_ui.dart';

Widget wrap(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  testWidgets('pad оборачивает в Padding со всеми сторонами', (tester) async {
    await tester.pumpWidget(wrap(const Text('a').pad(10)));

    final padding = tester.widget<Padding>(find.byType(Padding));
    expect(padding.padding, EdgeInsets.all(10));
    expect(find.text('a'), findsOneWidget);
  });

  testWidgets('padSymmetric и padOnly задают точечные отступы', (tester) async {
    await tester.pumpWidget(
      wrap(
        Column(children: [Text('s').padSymmetric(horizontal: 4, vertical: 2)]),
      ),
    );
    expect(
      tester.widget<Padding>(find.byType(Padding)).padding,
      EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );

    await tester.pumpWidget(
      wrap(Column(children: [Text('o').padOnly(left: 8, bottom: 3)])),
    );
    expect(
      tester.widget<Padding>(find.byType(Padding)).padding,
      EdgeInsets.only(left: 8, bottom: 3),
    );
  });

  testWidgets('center и align оборачивают в Center/Align', (tester) async {
    await tester.pumpWidget(wrap(const Text('c').center()));
    expect(find.byType(Center), findsOneWidget);

    await tester.pumpWidget(wrap(const Text('a').align(Alignment.centerRight)));
    expect(
      tester.widget<Align>(find.byType(Align)).alignment,
      Alignment.centerRight,
    );
  });

  testWidgets('expanded и flexible работают внутри Row', (tester) async {
    await tester.pumpWidget(
      wrap(Row(children: [const Text('e').expanded(), const Text('b')])),
    );
    expect(tester.widget<Expanded>(find.byType(Expanded)).flex, 1);

    await tester.pumpWidget(
      wrap(
        Row(
          children: [
            const Text('f').expanded(flex: 2),
            const Text('g').flexible(flex: 3),
          ],
        ),
      ),
    );
    expect(tester.widget<Expanded>(find.byType(Expanded)).flex, 2);
    expect(tester.widget<Flexible>(find.byType(Flexible)).flex, 3);
  });

  testWidgets('sized, aspectRatio, opacity, safeArea, clipRRect, decorated', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const Text('x').sized(width: 100, height: 50)),
    );
    final sized = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(sized.width, 100);
    expect(sized.height, 50);

    await tester.pumpWidget(wrap(const Text('x').aspectRatio(2)));
    expect(tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio, 2);

    await tester.pumpWidget(wrap(const Text('x').opacity(0.4)));
    expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.4);

    await tester.pumpWidget(wrap(const Text('x').safeArea()));
    expect(find.byType(SafeArea), findsOneWidget);

    await tester.pumpWidget(wrap(const Text('x').clipRRect(6)));
    expect(
      (tester.widget<ClipRRect>(find.byType(ClipRRect)).borderRadius
              as BorderRadius)
          .topLeft,
      Radius.circular(6),
    );

    await tester.pumpWidget(
      wrap(Text('x').decorated(const BoxDecoration(color: Colors.red))),
    );
    expect(
      tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration,
      isA<BoxDecoration>().having((d) => d.color, 'color', Colors.red),
    );
  });

  testWidgets('onTap обрабатывает нажатие', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(Text('tap me').onTap(() => tapped = true)));

    await tester.tap(find.text('tap me'));
    expect(tapped, isTrue);
  });

  testWidgets('цепочка обёрток применяется последовательно', (tester) async {
    await tester.pumpWidget(wrap(const Text('chain').pad(8).center()));

    expect(find.byType(Padding), findsOneWidget);
    expect(
      find.ancestor(of: find.byType(Padding), matching: find.byType(Center)),
      findsOneWidget,
    );
  });
}
