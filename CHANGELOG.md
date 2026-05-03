# Changelog

## 0.0.3-beta.1

* **`Result<T>` / `StreamResult<T>`** — typedef над `Either<Failure, T>`; публичные сигнатуры UseCase/Bloc используют `Result`; из `result.dart` реэкспорт `Either`, `Left`, `Right` для удобства.
* **`Failure.code`** — стабильные строки (`network.no_internet`, `http.status_502`, …) для аналитики и отчётов.
* **`NexoAsyncState<T>`** — sealed `idle` / `loading` / `success` / `failure` + расширение `dataOrNull` / `failureOrNull`.
* **`NexoUseCase.callWithRetry`** — extension с backoff и `retryIf` / `Failure.isRetryable`.
* **`fetchCacheThenNetwork` / `fetchNetworkThenCache`** — offline-first хелперы.
* **`FailurePresenter`** — snackbar / dialog / technical copy без логики в `Failure`.
* **`NexoCrashReporter` / `NoOpNexoCrashReporter`** — абстракция под Crashlytics/Sentry.
* **`NexoRequestIdInterceptor`** — заголовок `x-request-id` и лог по id.
* `NexoBlocObserver` логирует `failure.code` вместе с сообщением.

## 0.0.2-beta.1

* Barrel exports: `package:nexo/nexo.dart`, `nexo_core.dart`, `nexo_errors.dart`, `nexo_logger.dart`.
* Localized failure messages: `FailureUserMessageCatalog`, `RuFailureUserMessages`, `EnFailureUserMessages`, and `FailureUserMessageX.localizedMessage` (default `userMessage` remains Russian).
* `BaseSecureStorageDataSource` on top of `flutter_secure_storage`.
* Example Flutter app under `example/`.
* CI workflow (format, analyze, tests, `dart doc`).
* Unit tests for `FailureMapper`, `PaginationController`, catalogs, and `NexoUseCase`.
* Repository URL in `pubspec.yaml` updated to the real GitHub remote.

## 0.0.1

* Initial toolkit: Bloc/Cubit helpers, `Failure` + mappers, Dio client and interceptors, local/remote data sources, logging.
