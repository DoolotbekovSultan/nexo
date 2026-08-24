import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_example/main.dart';

void main() {
  testWidgets('галерея: навигация по вкладкам и базовые сценарии', (
    tester,
  ) async {
    await tester.pumpWidget(const NexoExampleApp());

    expect(find.text('nexo example'), findsOneWidget);

    await tester.tap(find.text('load()'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(find.text('Пункт 1'), findsOneWidget);

    await tester.tap(find.text('Форма'));
    await tester.pump();

    expect(find.text('Отправить'), findsOneWidget);

    await tester.tap(find.text('Ошибки'));
    await tester.pump();

    expect(find.textContaining('интернет'), findsWidgets);
    expect(find.text('SnackBar'), findsOneWidget);

    await tester.tap(find.text('Outbox'));
    await tester.pump();

    expect(find.text('В очереди: 0'), findsOneWidget);

    await tester.tap(find.text('enqueue()'));
    await tester.pump();
    await tester.pump();

    expect(find.text('В очереди: 1'), findsOneWidget);

    await tester.tap(find.text('flush()'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.textContaining('sent: 1'), findsOneWidget);
    expect(find.text('В очереди: 0'), findsOneWidget);
  });
}
