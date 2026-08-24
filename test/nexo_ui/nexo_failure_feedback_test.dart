import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  const failure = Failure.network(type: NetworkFailure.noInternet);

  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return captured;
  }

  group('showFailureSnackBar', () {
    testWidgets('показывает userMessage', (tester) async {
      final context = await pumpHost(tester);

      showFailureSnackBar(context, failure);
      await tester.pumpAndSettle();

      expect(find.text('Нет подключения к интернету'), findsOneWidget);
    });

    testWidgets('action срабатывает и заменяет предыдущий снекбар', (
      tester,
    ) async {
      final context = await pumpHost(tester);
      var taps = 0;

      showFailureSnackBar(context, failure);
      await tester.pumpAndSettle();

      showFailureSnackBar(
        context,
        failure,
        actionLabel: 'Повторить',
        onAction: () => taps++,
      );
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);

      await tester.tap(find.text('Повторить'));
      await tester.pump();

      expect(taps, 1);
    });
  });

  group('showFailureDialog', () {
    testWidgets('показывает заголовок категории и текст ошибки', (
      tester,
    ) async {
      final context = await pumpHost(tester);

      showFailureDialog(context, failure);
      await tester.pumpAndSettle();

      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Нет подключения к интернету'), findsOneWidget);
    });

    testWidgets('кнопка повтора закрывает диалог и вызывает колбэк', (
      tester,
    ) async {
      final context = await pumpHost(tester);
      var retries = 0;

      showFailureDialog(context, failure, onRetry: () => retries++);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Повторить'));
      await tester.pumpAndSettle();

      expect(retries, 1);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('кнопка закрытия просто закрывает диалог', (tester) async {
      final context = await pumpHost(tester);

      showFailureDialog(context, failure, onRetry: () {});
      await tester.pumpAndSettle();

      await tester.tap(find.text('Понятно'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
