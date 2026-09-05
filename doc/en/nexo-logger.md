# Logging

Nexo provides a `NexoLogger` abstraction and a ready-made adapter for Talker.

---

## Basic Setup

```dart
import 'package:talker/talker.dart';
import 'package:nexo/nexo_logger.dart';

final talker = Talker();
final logger = TalkerLoggerAdapter(talker);
```

---

## Log Levels

```dart
// Debug — detailed information for developers
logger.debug('Loaded ${users.length} users');

// Info — significant events
logger.info('Application started');
logger.info('User signed in');

// Warning — non-critical warnings
logger.warning('Token is about to expire');

// Error — errors with stack traces
logger.error(
  message: 'Failed to load profile',
  error: exception,
  stackTrace: stackTrace,
);
```

---

## BLoC Integration

```dart
// NexoBlocObserver automatically logs:
// - BLoC/Cubit creation and closure
// - Incoming events
// - State transitions
// - Errors

Bloc.observer = NexoBlocObserver(
  logger,
  crashReporter: crashReporter,
  logLifecycle: true,   // Created / Closed
  logEvents: true,      // Event: ...
  logChanges: true,     // State: ... → ...
  logErrors: true,      // Error [code]: message
  maxLogLength: 1000,   // Truncation of long values
  shouldLogBloc: (bloc) => bloc is! InternalBloc, // Filtering
);
```

---

## Network Integration

```dart
// NexoLoggingInterceptor logs:
// - HTTP REQUEST: method, URL, headers, body
// - HTTP RESPONSE: status, duration, body
// - HTTP ERROR: type, status, message

dio.interceptors.add(
  NexoLoggingInterceptor(
    logger: logger,
    logRequests: true,
    logRequestHeaders: true,
    logRequestBody: true,
    logResponses: true,
    logResponseHeaders: false, // response headers are noisy
    logResponseBody: true,
    logErrors: true,
    sensitiveFields: {'password', 'token', 'secret'}, // masking
  ),
);
```

---

## UseCase Auto-Logging

`NexoUseCase` and `NexoStreamUseCase` automatically log:

```dart
// UseCase logs:
// - "UseCase started: GetUserUseCase"
// - "UseCase succeeded: GetUserUseCase"
// - "UseCase failed: GetUserUseCase, code: network.no_internet, message: ..."
// - "UseCase finished: GetUserUseCase"

// Levels:
// - started/finished → debug
// - succeeded → debug
// - failed → error (with error object and stackTrace)
```

---

## Hive/Isar/SharedPreferences Auto-Logging

All data sources automatically log:

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

## Custom Implementation

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
// Abstraction for Crashlytics / Sentry
abstract class NexoCrashReporter {
  void recordFailure(Failure failure, {StackTrace? stackTrace, Map<String, Object?>? context});
  void recordError(Object error, StackTrace stackTrace, {Map<String, Object?>? context});
  void recordBreadcrumb(NexoBreadcrumb breadcrumb);
}

// No-op stub (default)
final reporter = NoOpNexoCrashReporter();

// For tests — collects everything in memory
final reporter = CollectingNexoCrashReporter(maxBreadcrumbs: 100);
// reporter.recordedFailures — list of recorded Failure instances
// reporter.recordedErrors — list of errors before mapping
// reporter.breadcrumbTrail — breadcrumb feed
```
