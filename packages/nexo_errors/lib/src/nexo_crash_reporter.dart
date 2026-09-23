import 'package:nexo_errors/src/failure.dart';

/// Уровень важности [NexoBreadcrumb] — для фильтрации в Sentry / Crashlytics.
enum NexoBreadcrumbLevel { debug, info, warning, error }

/// «Хлебная крошка» — событие из жизни приложения до сбоя.
///
/// Лента последних крошек прикладывается к краш-репорту и показывает,
/// *как* приложение пришло к ошибке: навигация, HTTP-запросы, ошибки
/// блоков, действия пользователя.
final class NexoBreadcrumb {
  /// Создаёт «хлебную крошку».
  ///
  /// [message] — текст события.
  /// [category] — категория (nav, http, bloc, ui и т.д.). По умолчанию: `app`.
  /// [level] — важность события. По умолчанию: [NexoBreadcrumbLevel.info].
  /// [data] — дополнительные структурированные данные (опционально).
  NexoBreadcrumb(
    this.message, {
    this.category = 'app',
    this.level = NexoBreadcrumbLevel.info,
    Map<String, Object?>? data,
  }) : data = data == null ? null : Map.unmodifiable(data),
       timestamp = DateTime.now();

  /// Текст события («открыл экран Checkout», «POST /orders → 401»).
  final String message;

  /// Категория: `nav`, `http`, `usecase`, `bloc`, `ui`, …
  final String category;

  /// Важность события.
  final NexoBreadcrumbLevel level;

  /// Дополнительные структурированные данные (id запроса, код ошибки…).
  final Map<String, Object?>? data;

  /// Момент события; проставляется автоматически.
  final DateTime timestamp;

  @override
  String toString() => '$timestamp [$category] $message';
}

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

  /// Добавить событие в ленту breadcrumbs, прикладываемую к краш-репортам.
  ///
  /// Вызывайте из навигации, HTTP-слоя и UI; [NexoBlocObserver] пишет
  /// ошибки блоков автоматически.
  void recordBreadcrumb(NexoBreadcrumb breadcrumb);
}

/// Заглушка по умолчанию; ничего не делает.
///
/// Используется, когда реальный [NexoCrashReporter] не нужен
/// (например, в тестах или когда crash reporting отключён).
final class NoOpNexoCrashReporter implements NexoCrashReporter {
  /// Создаёт заглушку [NoOpNexoCrashReporter].
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

  @override
  void recordBreadcrumb(NexoBreadcrumb breadcrumb) {}
}
