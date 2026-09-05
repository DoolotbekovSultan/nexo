# Обработка ошибок: Failure и Result

Nexo предоставляет единую модель ошибок через sealed-класс `Failure` и функциональный тип `Result<T>`.

---

## Failure — единая модель ошибок

`Failure` — sealed-класс с 16 конструкторами для разных категорий ошибок:

```dart
sealed class Failure {
  // Конструкторы
  Failure.network(...)     // Сетевые ошибки
  Failure.http(...)        // HTTP-ошибки (4xx, 5xx)
  Failure.auth(...)        // Аутентификация
  Failure.validation(...)  // Валидация данных
  Failure.storage(...)     // Локальное хранилище
  Failure.database(...)    // База данных
  Failure.cache(...)       // Кэш
  Failure.parse(...)       // Парсинг данных
  Failure.permission(...)  // Разрешения ОС
  Failure.platform(...)    // Платформенные ошибки
  Failure.file(...)        // Файловые операции
  Failure.location(...)    // Геолокация
  Failure.notification(...) // Push-уведомления
  Failure.payment(...)     // Платежи
  Failure.sync(...)        // Синхронизация
  Failure.unknown(...)     // Неизвестные ошибки
}
```

### Каждый Failure содержит

| Свойство | Тип | Описание |
|----------|-----|----------|
| `userMessage` | `String` | Сообщение для пользователя (по умолчанию на русском) |
| `code` | `String` | Стабильный код ошибки (например, `network.no_internet`) |
| `isRetryable` | `bool` | Можно ли повторить операцию |
| `requiresLogout` | `bool` | Нужен ли выход из аккаунта |
| `logCategory` | `String` | Категория для логирования |

### Примеры создания

```dart
// Сетевая ошибка
final failure = Failure.network(type: NetworkFailure.noInternet);

// HTTP ошибка с деталями
final failure = Failure.http(
  type: HttpFailure.unauthorized,
  statusCode: 401,
  message: 'Invalid token',
);

// Ошибка аутентификации
final failure = Failure.auth(
  type: AuthFailure.tokenExpired,
  message: 'Session expired',
);

// Ошибка валидации с ошибками по полям
final failure = Failure.validation(
  type: ValidationFailure.required,
  field: 'email',
  message: 'Email is required',
  fieldErrors: {'email': ['Required', 'Invalid format']},
);
```

---

## Result<T> — функциональный результат

`Result<T>` — sealed-класс, заменяющий try-catch на композицию:

```dart
sealed class Result<T> {
  Result.success(T value);  // Right — успех
  Result.failure(Failure);  // Left — ошибка
}
```

### Создание

```dart
// Успех
final result = Result.success(User(name: 'John'));

// Ошибка
final result = Result<int>.failure(
  Failure.network(type: NetworkFailure.noInternet),
);
```

### Обработка

```dart
// 1. fold — развёртывание в одно значение
final message = result.fold(
  onFailure: (f) => f.userMessage,
  onSuccess: (data) => 'Загружено: $data',
);

// 2. Паттерн-матчинг
final text = switch (result) {
  Right(:final value) => 'Данные: $value',
  Left(:final failure) => failure.userMessage,
};

// 3. Проверка типа
if (result.isSuccess) {
  final data = result.dataOrNull;
}

// 4. Получение значения или fallback
final data = result.getOrElse((f) => defaultValue);

// 5. Трансформация
final mapped = result.map((data) => data.toUpperCase());
```

### В UseCase

```dart
class GetUserUseCase extends NexoUseCase<User, String> {
  GetUserUseCase(super.logger);

  @override
  Future<User> execute(String userId) async {
    return await api.getUser(userId);
  }
}

// Вызов — автоматически оборачивает в Result
final result = await GetUserUseCase(logger)('user_123');

result.fold(
  onFailure: (f) => showError(f.userMessage),
  onSuccess: (user) => showProfile(user),
);
```

---

## Мапперы ошибок

`FailureMapper` преобразует произвольные исключения в `Failure`:

