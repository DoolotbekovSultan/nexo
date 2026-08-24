# Changelog

## 0.0.6-beta.0

- **Breaking**: `Result<T>` — собственный sealed-тип вместо `Either<Failure, T>` из dartz:
  - те же короткие имена веток `Right<T>` / `Left<T>`; фабрики-алиасы `Result.success(value)` / `Result.failure(failure)`;
  - именованный `fold(onFailure:, onSuccess:)` — порядок веток больше нельзя перепутать;
  - хелперы `isSuccess` / `isFailure`, `dataOrNull` / `failureOrNull`, `map`, `getOrElse`;
  - исчерпывающий паттерн-матчинг по sealed-классу (`switch (result) { case Right(:final value) ... }`);
  - value-equality у обеих веток (удобно в тестах: `expect(result, const Right(42))`);
  - зависимость `dartz` удалена, её типы (`Either`, `Left`, `Right` из dartz) больше не экспортируются.
  - Миграция: позиционный `fold((l), (r))` → `fold(onFailure:, onSuccess:)`; остальной код на `Right`/`Left` совместим.
- Новый модуль **`nexo_testing`** (`lib/nexo_testing.dart`) — матчеры для тестов на базе пакета `matcher`:
  - `isSuccess([value])` / `isFailure(code:)` для `Result`;
  - `failureWithCode(code)` / `failureWithUserMessage(text)` для `Failure`;
  - расширения `dataOrThrow()` / `failureOrThrow()`.
- `nexo_ui`: новые виджеты **`NexoAsyncStateBuilder`** (маппинг `NexoAsyncState` на UI с дефолтами idle/loading/failure) и **`NexoFailureView`** (иконка + `userMessage` + опциональный технический код + кнопка «Повторить»).
- `nexo_core`: новый **`NexoAsyncCubit<T>`** — готовый кубит типового экрана: реализуйте `fetch()`, вызывайте `load()` / `retry()` / `refresh()` (тихое обновление без спиннера), состояние — `NexoAsyncState`; встроенная защита от устаревших ответов и колбэк `onFailure`.
- `nexo_ui`: **`showFailureSnackBar`** / **`showFailureDialog`** (тексты из `FailurePresenter`, опциональный retry), **`NexoEmptyView`** (заглушка пустого состояния с действием) и **`NexoSkeletonLoader` / `NexoSkeletonList`** (пульсирующие заглушки загрузки).
- `nexo_errors`: **requestId в ошибках** — `DioFailureMapper` теперь прокидывает `x-request-id` (ключ `nexoRequestIdExtraKey` из `extra`) в поля `requestId` у `NetworkAppFailure` / `HttpAppFailure`, чтобы связывать ошибки UI с логами и сервером; `NexoRequestIdInterceptor.extraRequestIdKey` использует тот же общий ключ.
- `nexo_core`: **безопасность логов** — `NexoLoggingInterceptor` маскирует чувствительные query-параметры URL (`/items?access_token=…`) во всех фазах (запрос / ответ / ошибка); раньше токен мог попасть в лог открытым.
- `nexo_core`: новый **`NexoOutbox`** — очередь офлайн-мутаций (паттерн outbox): `enqueue()` мгновенно кладёт действие в очередь (для UI это уже «успех»), `flush()` последовательно доставляет операции строго в порядке постановки и останавливается на первой ошибке, возвращая маппнутый `Failure` (`OutboxFlushResult`). Хранилище подключается через интерфейс `OutboxStore` (готовая `InMemoryOutboxStore`; для продакшена — реализация поверх Hive / Isar / Drift через готовые датасорсы пакета). Поле `OutboxEntry.id` предназначено для ключа идемпотентности на сервере.
- `nexo_core`: новые **`NexoValidators`** — готовые валидаторы форм (`requiredField`, `email`, `phone`, `url`, `number`, `minLength` / `maxLength`, `password`, композитор `compose`). Тип `NexoValidator<T> = String? Function(T?)` совместим с `FormFieldValidator` — подходит напрямую в `TextFormField.validator`; `null` считается пустым значением. Тексты ошибок берутся из каталога сообщений пакета (включая подстановку имени поля через `fieldName:`) и локализуются вместе с ним; каждое правило принимает `message:` для полного переопределения текста.
- `example`: демо-галерея из четырёх вкладок — асинхронный экран (`NexoAsyncCubit` + `NexoAsyncStateBuilder` + skeleton/empty/failure), форма на `NexoValidators`, feedback-виджеты (`showFailureSnackBar` / `showFailureDialog`, локализация, заглушки) и живая очередь `NexoOutbox` с офлайн-переключателем.

## 0.0.5-beta.1

- Новый модуль **`nexo_ui`** (ранее WIP за `.gitignore`, теперь часть публичного API):
  - `gap.dart`: расширения **`num.gapH` / `num.gapW`** — спейсеры для `Column`/`Row` с масштабированием через ScreenUtil (требует инициализации `ScreenUtilInit`);
  - `widget_wrappers.dart`: цепочки обёрток виджетов — `pad` / `padSymmetric` / `padOnly`, `center`, `align`, `expanded`, `flexible`, `sized`, `aspectRatio`, `opacity`, `safeArea`, `clipRRect`, `decorated`, `onTap`;
  - `text_wrapper.dart`: `'строка'.text(...)` — быстрое создание `Text`;
  - компоненты **`NexoButton`** (варианты filled/outlined/text, состояние загрузки, иконка) и **`NexoCard`** (рамка, тень, нажатие);
- Баррел `lib/nexo_ui.dart`; модуль также экспортируется из зонтичного `package:nexo/nexo.dart`.

## 0.0.4-beta.4

- **Web-совместимость `nexo_errors`**: мапперы больше не импортируют `dart:io` напрямую.
  Новые probe-хелперы (`platform_exceptions.dart`) через conditional imports определяют
  `SocketException` / `HandshakeException` / `TlsException` / `HttpException` /
  `FileSystemException` на VM и возвращают «не совпадает» на вебе, где эти типы недоступны.
- **`DioFailureMapper`**: добавлен кейс `DioExceptionType.transformTimeout` (появился в dio 5.10;
  dart2js требует исчерпывающий switch по enum — без кейса веб-сборка падала).
- Констрейнт dio поднят до `^5.10.0`.

## 0.0.4-beta.3

- Metadata refresh and republish for current stable Flutter/Dart compatibility.
- Includes recent core, error handling, and CLI generator improvements.

## 0.0.4-beta.2

- Документация и примеры: `WidgetsFlutterBinding.ensureInitialized` и `runApp` должны вызываться **внутри** тела [`runAppInZone`](lib/packages/nexo_errors/nexo_flutter_errors.dart), иначе Flutter сообщает о zone mismatch.

## 0.0.4-beta.1

- Добавлен [`NexoFlutterErrors`](lib/packages/nexo_errors/nexo_flutter_errors.dart): глобальные `FlutterError.onError`, `PlatformDispatcher.instance.onError`, опционально зона через `runAppInZone`; интеграция с `NexoLogger` и `NexoCrashReporter` (без UI).
- [`NexoBlocObserver`](lib/packages/nexo_core/bloc/nexo_bloc_observer.dart): опциональный `crashReporter` для дублирования ошибок BLoC в отчётность.
- Добавлен [`CollectingNexoCrashReporter`](lib/packages/nexo_errors/collecting_nexo_crash_reporter.dart) для тестов.

## 0.0.3-beta.1

- Предыдущая публичная версия.
