# nexo

[![CI](https://github.com/DoolotbekovSultan/nexo/actions/workflows/ci.yml/badge.svg)](https://github.com/DoolotbekovSultan/nexo/actions/workflows/ci.yml)

Модульный набор утилит для Flutter-приложений: слой **UseCase**, собственный sealed **`Result`**, единая модель **`Failure`** с маппингом и локализацией, готовый **`NexoAsyncCubit`** и виджеты состояний, очередь офлайн-мутаций (**outbox**), валидаторы форм, **Bloc/Cubit**-обёртки, **Dio** (клиент и интерцепторы), базовые **data source**-ы, **breadcrumbs** для краш-репортов и **логирование**.

**Версия:** `0.0.6-beta.0`  
**SDK:** Dart `^3.11.3`, Flutter `>=1.17.0`

## Установка

Зависимость из git или локальный path — в зависимости от того, как вы публикуете пакет:

```yaml
dependencies:
  nexo:
    path: ../nexo  # или git: url + ref
```

```bash
flutter pub add nexo
# при публикации в pub.dev
```

### Генерация кода

Модель `Failure` построена на **Freezed**. После изменения `failure.dart` или связанных типов:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Структура репозитория

Код сгруппирован по папкам под `lib/packages/` (это **не** отдельные pub-пакеты, а логические модули внутри одного пакета `nexo`):

| Папка | Назначение |
|--------|------------|
| `nexo_core` | UseCase, `NexoAsyncCubit`, Bloc/Cubit, сеть (Dio), локальные/удалённые data source, пагинация, outbox-очередь, валидаторы форм |
| `nexo_errors` | `Failure` (sealed + Freezed), подтипы ошибок, `Result`, мапперы (Dio, Hive, Isar, Drift, Firebase…), breadcrumbs, crash-reporter |
| `nexo_logger` | Абстракция `NexoLogger`, адаптер под **Talker** |
| `nexo_ui` | Виджеты состояний (`NexoAsyncStateBuilder`, `NexoFailureView`, `NexoEmptyView`, скелетоны), feedback (snackbar/диалоги), кнопки/карточки, гэпы |
| `nexo_testing` | Матчеры тестов: `isSuccess` / `isFailure`, `failureWithCode`, расширения `dataOrThrow()` |

Рекомендуемые **barrel-импорты**:

```dart
import 'package:nexo/nexo.dart'; // всё сразу
// или точечно:
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:nexo/nexo_ui.dart';
import 'package:nexo/nexo_testing.dart'; // только в тестах
```

Глубокие импорты по-прежнему допустимы: `package:nexo/packages/nexo_core/...`.

### Локализация сообщений `Failure`

По умолчанию **`userMessage`** — русский текст (как и раньше). Для английского или своей копирайта используйте **`FailureUserMessageCatalog`** и расширение **`localizedMessage`**:

```dart
import 'package:nexo/nexo_errors.dart';

failure.localizedMessage(const EnFailureUserMessages());
```

Свой каталог: реализуйте `FailureUserMessageCatalog` и верните строки из `forFailure`.

### Ядро: `Result`, код ошибки, async-состояние

- **`Result<T>`** — собственный sealed-тип (без dartz): ветки **`Right<T>` / `Left<T>`**, фабрики-алиасы `Result.success(value)` / `Result.failure(failure)`. Именованный `fold(onFailure:, onSuccess:)`, `map`, `getOrElse`, `dataOrNull` / `failureOrNull`, value-equality и **исчерпывающий паттерн-матчинг**:
  ```dart
  final text = switch (result) {
    Right(:final value) => 'Данные: $value',
    Left(:final failure) => failure.userMessage,
  };
  ```
- **`Failure.code`** — стабильная строка (`network.no_internet`, `http.unauthorized`) для Sentry, логов и бэкенда; сетевые/HTTP-ошибки автоматически получают **`requestId`** из `x-request-id`.
- **`NexoAsyncState<T>`** — sealed: `NexoAsyncIdle` / `NexoAsyncLoading` / `NexoAsyncSuccess` / `NexoAsyncFailure`; геттеры `isIdle`, `isLoading`, … и `dataOrNull`, `failureOrNull`.
- **`NexoUseCase.callWithRetry`** — повтор вызова с экспоненциальной задержкой по `retryIf` либо `Failure.isRetryable`.
- **`fetchCacheThenNetwork`** / **`fetchNetworkThenCache`** — минимальный offline-first.
- **`FailurePresenter`** — тексты для snackbar / диалога; используются готовыми виджетами feedback.
- **`NexoCrashReporter`** + **breadcrumbs** — точка расширения для Crashlytics/Sentry: `recordBreadcrumb(NexoBreadcrumb(...))` пишет событие в ленту, которая прикладывается к отчёту; ошибки блоков попадают туда автоматически через `NexoBlocObserver`.
- **`NexoFlutterErrors`** — `install` для `FlutterError.onError` и `PlatformDispatcher.instance.onError`, плюс **`runAppInZone`** (внутри первым вызывайте `WidgetsFlutterBinding.ensureInitialized`, затем `runApp`).
- **`CollectingNexoCrashReporter`** — накопление ошибок и кольцевой буфер крошек в памяти (тесты).
- **`NexoRequestIdInterceptor`** — заголовок `x-request-id`, id в логах и в полях `requestId` у ошибок.

**Сознательно не добавлялись** (чтобы не раздувать пакет): полноценный debug-overlay, жёсткий `NexoEnvironment` с пресетами URL (лучше в приложении), разбиение на несколько pub-пакетов без запроса на миграцию.

## Зависимости (основные)

- **Состояние:** `bloc`, `flutter_bloc`, `bloc_concurrency`, `stream_transform`
- **Сеть:** `dio`
- **Локальные хранилища:** `hive`, `isar`, `shared_preferences`, `flutter_secure_storage`, `path_provider`
- **Firebase (частично):** `firebase_core`, `firebase_auth`
- **Модели:** `freezed_annotation`, `json_annotation`
- **Логи:** `talker`
- **UI:** `flutter_screenutil` (для адаптивных спейсеров; нативные гэпы — чистые пиксели)
- **Тесты (модуль nexo_testing):** `matcher`

## Модули и публичное API

### nexo_logger

- **`NexoLogger`** — абстрактный контракт: `debug`, `info`, `warning`, `error`.
- **`TalkerLoggerAdapter`** — реализация через `Talker`.

Передавайте `NexoLogger` в use case и data source для единообразного логирования.

### nexo_errors

- **`Failure`** — sealed-класс с вариантами: сеть, HTTP, auth, валидация, storage, БД, кэш, parse, permissions, platform, file, location, notification, payment, sync, unknown.
- Удобные геттеры: **`userMessage`** (русский по умолчанию), **`localizedMessage`**, **`isRetryable`**, **`requiresLogout`**, **`requiresSettings`**, **`logCategory`**.
- **`Failure.code`** — стабильный код для аналитики (см. раздел «Ядро» выше).
- **`FailureMapper.from(error, stackTrace?)`** — централизованное преобразование исключений в `Failure` через цепочку **`FailureSubMapper`**.
- **`Object.toFailure([stackTrace])`** — extension (объявлен в `failure_mapper_extension.dart` и дублируется в `failure_mapper.dart` как `FailureMapperX`).
- **`Result<T>`**, **`StreamResult<T>`**, **`FailurePresenter`**, **`NexoCrashReporter`**.

Подмапперы (порядок в `FailureMapper`): доменные исключения, Firebase Auth, Firebase Messaging (по `FirebaseException`), Dio, platform, Hive, Isar, Drift/SQLite (эвристика по тексту ошибки), file system, common.

### nexo_core — UseCase

- **`NexoUseCase<T, Params>`** — абстрактный класс с `execute` и `call`: `Future<Result<T>>`, логирование (в т.ч. **`failure.code`**), перехват исключений и маппинг через `toFailure`.
- **`NexoStreamUseCase<T, Params>`** — `build` возвращает `Stream<T>`; `call` даёт `Stream<Result<T>>`.
- **`NoParams`** — для use case без параметров (см. `no_params.dart`).

### nexo_core — Bloc / Cubit

- **`NexoBloc<Event, State>`** / **`NexoCubit<State>`** — базовые классы с **`FailureSupport`**.
- Методы:
  - **`execute`** / **`executeEither`** — async-действие с опциональным loading, success, error.
  - **`subscribe`** / **`subscribeEither`** — подписка на потоки с маппингом ошибок в `Failure`.
- **`NexoCubit`** дополнительно: **`SubscriptionMixin`**, отмена подписок по ключу, `close` отменяет подписки.
- **`NexoBlocObserver`** — `BlocObserver` с логированием lifecycle / events / changes / errors через `NexoLogger`, фильтр `shouldLogBloc`, усечение длины логов; ошибки блоков автоматически пишутся в breadcrumbs crash-reporter'а.
- Вспомогательные файлы: `bloc_transformers.dart`, `optimistic_update_helper.dart`, `pagination_controller.dart`, `reconnecting_stream_service.dart`, `nexo_bloc_observer.dart`.

#### `NexoAsyncCubit<T>` — типовой экран в три строки

Готовый кубит «UseCase → состояние»: реализуйте `fetch()`, управляйте методами `load()` / `retry()` / `refresh()`, а состояние отображайте через `NexoAsyncStateBuilder`.

```dart
class UsersCubit extends NexoAsyncCubit<List<User>> {
  UsersCubit(this._getUsers);
  final GetUsersUseCase _getUsers;

  @override
  Future<Result<List<User>>> fetch() => _getUsers(NoParams());
}

context.read<UsersCubit>().load(); // -> Loading -> Success | Failure
```

Защита от устаревших ответов встроена, колбэк `onFailure` — для снекбаров вне дерева билда.

### nexo_core — Сеть

- **`HttpMethod`** + extension для строкового метода.
- **`DioClient`** — тонкая обёртка над `Dio`: `get/post/put/patch/delete/head/options`, `request`/`requestUri`, form-data, `download`, геттер **`config`** для отладки.
- **`NexoAuthInterceptor`** — Bearer-токен, refresh с дедупликацией через `Completer`, повтор запроса, флаги `skipAuth` / `_auth_retried`, колбэки логов.
- **`NexoRetryInterceptor`** — exponential backoff с джиттером, настраиваемые типы/коды/методы, `skipRetry`.
- **`NexoLoggingInterceptor`** — логирование запросов/ответов.
- **`NexoRequestIdInterceptor`** — correlation id в заголовке и логах.
- **`BaseRemoteDataSource`** — обёртка над `DioClient` с логированием ошибок для GET/POST/PUT/PATCH/DELETE/download/form-data.

### nexo_core — Локальные data source

- **`BaseHiveDataSource<T, ID>`** — инициализация box, операции с логированием ошибок.
- **`BaseIsarDataSource`** — `read`/`write`/`writeSync` с обработкой ошибок.
- **`BaseSharedPreferencesDataSource`** — типизированные get/set и JSON-хелперы с логированием.
- **`BaseSecureStorageDataSource`** — обёртка над `FlutterSecureStorage` (строки, JSON, удаление).

### Пагинация

- **`PageChunk<T, Cursor>`** — страница: элементы, следующий курсор, `hasMore`.
- **`PaginationController<T, Cursor>`** — накопление списка, `loadNext`, `reset`, `replaceAll`, защита от параллельной загрузки.

### Outbox — очередь офлайн-мутаций

Паттерн outbox: действие пользователя мгновенно попадает в локальную очередь (для UI это уже «успех»), а `flush()` доставляет его на сервер при появлении сети — строго в порядке постановки, с остановкой на первой ошибке.

```dart
final outbox = NexoOutbox(
  store: InMemoryOutboxStore(), // в проде: своя реализация OutboxStore поверх Hive/Isar/Drift
  send: (entry) => dio.post(entry.path, data: entry.payload),
);

await outbox.enqueue(path: '/posts', payload: {'title': 'Привет'});

// по возврату сети или на старте приложения:
final result = await outbox.flush();
if (!result.isComplete) showFailureSnackBar(context, result.failure!);
```

`OutboxEntry.id` используйте как ключ идемпотентности на сервере.

### Валидаторы форм

Готовые правила для `TextFormField.validator`: `requiredField`, `email`, `phone`, `url`, `number`, `minLength` / `maxLength`, `password` и композитор `compose`. Тексты — из каталога сообщений пакета (локализуются вместе с ним), имя поля подставляется через `fieldName:`, точечная замена текста — через `message:`.

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'Email'),
  validator: NexoValidators.compose([
    NexoValidators.requiredField(fieldName: 'Email'),
    NexoValidators.email(message: 'Проверьте адрес почты'),
  ]),
)
```

### nexo_ui

- **`NexoAsyncStateBuilder<T>`** — маппинг `NexoAsyncState` на UI; обязателен только `success`, у остальных веток разумные дефолты.
- **`NexoFailureView`** — иконка + `userMessage` + опциональный технический код + кнопка «Повторить».
- **`NexoEmptyView`**, **`NexoSkeletonLoader`** / **`NexoSkeletonList`** — пустое состояние и заглушки загрузки.
- **`showFailureSnackBar(context, failure)`** / **`showFailureDialog(...)`** — единообразный показ ошибок из `FailurePresenter`.
- **`NexoButton`**, **`NexoCard`**, гэпы `num.gapH` / `num.gapW`, цепочки обёрток (`pad`, `center`, `expanded`, …).

Типовой экран целиком:

```dart
NexoAsyncStateBuilder<List<User>>(
  state: state,
  loading: (_) => const NexoSkeletonList(itemCount: 4),
  success: (_, users) => UserList(users),
  failure: (_, failure) => NexoFailureView(
    failure: failure,
    onRetry: () => context.read<UsersCubit>().retry(),
  ),
)
```

### nexo_testing

Матчеры для тестов на базе пакета `matcher`:

```dart
import 'package:nexo/nexo_testing.dart';

