import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/nexo_crash_reporter.dart';

/// Реализация [NexoCrashReporter] для тестов и отладки: накапливает события
/// в памяти и держит кольцевой буфер breadcrumbs.
///
/// ## Пример использования
///
/// ```dart
/// final reporter = CollectingNexoCrashReporter(maxBreadcrumbs: 100);
///
/// // В тесте:
/// expect(reporter.recordedFailures, isEmpty);
/// reporter.recordFailure(someFailure);
/// expect(reporter.recordedFailures, hasLength(1));
/// ```
final class CollectingNexoCrashReporter implements NexoCrashReporter {
  /// Создаёт собирающий репортёр.
  ///
  /// [maxBreadcrumbs] — максимум breadcrumb'ов в ленте. По умолчанию: 50.
  CollectingNexoCrashReporter({this.maxBreadcrumbs = 50});

  /// Список записанных [Failure] для проверки в тестах.
  final List<Failure> recordedFailures = [];

  /// Список записанных ошибок (до маппинга в [Failure]) для проверки в тестах.
  final List<({Object error, StackTrace stackTrace})> recordedErrors = [];

  /// Вместимость ленты breadcrumbs; старые крошки вытесняются.
  final int maxBreadcrumbs;

  final List<NexoBreadcrumb> _breadcrumbs = [];

  /// Неизменяемый снимок последних [maxBreadcrumbs] крошек.
  List<NexoBreadcrumb> get breadcrumbTrail => List.unmodifiable(_breadcrumbs);

  /// Записывает [Failure] в список [recordedFailures].
  @override
  void recordFailure(
    Failure failure, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {
    recordedFailures.add(failure);
  }

  /// Записывает ошибку (до маппинга) в список [recordedErrors].
  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
  }) {
    recordedErrors.add((error: error, stackTrace: stackTrace));
  }

  /// Добавляет breadcrumb в кольцевой буфер.
  @override
  void recordBreadcrumb(NexoBreadcrumb breadcrumb) {
    _breadcrumbs.add(breadcrumb);
    if (_breadcrumbs.length > maxBreadcrumbs) {
      _breadcrumbs.removeRange(0, _breadcrumbs.length - maxBreadcrumbs);
    }
  }

  /// Очищает все накопленные данные (ошибки, breadcrumbs).
  void clear() {
    recordedFailures.clear();
    recordedErrors.clear();
    _breadcrumbs.clear();
  }
}
