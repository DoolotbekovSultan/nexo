import 'package:nexo/packages/nexo_errors/failure.dart';

/// Абстракция для Crashlytics, Sentry и т.п. Реализации подключаются в приложении.
abstract class NexoCrashReporter {
  /// Зафиксировать уже смапленный [Failure] (например из UseCase / Bloc).
  void recordFailure(
    Failure failure, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  });

  /// Сырой сбой до маппинга в [Failure].
  void recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
  });
}

/// Заглушка по умолчанию.
final class NoOpNexoCrashReporter implements NexoCrashReporter {
  const NoOpNexoCrashReporter();

  @override
  void recordFailure(
    Failure failure, {
    StackTrace? stackTrace,
    Map<String, Object?>? context,
  }) {}

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
  }) {}
}
