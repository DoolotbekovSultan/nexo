# Логирование

Nexo предоставляет абстракцию `NexoLogger` и готовый адаптер для Talker.

---

## Базовая настройка

```dart
import 'package:talker/talker.dart';
import 'package:nexo/nexo_logger.dart';

final talker = Talker();
final logger = TalkerLoggerAdapter(talker);
```

---

## Уровни логирования

```dart
// Debug — детальная информация для разработчиков
logger.debug('Загружено ${users.length} пользователей');

// Info — значимые события
logger.info('Приложение запущено');
logger.info('Пользователь вошёл в аккаунт');

// Warning — предупреждения (не критичные)
logger.warning('Токен скоро истечёт');

// Error — ошибки с стеком вызовов
logger.error(
  message: 'Ошибка загрузки профиля',
  error: exception,
  stackTrace: stackTrace,
);
```

---

## Интеграция с BLoC

```dart
// NexoBlocObserver автоматически логирует:
// - Создание/закрытие BLoC/Cubit
// - Входящие события
// - Изменения состояний
// - Ошибки

Bloc.observer = NexoBlocObserver(
  logger,
  crashReporter: crashReporter,
  logLifecycle: true,   // Created / Closed
  logEvents: true,      // Event: ...
  logChanges: true,     // State: ... → ...
  logErrors: true,      // Error [code]: message
  maxLogLength: 1000,   // Обрезка длинных значений
  shouldLogBloc: (bloc) => bloc is! InternalBloc, // Фильтрация
);
```

---

## Интеграция с Network

```dart
// NexoLoggingInterceptor логирует:
// - HTTP REQUEST: метод, URL, заголовки, тело
// - HTTP RESPONSE: статус, время, тело
// - HTTP ERROR: тип, статус, сообщение

dio.interceptors.add(
  NexoLoggingInterceptor(
    logger: logger,
    logRequests: true,
    logRequestHeaders: true,
    logRequestBody: true,
    logResponses: true,
    logResponseHeaders: false, // заголовки ответов — шумные
    logResponseBody: true,
    logErrors: true,
    sensitiveFields: {'password', 'token', 'secret'}, // маскировка
  ),
);
```

---

## Автологирование UseCase

`NexoUseCase` и `NexoStreamUseCase` автоматически логируют:

```dart
// UseCase логирует:
// - "UseCase started: GetUserUseCase"
// - "UseCase succeeded: GetUserUseCase"
// - "UseCase failed: GetUserUseCase, code: network.no_internet, message: ..."
// - "UseCase finished: GetUserUseCase"

// Уровень:
// - started/finished → debug
// - succeeded → debug
// - failed → error (с object error и stackTrace)
```

---

## Автологирование Hive/Isar/SharedPreferences

Все датасорсы автоматически логируют:

```dart
// Hive:
// [Hive:users] Initializing
// [Hive:users] Put key=user_1 flush=false
// [Hive:users] Get key=user_1 hit=true
// [Hive:users] Failed to get key=missing

// SharedPreferences:
// [SP] setString failed key=theme
// [SP] getString failed key=missing

// SecureStorage:
// [SecureStorage] write failed key=token
// [SecureStorage] read failed key=token
```

---

## Кастомная реализация

```dart
class MyLogger implements NexoLogger {
  @override
  void debug(String message) {
    if (kDebugMode) print('[DEBUG] $message');
  }

  @override
  void info(String message) {
    analytics.logEvent(name: 'info', parameters: {'message': message});
  }

  @override
  void warning(String message) {
    analytics.logEvent(name: 'warning', parameters: {'message': message});
  }

  @override
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  }) {
    crashlytics.recordError(error, stackTrace, reason: message);
  }
}
```

---

## Crash Reporter

```dart
// Абстракция для Crashlytics / Sentry
abstract class NexoCrashReporter {
  void recordFailure(Failure failure, {StackTrace? stackTrace, Map<String, Object?>? context});
  void recordError(Object error, StackTrace stackTrace, {Map<String, Object?>? context});
  void recordBreadcrumb(NexoBreadcrumb breadcrumb);
}

// Заглушка (по умолчанию)
final reporter = NoOpNexoCrashReporter();

// Для тестов — собирает всё в память
final reporter = CollectingNexoCrashReporter(maxBreadcrumbs: 100);
// reporter.recordedFailures — список записанных Failure
// reporter.recordedErrors — список ошибок до маппинга
// reporter.breadcrumbTrail — лента breadcrumb'ов
```
