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
| `logCategory` | `String` | Категория для логирования / аналитики |

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
  type: ValidationFailure.requiredField,
  field: 'email',
  message: 'Email is required',
  fieldErrors: {'email': ['Required', 'Invalid format']},
);
```

---

## Справочник по enum'ам

### NetworkFailure

| Значение | Описание |
|----------|----------|
| `noInternet` | Нет подключения к интернету |
| `timeout` | Превышено время ожидания соединения |
| `badCertificate` | Невалидный SSL-сертификат |
| `cancelled` | Запрос был отменён |
| `dnsLookupFailed` | Не удалось разрешить DNS |
| `connectionRefused` | Сервер отклонил соединение |
| `hostUnreachable` | Хост недоступен |
| `connectionReset` | Соединение сброшено |
| `proxyError` | Ошибка прокси-сервера |
| `vpnError` | Ошибка VPN |
| `tooManyRedirects` | Слишком много перенаправлений |
| `invalidUrl` | Невалидный URL |

### HttpFailure

| Значение | HTTP Статус | Описание |
|----------|-------------|----------|
| `badRequest` | 400 | Неверный запрос |
| `unauthorized` | 401 | Не аутентифицирован |
| `paymentRequired` | 402 | Требуется оплата |
| `forbidden` | 403 | Доступ запрещён |
| `notFound` | 404 | Ресурс не найден |
| `methodNotAllowed` | 405 | HTTP-метод не разрешён |
| `notAcceptable` | 406 | Неприемлемый формат ответа |
| `proxyAuthRequired` | 407 | Требуется аутентификация прокси |
| `requestTimeout` | 408 | Время ожидания запроса истекло |
| `conflict` | 409 | Конфликт данных |
| `gone` | 410 | Ресурс удалён навсегда |
| `lengthRequired` | 411 | Требуется Content-Length |
| `preconditionFailed` | 412 | Предусловие не выполнено |
| `payloadTooLarge` | 413 | Тело запроса слишком велико |
| `uriTooLong` | 414 | URI слишком длинный |
| `unsupportedMediaType` | 415 | Неподдерживаемый тип содержимого |
| `rangeNotSatisfiable` | 416 | Запрашиваемый диапазон не удовлетворён |
| `expectationFailed` | 417 | Ожидание не выполнено |
| `teapot` | 418 | Я чайник (RFC 2324) |
| `misdirectedRequest` | 421 | Неправильно направление запроса |
| `unprocessableEntity` | 422 | Ошибки валидации на стороне сервера |
| `locked` | 423 | Ресурс заблокирован |
| `failedDependency` | 424 | Не удалось выполнить зависимость |
| `tooEarly` | 425 | Слишком рано |
| `upgradeRequired` | 426 | Требуется обновление протокола |
| `preconditionRequired` | 428 | Требуется предусловие |
| `tooManyRequests` | 429 | Слишком много запросов |
| `requestHeaderFieldsTooLarge` | 431 | Заголовки запроса слишком велики |
| `unavailableForLegalReasons` | 451 | Недоступно по юридическим причинам |
| `internalServerError` | 500 | Внутренняя ошибка сервера |
| `notImplemented` | 501 | Не реализовано на сервере |
| `badGateway` | 502 | Неверный шлюз |
| `serviceUnavailable` | 503 | Сервис недоступен |
| `gatewayTimeout` | 504 | Шлюз не отвечает |
| `httpVersionNotSupported` | 505 | Версия HTTP не поддерживается |
| `variantAlsoNegotiates` | 506 | Вариант тоже согласовывает |
| `insufficientStorage` | 507 | Недостаточно места на сервере |
| `loopDetected` | 508 | Обнаружен цикл |
| `notExtended` | 510 | Расширение не требуется |
| `networkAuthenticationRequired` | 511 | Требуется сетевая аутентификация |
| `unknown` | — | Любая другая ошибка HTTP |

### AuthFailure

| Значение | Описание |
|----------|----------|
| `unauthorized` | Нет активной сессии |
| `forbidden` | Недостаточно прав |
| `tokenExpired` | Токен доступа истёк |
| `tokenInvalid` | Токен невалиден / повреждён |
| `refreshTokenExpired` | Токен обновления истёк |
| `refreshTokenInvalid` | Токен обновления невалиден |
| `sessionRevoked` | Сессия отозвана (выход с другого устройства / блокировка) |
| `sessionNotFound` | Сессия не найдена |
| `wrongCredentials` | Неверный логин / пароль |
| `accountBlocked` | Аккаунт заблокирован |
| `accountTemporarilyLocked` | Аккаунт временно заблокирован (слишком много неудачных попыток) |
| `accountNotVerified` | Аккаунт не подтверждён (email / телефон) |
| `accountDeleted` | Аккаунт удалён |
| `accountNotFound` | Аккаунт не найден |
| `accountAlreadyExists` | Аккаунт уже существует |
| `passwordExpired` | Пароль истёк, требуется смена |
| `twoFactorRequired` | Требуется двухфакторная аутентификация |
| `twoFactorFailed` | Невалидный код двухфакторной аутентификации |
| `twoFactorExpired` | Код двухфакторной аутентификации истёк |
| `biometricFailed` | Ошибка биометрической аутентификации |
| `biometricNotAvailable` | Биометрия не настроена на устройстве |
| `biometricLocked` | Биометрия заблокирована (слишком много неудачных попыток) |
| `oauthFailed` | Ошибка провайдера OAuth (Google, Apple, Facebook...) |
| `oauthDenied` | Провайдер OAuth отклонил запрос |
| `oauthTokenInvalid` | Невалидный токен OAuth |
| `oauthAccountNotLinked` | Аккаунт не привязан к провайдеру OAuth |

### ValidationFailure

| Значение | Описание |
|----------|----------|
| `requiredField` | Обязательное поле пустое |
| `invalidFormat` | Неверный формат поля |
| `invalidEmail` | Неверный формат email |
| `invalidPhone` | Неверный формат телефона |
| `invalidUrl` | Неверный формат URL |
| `invalidDate` | Неверный формат даты |
| `invalidTime` | Неверный формат времени |
| `invalidNumber` | Неверный формат числа |
| `invalidCardNumber` | Неверный формат номера карты |
| `tooLong` | Значение превышает максимальную длину |
| `tooShort` | Значение короче минимальной длины |
| `tooLarge` | Числовое значение превышает максимум |
| `tooSmall` | Числовое значение ниже минимума |
| `outOfRange` | Значение вне допустимого диапазона |
| `notUnique` | Значение не уникально (уже существует) |
| `passwordTooWeak` | Пароль слишком слабый |
| `passwordMismatch` | Пароли не совпадают |
| `fileTooLarge` | Файл слишком большой |
| `invalidFileType` | Неверный тип файла |
| `invalidImageSize` | Неверные размеры изображения |
| `invalidCharacters` | Значение содержит запрещённые символы |
| `serverValidation` | Несколько ошибок валидации от сервера |

---

## Result\<T\> — функциональный результат

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
  ValidationFailure.requiredField,
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
// → "validation.required_field"
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

---

## NexoFlutterErrors — глобальная обработка ошибок

`NexoFlutterErrors` обеспечивает глобальный перехват ошибок для Flutter-приложений. После `install()` перехватываются:

- `FlutterError.onError` — ошибки рендеринга и assert'ы
- `PlatformDispatcher.instance.onError` — необработанные асинхронные ошибки

Также используйте `runAppInZone()` для перехвата ошибок в зоне.

### install()

```dart
NexoFlutterErrors.install(
  logger: logger,
  crashReporter: crashReporter, // опционально
);
```

| Параметр | Тип | Обязателен | Описание |
|----------|-----|------------|----------|
| `logger` | `NexoLogger` | да | Логгер для записи ошибок |
| `crashReporter` | `NexoCrashReporter` | нет | Сервис краш-репортов (например, Sentry, Crashlytics) |

### uninstall()

Удаляет глобальные обработчики. Полезно в тестах.

```dart
NexoFlutterErrors.uninstall();
```

### runAppInZone()

Оборачивает `body` в `runZonedGuarded` с отчётом об ошибках как в логгер, так и в `NexoCrashReporter`. Ошибки из самого `body` перехватываются и сообщаются (без re-throw), поэтому `Future` завершается; второй канал перехватывает необработанные ошибки внутри зоны.

```dart
NexoFlutterErrors.runAppInZone(() async {
  WidgetsFlutterBinding.ensureInitialized();
  // DI setup, NexoFlutterErrors.install() и т.д.
  runApp(MyApp());
});
```

### Важно: несоответствие зон

`WidgetsFlutterBinding.ensureInitialized()` и `runApp` **должны** вызываться в **одной зоне**. Если вызвать `ensureInitialized` вне зоны, а `runApp` внутри, Flutter выдаст ошибку несоответствия зон.

**Правильно:**

```dart
NexoFlutterErrors.runAppInZone(() async {
  WidgetsFlutterBinding.ensureInitialized();
  NexoFlutterErrors.install(logger: logger);
  runApp(MyApp());
});
```

**Неправильно:**

```dart
WidgetsFlutterBinding.ensureInitialized();
NexoFlutterErrors.install(logger: logger);
NexoFlutterErrors.runAppInZone(() async {
  runApp(MyApp()); // zone mismatch!
});
```

**Правило:** Оберните весь ваш `main` (включая `ensureInitialized`, DI, `install` и `runApp`) внутрь тела `runAppInZone`.