expect(result, isSuccess(42));
expect(result, isFailure(code: 'network.no_internet'));
expect(failure, failureWithUserMessage('Нет подключения к интернету'));
final data = result.dataOrThrow(); // бросит StateError с кодом ошибки
```


## Минимальный пример

```dart
// 1. Логгер
final logger = TalkerLoggerAdapter(Talker());

// 2. UseCase
class GetUser extends NexoUseCase<User, String> {
  GetUser(super.logger);

  @override
  Future<User> execute(String userId) async {
    // repository / api
    throw Exception('fail'); // станет Failure через toFailure
  }
}

// 3. Cubit
class UserCubit extends NexoCubit<UserState> {
  UserCubit() : super(const UserInitial());

  Future<void> load(String id) => executeEither(
        action: () => GetUser(logger)(id),
        onLoading: () => const UserLoading(),
        onSuccess: (u) => UserLoaded(u),
        onError: (f) => UserError(f.userMessage),
      );
}

// 4. BlocObserver
Bloc.observer = NexoBlocObserver(
  logger,
  crashReporter: const NoOpNexoCrashReporter(),
  shouldLogBloc: (b) => b is UserCubit,
);
```

## Пример приложения

Каталог **`example/`** — демо-галерея с четырьмя вкладками: асинхронный экран (`NexoAsyncCubit` + `NexoAsyncStateBuilder` + skeleton/empty/failure), форма на `NexoValidators`, feedback-виджеты и живая очередь `NexoOutbox`. Запуск из корня репозитория:

```bash
cd example && flutter run
```

## CI и качество

В **`.github/workflows/ci.yml`**: `dart format`, `flutter analyze`, `flutter test` (пакет + example), `dart doc --validate-links lib`.

Локально:

```bash
dart format lib test
flutter analyze
flutter test
dart doc lib
```

## Тяжёлые / платформенные зависимости

Пакет тянет **Firebase**, **Hive**, **Isar**, **Secure storage** и др. Если приложению нужна только часть API, зависимости всё равно резолвятся целиком — для минимального footprint в перспективе имеет смысл вынести модули в отдельные pub-пакеты (например `nexo_network`, `nexo_errors`). **Isar 3** привязан к версии Flutter/Dart; при апгрейде SDK следите за совместимостью или планируйте миграцию хранилища.

## Лицензия

См. файл `LICENSE`.
