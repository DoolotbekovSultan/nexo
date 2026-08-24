import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  Widget host({
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) => MaterialApp(
    home: Scaffold(
      body: NexoEmptyView(
        title: 'Пока ничего нет',
        subtitle: subtitle,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    ),
  );

  testWidgets('показывает заголовок и пояснение', (tester) async {
    await tester.pumpWidget(host(subtitle: 'Создайте первую запись'));

    expect(find.text('Пока ничего нет'), findsOneWidget);
    expect(find.text('Создайте первую запись'), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });

  testWidgets('без action кнопка скрыта', (tester) async {
    await tester.pumpWidget(host());

    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('action показывается и срабатывает', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      host(actionLabel: 'Создать', onAction: () => taps++),
    );

    expect(find.text('Создать'), findsOneWidget);

    await tester.tap(find.text('Создать'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('кастомная иконка переопределяет стандартную', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const Scaffold(
          body: NexoEmptyView(title: 'Пусто', icon: Icons.folder_off_outlined),
        ),
      ),
    );

    expect(find.byIcon(Icons.folder_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsNothing);
  });
}
