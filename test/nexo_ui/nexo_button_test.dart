import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('по умолчанию — FilledButton с текстом', (tester) async {
    await tester.pumpWidget(host(const NexoButton(label: 'Войти')));

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Войти'), findsOneWidget);
  });

  testWidgets('варианты мапятся на типы Material-кнопок', (tester) async {
    await tester.pumpWidget(
      host(
        const Column(
          children: [
            NexoButton(label: 'a', variant: NexoButtonVariant.filled),
            NexoButton(label: 'b', variant: NexoButtonVariant.outlined),
            NexoButton(label: 'c', variant: NexoButtonVariant.text),
          ],
        ),
      ),
    );

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('onPressed вызывается по тапу', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(
      host(NexoButton(label: 'OK', onPressed: () => pressed++)),
    );

    await tester.tap(find.text('OK'));
    expect(pressed, 1);
  });

  testWidgets('isLoading показывает прогресс и блокирует нажатие', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      host(
        NexoButton(
          label: 'Сохранить',
          isLoading: true,
          onPressed: () => pressed++,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);

    await tester.tap(find.text('Сохранить'), warnIfMissed: false);
    expect(pressed, 0);
  });

  testWidgets('icon отображается слева от текста', (tester) async {
    await tester.pumpWidget(
      host(const NexoButton(label: 'Add', icon: Icons.add)),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('expand растягивает кнопку на всю ширину', (tester) async {
    await tester.pumpWidget(
      host(const NexoButton(label: 'Wide', expand: true)),
    );

    final wrapper = tester.widget<SizedBox>(
      find
          .ancestor(
            of: find.byType(FilledButton),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(wrapper.width, double.infinity);
  });
}