```dart
try {
  await dio.get('/api/data');
} catch (e, s) {
  // Автоматический маппинг
  final failure = FailureMapper.from(e, s);
  showSnackBar(failure.userMessage);
}
```

### Через extension

```dart
catch (e, s) {
  final failure = e.toFailure(s);
  // то же самое
}
```

### Цепочка мапперов

`FailureMapper` пробует мапперы по очереди:

1. `DomainExceptionFailureMapper` — кастомные `AppException`
2. `FirebaseAuthFailureMapper` — ошибки Firebase Auth
3. `FirebaseMessagingFailureMapper` — ошибки Firebase Messaging
4. `DioFailureMapper` — ошибки Dio (HTTP)
5. `PlatformFailureMapper` — ошибки платформенных плагинов
6. `HiveFailureMapper` — ошибки Hive
7. `IsarFailureMapper` — ошибки Isar
8. `DriftFailureMapper` — ошибки Drift/SQLite
9. `FileSystemFailureMapper` — ошибки файловой системы
10. `CommonFailureMapper` — универсальный catch-all

---

## AppException — доменные исключения

Для ошибок бизнес-логики используйте `AppException`:

```dart
// Бросайте исключения в UseCase / репозитории
throw AuthAppException(AuthFailure.wrongCredentials, message: 'Wrong password');
throw ValidationAppException(
  ValidationFailure.required,
  field: 'email',
  fieldErrors: {'email': ['Required']},
);

// FailureMapper автоматически преобразует их в Failure
```

### Типы AppException

| Исключение | Категория |
|-----------|-----------|
| `AuthAppException` | Аутентификация |
| `ValidationAppException` | Валидация |
| `StorageAppException` | Хранилище |
| `DatabaseAppException` | База данных |
| `CacheAppException` | Кэш |
| `ParseAppException` | Парсинг |
| `PermissionAppException` | Разрешения |
| `PlatformAppException` | Платформа |
| `FileAppException` | Файлы |
| `LocationAppException` | Локация |
| `NotificationAppException` | Уведомления |
| `PaymentAppException` | Платежи |
| `SyncAppException` | Синхронизация |

---

## Локализация сообщений

### Встроенная локализация

```dart
// Русские сообщения (по умолчанию)
final message = failure.userMessage; // "Нет подключения к интернету"

// Английские сообщения
final catalog = EnFailureUserMessages();
final message = failure.localizedMessage(catalog); // "No internet connection"
```

### Кастомная локализация

```dart
class MyMessages implements FailureUserMessageCatalog {
  @override
  String forFailure(Failure failure) => switch (failure) {
    NetworkAppFailure(:final type) => switch (type) {
      NetworkFailure.noInternet => 'Проверьте соединение',
      NetworkFailure.timeout => 'Сервер не отвечает',
      _ => 'Ошибка сети',
    },
    _ => 'Произошла ошибка',
  };
}

final message = failure.localizedMessage(MyMessages());
```

---

## FailurePresenter — готовые строки для UI

```dart
// Для Snackbar
final text = FailurePresenter.snackbarMessage(failure);

// Для Dialog — заголовок
final title = FailurePresenter.dialogTitle(failure);

// Для Dialog — тело
final body = FailurePresenter.dialogBody(failure);

// Технический код (для разработчиков)
final code = FailurePresenter.technicalCode(failure);
// → "network.no_internet"
```

---

## Коды ошибок

Каждый `Failure` имеет стабильный строковый код:

```dart
final code = failure.code;
// → "network.no_internet"
// → "http.unauthorized"
// → "auth.token_expired"
// → "validation.required"
```

Коды удобны для:
- Аналитики (отслеживание частоты ошибок)
- Фильтрации (реагировать на конкретные ошибки)
- Логирования (стабильный идентификатор)

```dart
if (failure.code == 'auth.token_expired') {
  // Обновить токен
} else if (failure.code == 'network.no_internet') {
  // Показать offline-экран
}
```
