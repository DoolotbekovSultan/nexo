# nexo

[![CI](https://github.com/DoolotbekovSultan/nexo/actions/workflows/ci.yml/badge.svg)](https://github.com/DoolotbekovSultan/nexo/actions/workflows/ci.yml)

Modular toolkit for Flutter apps: **UseCase** layer, sealed **`Result`**, unified **`Failure`** model with mapping and localization, ready-made **`NexoAsyncCubit`** and state widgets, offline mutation queue (**outbox**), form validators, **Bloc/Cubit** wrappers, **Dio** (client and interceptors), base **data sources**, **breadcrumbs** for crash reports, and **logging**.

**Version:** `0.0.7-beta.0`  
**SDK:** Dart `^3.11.3`, Flutter `>=1.17.0`

## Installation

Dependency from git or local path — depending on how you publish the package:

```yaml
dependencies:
  nexo:
    path: ../nexo  # or git: url + ref
```

```bash
flutter pub add nexo
# when publishing to pub.dev
```

### Code Generation

The `Failure` model is built on **Freezed**. After editing `failure.dart` or related types:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Repository Structure

Code is grouped under `lib/packages/` (these are **not** separate pub packages, but logical modules inside a single `nexo` package):

| Folder | Purpose |
|--------|---------|
| `nexo_core` | UseCase, `NexoAsyncCubit`, Bloc/Cubit, networking (Dio), local/remote data sources, pagination, outbox queue, form validators |
| `nexo_errors` | `Failure` (sealed + Freezed), error subtypes, `Result`, mappers (Dio, Hive, Isar, Drift, Firebase…), breadcrumbs, crash-reporter |
| `nexo_logger` | `NexoLogger` abstraction, **Talker** adapter |
| `nexo_ui` | State widgets (`NexoAsyncStateBuilder`, `NexoFailureView`, `NexoEmptyView`, skeletons), feedback (snackbar/dialogs), buttons/cards, gaps |
| `nexo_testing` | Test matchers: `isSuccess` / `isFailure`, `failureWithCode`, `failureWithUserMessage`, `dataOrThrow()` extension |

Recommended **barrel imports**:

```dart
import 'package:nexo/nexo.dart'; // everything
// or granular:
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:nexo/nexo_ui.dart';
import 'package:nexo/nexo_testing.dart'; // tests only
```

Deep imports are still allowed: `package:nexo/packages/nexo_core/...`.

> **Note:** Importing `nexo_core.dart` also re-exports `flutter_bloc` (Bloc, BlocProvider, RepositoryProvider, etc.).

### `Failure` Localization

By default **`userMessage`** returns Russian text. For English or custom copy, use **`FailureUserMessageCatalog`** and the **`localizedMessage`** extension:

```dart
import 'package:nexo/nexo_errors.dart';

failure.localizedMessage(const EnFailureUserMessages());
```

Custom catalog: implement `FailureUserMessageCatalog` and return strings from `forFailure`.

### Core: `Result`, error codes, async state

- **`Result<T>`** — custom sealed type (no dartz): branches **`Right<T>` / `Left<T>`**, factory aliases `Result.success(value)` / `Result.failure(failure)`. Named `fold(onFailure:, onSuccess:)`, `map`, `getOrElse`, `dataOrNull` / `failureOrNull`, value-equality and **exhaustive pattern matching**:
  ```dart
  final text = switch (result) {
    Right(:final value) => 'Data: $value',
    Left(:final failure) => failure.userMessage,
  };
  ```
  Convenience methods: `orElse`, `tap`, `mapFailure`, `flatMap`, `when`.
- **`Failure.code`** — stable string (`network.no_internet`, `http.unauthorized`) for Sentry, logs and backend; network/HTTP errors automatically receive **`requestId`** from `x-request-id`.
- **`NexoAsyncState<T>`** — sealed: `NexoAsyncIdle` / `NexoAsyncLoading` / `NexoAsyncSuccess` / `NexoAsyncFailure`; getters `isIdle`, `isLoading`, … and `dataOrNull`, `failureOrNull`.
- **`NexoUseCase.callWithRetry`** — retry with exponential backoff via `retryIf` or `Failure.isRetryable`.
- **`fetchCacheThenNetwork`** / **`fetchNetworkThenCache`** — minimal offline-first.
- **`FailurePresenter`** — texts for snackbar / dialog; used by built-in feedback widgets.
- **`NexoCrashReporter`** + **breadcrumbs** — extension point for Crashlytics/Sentry: `recordBreadcrumb(NexoBreadcrumb(...))` writes an event to the feed attached to the report; bloc errors are automatically captured via `NexoBlocObserver`.
- **`NexoFlutterErrors`** — `install` for `FlutterError.onError` and `PlatformDispatcher.instance.onError`, plus **`runAppInZone`** (call `WidgetsFlutterBinding.ensureInitialized()` first, then `runApp` inside).
- **`CollectingNexoCrashReporter`** — in-memory error accumulation and ring buffer of breadcrumbs (for tests).
- **`NexoRequestIdInterceptor`** — `x-request-id` header, id in logs and `requestId` fields on errors.

**Intentionally not included** (to keep the package lean): full debug-overlay, rigid `NexoEnvironment` with URL presets (better in the app), splitting into multiple pub packages without a migration request.

## Dependencies (main)

- **State:** `bloc`, `flutter_bloc`, `bloc_concurrency`, `stream_transform`
- **Networking:** `dio`
- **Local storage:** `hive`, `isar`, `shared_preferences`, `flutter_secure_storage`, `path_provider`
- **Firebase (partial):** `firebase_core`, `firebase_auth`
- **Models:** `freezed_annotation`, `json_annotation`
- **Logging:** `talker`
- **Testing (nexo_testing module):** `matcher`

## Modules and Public API

### nexo_logger

- **`NexoLogger`** — abstract contract: `debug`, `info`, `warning`, `error`.
- **`TalkerLoggerAdapter`** — implementation via `Talker`.

Pass `NexoLogger` to use cases and data sources for consistent logging.

### nexo_errors

- **`Failure`** — sealed class with variants: network, HTTP, auth, validation, storage, database, cache, parse, permissions, platform, file, location, notification, payment, sync, unknown.
- Handy getters: **`userMessage`** (Russian by default), **`localizedMessage`**, **`isRetryable`**, **`requiresLogout`**, **`requiresSettings`**, **`logCategory`**.
- **`Failure.code`** — stable code for analytics (see "Core" section above).
- **`FailureMapper2`** — расширяемый маппер ошибок с поддержкой DI:
  - `register(mapper)` / `registerAll(mappers)` — регистрация кастомных мапперов.
  - Кастомные мапперы имеют приоритет над встроенными.
  - `fromStatic()` для обратной совместимости.
- **`FailureMapper.from(error, stackTrace?)`** — deprecated, делегирует в `FailureMapper2`.
- **`Object.toFailure([stackTrace])`** — extension (declared in `failure_mapper_extension.dart`).
- **`Result<T>`**, **`StreamResult<T>`**, **`FailurePresenter`**, **`NexoCrashReporter`**.

Sub-mappers (order in `FailureMapper2`): domain exceptions (с `extraMappings`), Firebase Auth, Firebase Messaging, Dio, platform, Hive (stackTrace-based), Isar (stackTrace-based), Drift (stackTrace-based), file system, common.

### nexo_core — UseCase

- **`NexoUseCase<T, Params>`** — abstract class with `execute` and `call`: `Future<Result<T>>`, logging (including **`failure.code`**), exception catching and mapping via `toFailure`.
- **`NexoStreamUseCase<T, Params>`** — `build` returns `Stream<T>`; `call` gives `Stream<Result<T>>`.
- **`NoParams`** — for parameterless use cases (see `no_params.dart`).
- **`@NexoUseCaseAnnotation`** — codegen аннотация для генерации implementation (генератор в `nexo_generator`):
  ```dart
  @NexoUseCaseAnnotation(repo: IUserRepository)
  abstract class GetUserUseCase {
    Future<User> execute(GetUserParams params);
  }
  // dart run build_runner build -> @injectable class GetUserUseCaseImpl
  ```

### nexo_core — Bloc / Cubit

- **`NexoBloc<Event, State>`** / **`NexoCubit<State>`** — base classes with **`FailureSupport`**.
- Methods:
  - **`execute`** / **`executeEither`** — async action with optional loading, success, error.
  - **`executeMutation`** — обёртка для мутаций (create/update/delete) с чтением текущего state.
  - **`loadData<T>()`** — упрощённая загрузка данных с автоматическим loading/success/error.
  - **`subscribe`** / **`subscribeEither`** — stream subscription with error mapping to `Failure`.
- **`NexoCubit`** additionally: **`SubscriptionMixin`**, keyed subscription cancellation, `close` cancels subscriptions.
- **`NexoBlocObserver`** — `BlocObserver` with lifecycle / events / changes / errors logging via `NexoLogger`, `shouldLogBloc` filter, log truncation; bloc errors are automatically written to crash-reporter breadcrumbs.
- Helper files: `bloc_transformers.dart`, `optimistic_update_helper.dart`, `pagination_controller.dart`, `reconnecting_stream_service.dart`, `nexo_bloc_observer.dart`.

#### `NexoAdminCrudBloc<T>` — generic CRUD для админ-панелей

```dart
@injectable
class AdminFilmsBloc extends NexoAdminCrudBloc<FilmDto> {
  AdminFilmsBloc({
    required FilmRepository repository,
    required String token,
  }) : super(repository: repository, token: token, path: 'films');
}
```

- Автоматические обработчики: load, search, create, delete.
- `executeMutation()` — обёртка для мутаций с чтением текущего state.
- `NexoCrudState<T>` — sealed: loading, ready, error.

#### `NexoPaginatedMixin<T, Cursor>` — cursor-based пагинация

```dart
class ClipsFeedBloc extends NexoBloc<ClipsFeedEvent, ClipsFeedState>
    with NexoPaginatedMixin<ClipFeedEntity, int> {
  // loadMore(emit, loader, onReady) — автоматический emit loading/ready/error
}
```

#### `NexoAsyncCubit<T>` — screen in three lines

Ready-made cubit "UseCase → state": implement `fetch()`, manage via `load()` / `retry()` / `refresh()`, render state with `NexoAsyncStateBuilder`.

```dart
class UsersCubit extends NexoAsyncCubit<List<User>> {
  UsersCubit(this._getUsers);
  final GetUsersUseCase _getUsers;

  @override
  Future<Result<List<User>>> fetch() => _getUsers(NoParams());
}

context.read<UsersCubit>().load(); // -> Loading -> Success | Failure
```

Stale response protection is built-in, `onFailure` callback — for snackbars outside the build tree.

### nexo_core — Networking

- **`HttpMethod`** + extension for string method.
- **`DioClient`** — thin wrapper over `Dio`: `get/post/put/patch/delete/head/options`, `request`/`requestUri`, form-data, `download`, **`config`** getter for debugging.
- **`NexoAuthInterceptor`** — Bearer token, refresh with deduplication via `Completer`, request retry, `skipAuth` / `_auth_retried` flags, log callbacks.
- **`NexoRetryInterceptor`** — exponential backoff with jitter, configurable types/codes/methods, `skipRetry`.
- **`NexoLoggingInterceptor`** — request/response logging.
- **`NexoRequestIdInterceptor`** — correlation id in header and logs.
- **`BaseRemoteDataSource`** — wrapper over `DioClient` with error logging for GET/POST/PUT/PATCH/DELETE/download/form-data.

### nexo_core — Local data sources

- **`BaseHiveDataSource<T, ID>`** — box initialization, operations with error logging.
- **`BaseIsarDataSource`** — `read`/`write`/`writeSync` with error handling.
- **`BaseSharedPreferencesDataSource`** — typed get/set and JSON helpers with logging.
- **`BaseSecureStorageDataSource`** — wrapper over `FlutterSecureStorage` (strings, JSON, deletion).

### Pagination

- **`PageChunk<T, Cursor>`** — page: items, next cursor, `hasMore`.
- **`PaginationController<T, Cursor>`** — list accumulation, `loadNext`, `reset`, `replaceAll`, parallel load protection.

### Outbox — offline mutation queue

Outbox pattern: user action immediately goes into a local queue (for UI this is already "success"), and `flush()` delivers it to the server when network appears — strictly in insertion order, stopping on the first error.

```dart
final outbox = NexoOutbox(
  store: InMemoryOutboxStore(), // in prod: your OutboxStore implementation over Hive/Isar/Drift
  send: (entry) => dio.post(entry.path, data: entry.payload),
);

await outbox.enqueue(path: '/posts', payload: {'title': 'Hello'});

// on network restore or app start:
final result = await outbox.flush();
if (!result.isComplete) showFailureSnackBar(context, result.failure!);
```

Use `OutboxEntry.id` as an idempotency key on the server.

### Form Validators

Ready-made rules for `TextFormField.validator`: `requiredField`, `email`, `phone`, `url`, `number`, `minLength` / `maxLength`, `password` and `compose` composer. Texts come from the package's message catalog (localized together), field name is injected via `fieldName:`, text replacement via `message:`.

```dart
TextFormField(
  decoration: const InputDecoration(labelText: 'Email'),
  validator: NexoValidators.compose([
    NexoValidators.requiredField(fieldName: 'Email'),
    NexoValidators.email(message: 'Check your email address'),
  ]),
)
```

### nexo_ui

- **`NexoAsyncStateBuilder<T>`** — maps `NexoAsyncState` to UI; only `success` is required, other branches have sensible defaults.
- **`NexoFailureView`** — icon + `userMessage` + optional technical code + "Retry" button.
- **`NexoEmptyView`**, **`NexoSkeletonLoader`** / **`NexoSkeletonList`** — empty state and loading placeholders.
- **`showFailureSnackBar(context, failure)`** / **`showFailureDialog(...)`** — uniform error display from `FailurePresenter`.
- **`NexoButton`**, **`NexoCard`**, gaps `num.gapH` / `num.gapW`, wrapper chains (`pad`, `center`, `expanded`, …).

Complete screen example:

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

Test matchers based on the `matcher` package:

```dart
import 'package:nexo/nexo_testing.dart';

expect(result, isSuccess(42));
expect(result, isFailure(code: 'network.no_internet'));
expect(failure, failureWithUserMessage('No internet connection'));
final data = result.dataOrThrow(); // throws StateError with error code
```

## Minimal Example

```dart
// 1. Logger
final logger = TalkerLoggerAdapter(Talker());

// 2. UseCase
class GetUser extends NexoUseCase<User, String> {
  GetUser(super.logger);

  @override
  Future<User> execute(String userId) async {
    // repository / api
    throw Exception('fail'); // becomes Failure via toFailure
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

## Example App

The **`example/`** directory is a demo gallery with four tabs: async screen (`NexoAsyncCubit` + `NexoAsyncStateBuilder` + skeleton/empty/failure), form with `NexoValidators`, feedback widgets, and live `NexoOutbox` queue. Run from the repository root:

```bash
cd example && flutter run
```

## CI and Quality

In **`.github/workflows/ci.yml`**: `dart format`, `flutter analyze`, `flutter test` (package + example), `dart doc --validate-links lib`.

Locally:

```bash
dart format lib test example/lib
flutter analyze
flutter test
dart doc lib
```

## Heavy / Platform Dependencies

The package pulls **Firebase**, **Hive**, **Isar**, **Secure storage**, etc. If your app only needs part of the API, dependencies still resolve fully — for minimal footprint consider splitting modules into separate pub packages (e.g. `nexo_network`, `nexo_errors`). **Isar 3** is tied to specific Flutter/Dart versions; when upgrading SDK, check compatibility or plan storage migration.

## License

See [LICENSE](LICENSE).
