# Тестирование

Nexo предоставляет матчеры и утилиты для тестирования.

---

## Матчеры для Result

```dart
import 'package:nexo/nexo_testing.dart';

// Проверка успеха
expect(result, isSuccess());

// Проверка успеха с конкретным значением
expect(result, isSuccess(42));

// Проверка ошибки
expect(result, isFailure());

// Проверка ошибки с конкретным кодом
expect(result, isFailure(code: 'network.no_internet'));

// Проверка конкретного Failure
expect(failure, failureWithCode('auth.token_expired'));
expect(failure, failureWithUserMessage('Сессия истекла'));
```

---

## Извлечение данных из Result

```dart
// Получить значение или выбросить ошибку
final user = result.dataOrThrow();
// Если result — Left, выбросит StateError с кодом и сообщением

// Получить ошибку или выбросить
final failure = result.failureOrThrow();
// Если result — Right, выбросит StateError со значением
```

---

## CollectingNexoCrashReporter

Для тестирования интеграции с краш-репортером:

```dart
final reporter = CollectingNexoCrashReporter(maxBreadcrumbs: 50);

// Вызываем методы, которые должны записывать ошибки
await someOperation();

// Проверяем
expect(reporter.recordedFailures, hasLength(1));
expect(reporter.recordedFailures.first.code, equals('network.no_internet'));

expect(reporter.recordedErrors, isEmpty);

expect(reporter.breadcrumbTrail, hasLength(3));
expect(reporter.breadcrumbTrail.last.message, contains('POST /api'));
```

---

## Тестирование Cubit

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

## Тестирование UseCase

```dart
void main() {
  test('GetUserUseCase returns user on success', () async {
    final logger = CollectingLogger(); // ваша заглушка
    final useCase = GetUserUseCase(logger);

    final result = await useCase('user_123');

    expect(result, isSuccess<User>());
    expect(result.dataOrThrow().name, equals('John'));
  });

  test('GetUserUseCase returns Failure on error', () async {
    final logger = CollectingLogger();
    final useCase = FailingUseCase(logger);

    final result = await useCase('user_123');

    expect(result, isFailure(code: 'network.no_internet'));
  });
}
```

---

## Мокирование зависимостей

```dart
// Мок UseCase
class MockGetUserUseCase extends Mock implements GetUserUseCase {}

// Мок Logger
class MockLogger extends Mock implements NexoLogger {}

// Мок датасource
class MockUserRemoteDataSource extends Mock
    implements UserRemoteDataSource {}

// Использование в тестах
final mockUseCase = MockGetUserUseCase();
when(() => mockUseCase(any())).thenAnswer(
  (_) async => Result.success(User(name: 'Test')),
);
```
