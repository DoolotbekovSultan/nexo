# nexo

[![CI](https://github.com/DoolotbekovSultan/nexo/actions/workflows/ci.yml/badge.svg)](https://github.com/DoolotbekovSultan/nexo/actions/workflows/ci.yml)

Modular toolkit for Flutter apps: **UseCase** layer, sealed **`Result`**, unified **`Failure`** model with mapping and localization, ready-made **`NexoAsyncCubit`** and state widgets, offline mutation queue (**outbox**), form validators, **Bloc/Cubit** wrappers, **Dio** (client and interceptors), base **data sources**, **breadcrumbs** for crash reports, and **logging**.

**Version:** `0.1.0`
**SDK:** Dart `^3.11.3`, Flutter `>=1.17.0`

## Installation

```yaml
dependencies:
  nexo: ^0.1.0
```

```bash
flutter pub add nexo
```

Or install individual packages for a minimal dependency footprint:

```yaml
dependencies:
  nexo_logger: ^0.1.0        # just logging
  nexo_errors: ^0.1.0        # Failure + Result
  nexo_bloc: ^0.1.0          # BLoC/Cubit wrappers
  nexo_network: ^0.1.0       # Dio client + interceptors
  # ... etc
```

## Package Structure

The monolith has been split into 15 independent packages:

```
nexo (umbrella — re-exports all)
├── nexo_logger              Logger abstraction + Talker adapter
├── nexo_errors              Failure, Result, mappers, localization
├── nexo_core                Shared types: NoParams, NexoUseCaseAnnotation, NexoAsyncState
├── nexo_validation          Form validators
├── nexo_network             DioClient, interceptors, offline strategies
├── nexo_datasource          Base datasource abstractions (remote + local)
├── nexo_usecase             NexoUseCase, NexoStreamUseCase, retry
├── nexo_bloc                NexoBloc, NexoCubit, NexoAsyncCubit, helpers
├── nexo_sync                NexoOutbox (offline mutation queue)
├── nexo_ui                  Widgets, state builders, extensions
├── nexo_testing             Test matchers for Failure and Result
├── nexo_errors_firebase     Firebase Auth + Messaging mappers (optional)
├── nexo_errors_hive         Hive mapper (optional)
├── nexo_errors_isar         Isar mapper (optional)
└── nexo_errors_drift        Drift/SQLite mapper (optional)
```

### Dependency Graph

```
nexo_logger ─────────────────────────────────────────────┐
       │                                                  │
       ▼                                                  │
nexo_errors ─────────────────┐                            │
       │                     │                            │
       ▼                     ▼                            │
  nexo_core            nexo_network                       │
       │                     │                            │
       ├──► nexo_usecase     ├──► nexo_datasource         │
       ├──► nexo_bloc                                  ◄──┘
       ├──► nexo_sync
       ├──► nexo_validation
       └──► nexo_ui ─────────────────────────────────────┘

nexo_errors_firebase / nexo_errors_hive / nexo_errors_isar / nexo_errors_drift
  └──► nexo_errors (optional, register via FailureMapper)
```

## Imports

```dart
// Everything (umbrella):
import 'package:nexo/nexo.dart';

// Granular:
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:nexo/nexo_ui.dart';
import 'package:nexo/nexo_testing.dart'; // tests only

// Direct package imports (also work):
import 'package:nexo_bloc/nexo_bloc.dart';
import 'package:nexo_network/nexo_network.dart';
import 'package:nexo_usecase/nexo_usecase.dart';
```

> **Backward compatibility:** `import 'package:nexo/nexo.dart'` re-exports all sub-packages. Existing code continues to work.

## Modules

### nexo_logger

- **`NexoLogger`** — abstract contract: `debug`, `info`, `warning`, `error`.
- **`TalkerLoggerAdapter`** — implementation via `Talker`.

### nexo_errors

- **`Failure`** — sealed class with 16 variants (network, HTTP, auth, validation, storage, database, cache, parse, permissions, platform, file, location, notification, payment, sync, unknown).
- **`Result<T>`** — custom sealed type: `Right<T>` / `Left<T>`, `fold`, `map`, `getOrElse`, value-equality.
- **`FailureMapper`** — extensible error mapper with DI support. Platform-agnostic mappers built-in; Firebase/Hive/Isar/Drift mappers available as optional packages.
- **`Object.toFailure()`** — extension method.
- **`FailurePresenter`** — texts for snackbar / dialog.
- **`NexoCrashReporter`** + **breadcrumbs** — extension point for Crashlytics/Sentry.
- **`NexoFlutterErrors`** — global error handler + `runAppInZone`.

### nexo_core

- **`NoParams`** — empty parameter class for UseCases.
- **`@NexoUseCaseAnnotation`** — codegen annotation.
- **`NexoAsyncState<T>`** — sealed: Idle / Loading / Success / Failure.

### nexo_usecase

- **`NexoUseCase<T, Params>`** — abstract class with `execute` and `call`: `Future<Result<T>>`.
- **`NexoStreamUseCase<T, Params>`** — `build` returns `Stream<T>`; `call` gives `Stream<Result<T>>`.
- **`callWithRetry`** — retry with exponential backoff.

### nexo_bloc

- **`NexoBloc<Event, State>`** / **`NexoCubit<State>`** — base classes with `FailureSupport`.
- **`NexoAsyncCubit<T>`** — ready-made cubit: implement `fetch()`, call `load()` / `retry()` / `refresh()`.
- **`NexoBlocObserver`** — lifecycle logging + crash-reporter breadcrumbs.
- Helpers: `bloc_transformers`, `optimistic_update_helper`, `pagination_controller`, `reconnecting_stream_service`, `subscription_mixin`.

### nexo_network

- **`DioClient`** — typed wrapper over Dio.
- **`NexoAuthInterceptor`** — Bearer token, refresh with deduplication.
- **`NexoRetryInterceptor`** — exponential backoff with jitter.
- **`NexoLoggingInterceptor`** — request/response logging with sensitive data masking.
- **`NexoRequestIdInterceptor`** — correlation id.
- **`fetchCacheThenNetwork`** / **`fetchNetworkThenCache`** — offline-first strategies.

### nexo_datasource

- **`BaseRemoteDataSource`** — wrapper over DioClient.
- **`BaseHiveDataSource<T, ID>`**, **`BaseIsarDataSource`**, **`BaseSharedPreferencesDataSource`**, **`BaseSecureStorageDataSource`**.

### nexo_validation

- **`NexoValidators`** — `requiredField`, `email`, `phone`, `url`, `number`, `minLength` / `maxLength`, `password`, `compose`.

### nexo_sync

- **`NexoOutbox`** — offline mutation queue with outbox pattern.

### nexo_ui

- **`NexoAsyncStateBuilder<T>`** — maps `NexoAsyncState` to UI.
- **`NexoFailureView`**, **`NexoEmptyView`**, **`NexoSkeletonLoader`**.
- **`showFailureSnackBar`** / **`showFailureDialog`**.
- **`NexoButton`**, **`NexoCard`**, gaps, widget wrappers.

### nexo_testing

- **`isSuccess`** / **`isFailure`** — matchers for `Result`.
- **`failureWithCode`** / **`failureWithUserMessage`** — matchers for `Failure`.
- **`dataOrThrow()`** / **`failureOrThrow()`** — extensions.

### Optional Error Mappers

Install only what you need:

```yaml
dependencies:
  nexo_errors_firebase: ^0.1.0  # Firebase Auth + Messaging
  nexo_errors_hive: ^0.1.0      # Hive
  nexo_errors_isar: ^0.1.0      # Isar
  nexo_errors_drift: ^0.1.0     # Drift/SQLite
```

```dart
import 'package:nexo_errors_firebase/nexo_errors_firebase.dart';

final mapper = FailureMapper(
  extraMappers: [FirebaseAuthFailureMapper(), FirebaseMessagingFailureMapper()],
);
```

## Code Generation

The `Failure` model is built on **Freezed**. After editing `failure.dart`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Example App

```bash
cd example && flutter run
```

## CI and Quality

```bash
dart format lib test example/lib
flutter analyze
flutter test
dart doc --validate-links lib
```

## License

See [LICENSE](LICENSE).
