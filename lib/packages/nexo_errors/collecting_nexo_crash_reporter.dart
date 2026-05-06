import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/nexo_crash_reporter.dart';

/// Реализация [NexoCrashReporter] для тестов и отладки: накапливает события в памяти.
final class CollectingNexoCrashReporter implements NexoCrashReporter {
  final List<Failure> recordedFailures = [];
  final List<({Object error, StackTrace stackTrace})> recordedErrors = [];

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

  void clear() {
    recordedFailures.clear();
    recordedErrors.clear();
  }
}
