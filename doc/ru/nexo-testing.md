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

Тестовый дублёр для `NexoCrashReporter`, накапливающий события в памяти. Полезен для проверки интеграции с краш-репортером в тестах:

```dart
final reporter = CollectingNexoCrashReporter(maxBreadcrumbs: 50);

// Вызываем методы, которые должны записывать ошибки
await someOperation();

// Проверяем записанные Failure
expect(reporter.recordedFailures, hasLength(1));
expect(reporter.recordedFailures.first.code, equals('network.no_internet'));

// Проверяем сырые ошибки (до маппинга в Failure)
expect(reporter.recordedErrors, isEmpty);

// Проверяем ленту breadcrumb'ов (кольцевой буфер, старые первыми)
expect(reporter.breadcrumbTrail, hasLength(3));
expect(reporter.breadcrumbTrail.last.message, contains('POST /api'));
```

Репортер хранит кольцевой буфер breadcrumb'ов (по умолчанию 50, настраивается через `maxBreadcrumbs`). Старые breadcrumb'ы удаляются при заполнении буфера. Вызовите `reporter.clear()` для сброса всех накопленных данных между тестами.

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

Встроенного `CollectingLogger` нет — используйте `_FakeLogger`, реализующий `NexoLogger`:

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
