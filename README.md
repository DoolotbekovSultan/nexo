# nexo

Модульный набор утилит для Flutter-приложений: слой **UseCase**, единая модель **Failure**, маппинг ошибок, **Bloc/Cubit**-обёртки, **Dio** (клиент и интерцепторы), базовые **data source**-ы и **логирование**.

**Версия:** `0.0.4-beta.2`  
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
| `nexo_core` | UseCase, StreamUseCase, Bloc/Cubit, сеть (Dio), локальные/удалённые data source, пагинация, вспомогательные блок-хелперы |
| `nexo_errors` | `Failure` (sealed + Freezed), типизированные подтипы ошибок, `FailureMapper`, подмапперы (Dio, Hive, Isar, и т.д.) |
| `nexo_logger` | Абстракция `NexoLogger`, адаптер под **Talker** |

Рекомендуемые **barrel-импорты**:

```dart
import 'package:nexo/nexo.dart'; // всё сразу
// или точечно:
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';
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

- **`Result<T>`** и **`StreamResult<T>`** — typedef над `Either<Failure, T>` / потоком тех же значений. Сигнатуры **`NexoUseCase.call`**, **`NexoStreamUseCase.call`**, **`executeEither` / `subscribeEither`** в Bloc/Cubit используют `Result<T>`. Через `result.dart` реэкспортируются **`Either`**, **`Left`**, **`Right`** (отдельный `import dartz` в фичах часто не нужен).
- **`Failure.code`** — стабильная строка (`network.no_internet`, `http.unauthorized`, при `HttpFailure.unknown` и известном статусе — `http.status_502`) для Sentry, логов и бэкенда.
- **`NexoAsyncState<T>`** — sealed: `NexoAsyncIdle` / `NexoAsyncLoading` / `NexoAsyncSuccess` / `NexoAsyncFailure`; геттеры **`isIdle`**, **`isLoading`**, … и **`dataOrNull`**, **`failureOrNull`**.
- **`NexoUseCase.callWithRetry`** (extension) — повтор вызова с задержкой и `retryIf` либо **`Failure.isRetryable`**.
- **`fetchCacheThenNetwork`** / **`fetchNetworkThenCache`** — минимальный offline-first без лишних абстракций.
- **`FailurePresenter`** — `snackbarMessage`, `dialogTitle`, `dialogBody`, `technicalCode` (тонкий UI-слой; при необходимости замените своим классом в приложении).
- **`NexoCrashReporter`** + **`NoOpNexoCrashReporter`** — точка расширения для Crashlytics/Sentry.
- **`NexoFlutterErrors`** — `install` для `FlutterError.onError` и `PlatformDispatcher.instance.onError`, плюс **`runAppInZone`** для `runZonedGuarded` (лог + опциональный `NexoCrashReporter`, без UI). Внутри `runAppInZone` первым вызывайте **`WidgetsFlutterBinding.ensureInitialized`**, затем `runApp`, иначе будет zone mismatch.
- **`CollectingNexoCrashReporter`** — накопление ошибок в памяти (тесты).
- **`NexoRequestIdInterceptor`** — заголовок **`x-request-id`** и лог id на response/error.

**Сознательно не добавлялись** (чтобы не раздувать пакет): полноценный debug-overlay, жёсткий `NexoEnvironment` с пресетами URL (лучше в приложении), разбиение на несколько pub-пакетов без запроса на миграцию.

## Зависимости (основные)

- **Состояние:** `bloc`, `flutter_bloc`, `bloc_concurrency`, `stream_transform`
- **Функциональный стиль:** `dartz` (`Either`)
- **Сеть:** `dio`
- **Локальные хранилища:** `hive`, `isar`, `shared_preferences`, `flutter_secure_storage`, `path_provider`
- **Firebase (частично):** `firebase_core`, `firebase_auth`
- **Модели:** `freezed_annotation`, `json_annotation`
- **Логи:** `talker`
- **UI (в пакете объявлено):** `flutter_screenutil`

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
- **`NexoBlocObserver`** — `BlocObserver` с логированием lifecycle / events / changes / errors через `NexoLogger`, фильтр `shouldLogBloc`, усечение длины логов.
- Вспомогательные файлы: `bloc_transformers.dart`, `optimistic_update_helper.dart`, `pagination_controller.dart`, `reconnecting_stream_service.dart`, `nexo_bloc_observer.dart`.

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

Каталог **`example/`** — обычное Flutter-приложение с path-зависимостью на родительский пакет. Запуск из корня репозитория:

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
