import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo_logger/nexo_logger.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
}

void main() {
  group('CollectingNexoCrashReporter breadcrumbs', () {
    test('крошки накапливаются в порядке добавления', () {
      final reporter = CollectingNexoCrashReporter();

      reporter.recordBreadcrumb(
        NexoBreadcrumb('открыл экран', category: 'nav'),
      );
      reporter.recordBreadcrumb(
        NexoBreadcrumb('POST /orders → 401', category: 'http'),
      );

      final trail = reporter.breadcrumbTrail;

      expect(trail, hasLength(2));
      expect(trail.first.category, 'nav');
      expect(trail.last.message, 'POST /orders → 401');
    });

    test('кольцевой буфер держит только последние maxBreadcrumbs', () {
      final reporter = CollectingNexoCrashReporter(maxBreadcrumbs: 3);

      for (var i = 0; i < 5; i++) {
        reporter.recordBreadcrumb(NexoBreadcrumb('event-$i'));
      }

      expect(reporter.breadcrumbTrail.map((b) => b.message), [
        'event-2',
        'event-3',
        'event-4',
      ]);
    });

    test('data иммутабельна, timestamp проставляется сам', () {
      final Map<String, Object?> data = {'requestId': 'req-1'};
      final crumb = NexoBreadcrumb('запрос', category: 'http', data: data);

      data['injected'] = true;

      expect(crumb.data, {'requestId': 'req-1'});
      expect(
        crumb.timestamp.isBefore(
          DateTime.now().add(const Duration(seconds: 1)),
        ),
        isTrue,
      );
      expect(crumb.level, NexoBreadcrumbLevel.info);
    });

    test('clear очищает и крошки тоже', () {
      final reporter = CollectingNexoCrashReporter();
      reporter.recordBreadcrumb(NexoBreadcrumb('x'));

      reporter.clear();

      expect(reporter.breadcrumbTrail, isEmpty);
    });

    test('toString содержит категорию и сообщение', () {
      final crumb = NexoBreadcrumb('упс', category: 'ui');

      expect('$crumb', contains('[ui]'));
      expect('$crumb', contains('упс'));
    });
  });

  group('интеграции', () {
    test('NoOp принимает крошки без побочных эффектов', () {
      const reporter = NoOpNexoCrashReporter();

      expect(
        () => reporter.recordBreadcrumb(NexoBreadcrumb('noop')),
        returnsNormally,
      );
    });

    test('NexoBlocObserver пишет ошибку блока в ленту и в отчёт', () {
      final reporter = CollectingNexoCrashReporter();
      final observer = NexoBlocObserver(
        _FakeLogger(),
        crashReporter: reporter,
        logErrors: true,
      );
      final cubit = _CounterCubit();

      observer.onError(cubit, StateError('boom'), StackTrace.current);

      final trail = reporter.breadcrumbTrail;
      expect(trail, hasLength(1));
      expect(trail.single.category, 'bloc');
      expect(trail.single.level, NexoBreadcrumbLevel.error);
      expect(trail.single.data, isNotNull);
      expect(trail.single.data!['failureCode'], isNotEmpty);

      expect(reporter.recordedErrors, hasLength(1));
    });
  });
}

class _FakeLogger implements NexoLogger {
  @override
  void debug(String message) {}

  @override
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  }) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}
}
