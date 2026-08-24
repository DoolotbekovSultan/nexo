import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_ui.dart';

void main() {
  Widget host(NexoAsyncState<String> state) => MaterialApp(
    home: Scaffold(
      body: NexoAsyncStateBuilder<String>(
        state: state,
        success: (_, data) => Text('data:$data'),
      ),
    ),
  );

  group('ветки по умолчанию', () {
    testWidgets('idle — пустой виджет', (tester) async {
      await tester.pumpWidget(host(const NexoAsyncIdle()));

      expect(find.text('data:x'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('loading — центрированный спиннер', (tester) async {
      await tester.pumpWidget(host(const NexoAsyncLoading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('success — билдер с данными', (tester) async {
      await tester.pumpWidget(host(const NexoAsyncSuccess('x')));

      expect(find.text('data:x'), findsOneWidget);
    });

    testWidgets('failure — NexoFailureView по умолчанию', (tester) async {
      await tester.pumpWidget(host(const NexoAsyncFailure(Failure.unknown())));

      expect(find.byType(NexoFailureView), findsOneWidget);
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  group('кастомные ветки', () {
    testWidgets('idle и loading переопределяются', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NexoAsyncStateBuilder<String>(
              state: const NexoAsyncIdle(),
              success: (_, _) => const SizedBox.shrink(),
              idle: (_) => const Text('custom-idle'),
              loading: (_) => const Text('custom-loading'),
            ),
          ),
        ),
      );

      expect(find.text('custom-idle'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NexoAsyncStateBuilder<String>(
              state: const NexoAsyncLoading(),
              success: (_, _) => const SizedBox.shrink(),
              idle: (_) => const Text('custom-idle'),
              loading: (_) => const Text('custom-loading'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('custom-loading'), findsOneWidget);
    });

    testWidgets('failure получает Failure и колбэки работают', (tester) async {
      final failure = const Failure.network(type: NetworkFailure.noInternet);
      var retries = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NexoAsyncStateBuilder<String>(
              state: NexoAsyncFailure(failure),
              success: (_, _) => const SizedBox.shrink(),
              failure: (_, f) =>
                  NexoFailureView(failure: f, onRetry: () => retries++),
            ),
          ),
        ),
      );

      expect(retries, 0);

      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(retries, 1);
    });
  });
}
