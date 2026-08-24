import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  Widget host(Failure failure, {VoidCallback? onRetry}) => MaterialApp(
    home: Scaffold(
      body: NexoFailureView(failure: failure, onRetry: onRetry),
    ),
  );

  testWidgets('показывает userMessage ошибки', (tester) async {
    await tester.pumpWidget(
      host(const Failure.network(type: NetworkFailure.noInternet)),
    );

    expect(find.text('Нет подключения к интернету'), findsOneWidget);
  });

  testWidgets('кнопка повтора скрыта без onRetry', (tester) async {
    await tester.pumpWidget(
      host(const Failure.network(type: NetworkFailure.noInternet)),
    );

    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('onRetry показывает кнопку и обрабатывает нажатие', (
    tester,
  ) async {
    var retries = 0;

    await tester.pumpWidget(
      host(
        const Failure.network(type: NetworkFailure.timeout),
        onRetry: () => retries++,
      ),
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(retries, 1);
  });

  testWidgets('showTechnicalCode выводит стабильный код', (tester) async {
    final failure = const Failure.network(type: NetworkFailure.noInternet);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NexoFailureView(failure: failure, showTechnicalCode: true),
        ),
      ),
    );

    expect(find.text(failure.code), findsOneWidget);
  });

  testWidgets('кастомная иконка переопределяет стандартную', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NexoFailureView(
            failure: const Failure.unknown(),
            icon: Icons.wifi_off,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });
}
