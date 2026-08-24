import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/nexo_crash_reporter.dart';

/// Реализация [NexoCrashReporter] для тестов и отладки: накапливает события
/// в памяти и держит кольцевой буфер breadcrumbs.
final class CollectingNexoCrashReporter implements NexoCrashReporter {
  CollectingNexoCrashReporter({this.maxBreadcrumbs = 50});

  final List<Failure> recordedFailures = [];
  final List<({Object error, StackTrace stackTrace})> recordedErrors = [];

  /// Вместимость ленты breadcrumbs; старые крошки вытесняются.
  final int maxBreadcrumbs;

  final List<NexoBreadcrumb> _breadcrumbs = [];

  /// Неизменяемый снимок последних [maxBreadcrumbs] крошек.
  List<NexoBreadcrumb> get breadcrumbTrail => List.unmodifiable(_breadcrumbs);

  @override
  void recordFailure(
    Failure failure, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    recordedFailures.add(failure);
  }

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
  }) {
    recordedErrors.add((error: error, stackTrace: stackTrace));
  }

  @override
  void recordBreadcrumb(NexoBreadcrumb breadcrumb) {
    _breadcrumbs.add(breadcrumb);
    if (_breadcrumbs.length > maxBreadcrumbs) {
      _breadcrumbs.removeRange(0, _breadcrumbs.length - maxBreadcrumbs);
    }
  }

  void clear() {
    recordedFailures.clear();
    recordedErrors.clear();
    _breadcrumbs.clear();
  }
}
