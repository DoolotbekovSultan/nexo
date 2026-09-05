# Testing

Nexo provides matchers and utilities for testing.

---

## Result Matchers

```dart
import 'package:nexo/nexo_testing.dart';

// Check for success
expect(result, isSuccess());

// Check for success with a specific value
expect(result, isSuccess(42));

// Check for failure
expect(result, isFailure());

// Check for failure with a specific code
expect(result, isFailure(code: 'network.no_internet'));

// Check a specific Failure
expect(failure, failureWithCode('auth.token_expired'));
expect(failure, failureWithUserMessage('Session expired'));
```

---

## Extracting Data from Result

```dart
// Get the value or throw an error
final user = result.dataOrThrow();
// If result is Left, throws StateError with code and message

// Get the failure or throw
final failure = result.failureOrThrow();
// If result is Right, throws StateError with the value
```

---

## CollectingNexoCrashReporter

A test double for `NexoCrashReporter` that accumulates events in memory, useful for verifying crash reporting integration in tests:

```dart
final reporter = CollectingNexoCrashReporter(maxBreadcrumbs: 50);

// Call methods that should record errors
await someOperation();

// Verify recorded failures
expect(reporter.recordedFailures, hasLength(1));
expect(reporter.recordedFailures.first.code, equals('network.no_internet'));

// Verify raw errors (before mapping to Failure)
expect(reporter.recordedErrors, isEmpty);

// Verify breadcrumb trail (ring buffer, oldest first)
expect(reporter.breadcrumbTrail, hasLength(3));
expect(reporter.breadcrumbTrail.last.message, contains('POST /api'));
```

The reporter keeps a ring buffer of breadcrumbs (default 50, configurable via `maxBreadcrumbs`). Old breadcrumbs are evicted when the buffer is full. Call `reporter.clear()` to reset all accumulated data between test cases.

---

## Cubit Testing with blocTest

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:nexo/nexo_testing.dart';

void main() {
  group('UserCubit', () => {
    blocTest<UserCubit, NexoAsyncState<User>>(
      'emits Loading → Success on load',
      build: () => UserCubit(mockUseCase),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<NexoAsyncLoading<User>>(),
        isA<NexoAsyncSuccess<User>>(),
      ],
    );

    blocTest<UserCubit, NexoAsyncState<User>>(
      'emits Loading → Failure on error',
      build: () => UserCubit(failingUseCase),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<NexoAsyncLoading<User>>(),
        isA<NexoAsyncFailure<User>>(),
      ],
    );
  });
}
```

---

## UseCase Testing

There is no built-in `CollectingLogger` — use a `_FakeLogger` implementing `NexoLogger`:

```dart
class _FakeLogger implements NexoLogger {
  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}

  @override
  void error({required String message, required Object error, StackTrace? stackTrace}) {}
}

void main() {
  test('GetUserUseCase returns user on success', () async {
    final logger = _FakeLogger();
    final useCase = GetUserUseCase(logger);

    final result = await useCase('user_123');

    expect(result, isSuccess<User>());
    expect(result.dataOrThrow().name, equals('John'));
  });

  test('GetUserUseCase returns Failure on error', () async {
    final logger = _FakeLogger();
    final useCase = FailingUseCase(logger);

    final result = await useCase('user_123');

    expect(result, isFailure(code: 'network.no_internet'));
  });
}
```

---

## Mocking Dependencies

```dart
// Mock UseCase
class MockGetUserUseCase extends Mock implements GetUserUseCase {}

// Mock Logger
class MockLogger extends Mock implements NexoLogger {}

// Mock data source
class MockUserRemoteDataSource extends Mock
    implements UserRemoteDataSource {}

// Usage in tests
final mockUseCase = MockGetUserUseCase();
when(() => mockUseCase(any())).thenAnswer(
  (_) async => Result.success(User(name: 'Test')),
);
```
