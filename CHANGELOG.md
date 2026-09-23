# Changelog

## 0.1.0

### Package Split — монолит разделён на 15 независимых пакетов

**Breaking:** код больше не лежит в `lib/packages/`. Все модули вынесены в отдельные пакеты под `packages/`:

| Пакет | Ответственность |
|-------|----------------|
| `nexo_logger` | Абстракция `NexoLogger` + `TalkerLoggerAdapter` |
| `nexo_errors` | `Failure`, `Result`, мапперы, локализация, crash reporter |
| `nexo_core` | Общие типы: `NoParams`, `NexoUseCaseAnnotation`, `NexoAsyncState` |
| `nexo_validation` | `NexoValidators` (form validation) |
| `nexo_network` | `DioClient`, interceptors, offline strategies |
| `nexo_datasource` | Базовые abstract datasource'ы (remote + local) |
| `nexo_usecase` | `NexoUseCase`, `NexoStreamUseCase`, retry |
| `nexo_bloc` | `NexoBloc`, `NexoCubit`, `NexoAsyncCubit`, helpers |
| `nexo_sync` | `NexoOutbox` (offline mutation queue) |
| `nexo_ui` | Виджеты, extensions, gaps |
| `nexo_testing` | Матчеры для `Failure` и `Result` |
| `nexo_errors_firebase` | Firebase Auth + Messaging мапперы (optional) |
| `nexo_errors_hive` | Hive маппер (optional) |
| `nexo_errors_isar` | Isar маппер (optional) |
| `nexo_errors_drift` | Drift/SQLite маппер (optional) |

**Обратная совместимость:** `import 'package:nexo/nexo.dart'` продолжает работать — umbrella-пакет re-export'ит все дочерние.

### FailureMapper — cleanup

- **Удалён** deprecated `FailureMapper` (old).
- **`FailureMapper2` → `FailureMapper`** — переименован, принимает опциональный `builtInMappers`.
- **Platform-agnostic по дефолту** — встроенные мапперы: `DomainExceptionFailureMapper`, `DioFailureMapper`, `PlatformFailureMapper`, `FileSystemFailureMapper`, `CommonFailureMapper`.
- **Firebase/Hive/Isar/Drift мапперы** вынесены в отдельные optional пакеты (`nexo_errors_firebase`, `nexo_errors_hive`, `nexo_errors_isar`, `nexo_errors_drift`). Проекты без Firebase/Hive/Isar больше не тянут эти зависимости.

### Зависимости

- `firebase_auth`, `firebase_core`, `hive`, `isar` удалены из корневого `pubspec.yaml` (теперь в отдельных пакетах).
- Каждый дочерний пакет имеет свой `pubspec.yaml` с минимальным набором зависимостей.

## 0.0.8-beta.0

### nexo_core — BLoC/Cubit адаптация под Result<T>

- **`executeMutation<T>()`** — теперь принимает `Future<Result<T>>` вместо throw:
  ```dart
  await executeMutation(
    emit: emit,
    action: () => _repository.create(_token, payload),  // Result<Film>
    onSuccess: (film) { ... },
    onError: (f) { ... },
  );
  ```

- **`loadData<T>()`** — теперь принимает `Future<Result<T>>`:
  ```dart
  await loadData<User>(
    emit: emit,
    action: () => _getUserUseCase(id),  // Result<User>
    toState: (data) => State.ready(data: data),
    toError: (f) => State.error(failure: f),
  );
  ```

- **`NexoCrudState<T, F>`** — generic feedback вместо `String?`:
  ```dart
  typedef FilmCrudState = NexoCrudState<FilmDto, AdminFeedback>;
  ```

- **`NexoAdminCrudBloc<T, F>`** — наследует `NexoBloc`, generic feedback:
  ```dart
  class AdminFilmsBloc extends NexoAdminCrudBloc<FilmDto, AdminFeedback> {
    @override
    AdminFeedback buildSuccessFeedback(String msg) => AdminFeedback.success(msg);
    @override
    AdminFeedback buildErrorFeedback(String msg) => AdminFeedback.error(msg);
  }
  ```

- **`NexoPaginatedMixin`** — убрано ограничение `on Bloc<Object, Object>`, работает с любым `NexoBloc<Event, State>`.

### Codegen

- Настроен `build_runner` для `@NexoUseCaseAnnotation`.
- Добавлена dev-зависимость `source_gen: ^4.2.4`.

## 0.0.7-beta.0

### nexo_core — BLoC/Cubit улучшения

- **`executeMutation()`** — обёртка для мутаций (create/update/delete) в `NexoBloc` и `NexoCubit`:
  ```dart
  await executeMutation(
    emit: emit,
    action: () => _repository.create(_token, payload),
    onSuccess: () { _emitReady(emit, feedback: 'Создано'); },
    onError: (f) { _emitReady(emit, feedback: f.userMessage); },
  );
  ```

- **`loadData<T>()`** — упрощённая загрузка данных в `NexoBloc` и `NexoCubit`:
  ```dart
  await loadData<User>(
    emit: emit,
    action: () => _getUserUseCase(id),
    toState: (data) => State.ready(data: data),
    toError: (f) => State.error(failure: f),
    onLoading: () => const State.loading(),
  );
  ```

### nexo_errors — Result convenience methods

- **`orElse(fn)`** — значение при успехе, иначе дефолт.
- **`tap(onSuccess:, onFailure:)`** — side-effect без трансформации.
- **`mapFailure(fn)`** — трансформация только Failure.
- **`flatMap(fn)`** — chaining: если success — применяет fn.
- **`when(success:, onFailure:)`** — паттерн-матчинг без fold.

### nexo_core — NexoValidators расширение

- **`hasUpperAndDigit()`** — проверка заглавной буквы и цифры.
- **`hasSpecialChar()`** — проверка спецсимвола.
- **`matches(pattern)`** — проверка по regex.
- **`matchesField(other)`** — зависимая валидация (совпадение полей).

### nexo_testing — новые матчеры

- **`isRight()` / `isLeft()`** — алиасы для `isSuccess`/`isFailure`.
- **`hasFailureCode()` / `hasFailureMessage()` / `hasFailureType()`** — матчеры для Failure.
- **`resultContains()`** — проверка значения в Result.

## 0.0.6-beta.0

### nexo_core — новые абстракции

- **`NexoAdminCrudBloc<T>`** — generic CRUD BLoC для админ-панелей:
  - Интерфейс `NexoAdminRepository<T>` с методами `list`, `create`, `delete`.
  - Автоматические обработчики: `LoadCrudData`, `SearchCrudData`, `CreateCrudEntity`, `DeleteCrudEntity`.
  - `executeMutation()` — обёртка над try/catch для мутаций с чтением текущего state.
  - `NexoCrudState<T>` — sealed-состояние: `NexoCrudLoading`, `NexoCrudReady`, `NexoCrudError`.

- **`NexoPaginatedMixin<T, Cursor>`** — миксин для cursor-based пагинации:
  - Инкапсулирует `PaginationController`, предоставляет `loadMore(emit, loader, onReady)`.
  - Автоматический emit loading/ready/error, guard от параллельных загрузок.
  - Convenience-геттеры: `paginatedItems`, `nextCursor`, `hasMore`, `isPaginatedLoading`.

- **`@NexoUseCaseAnnotation`** — аннотация для codegen UseCase (генератор в отдельном пакете `nexo_generator`).

### nexo_errors — FailureMapper 2.0

- **`FailureMapper2`** — расширяемый маппер ошибок с поддержкой DI:
  - `register(mapper)` / `registerAll(mappers)` — регистрация кастомных мапперов.
  - Кастомные мапперы имеют приоритет над встроенными.
  - `fromStatic()` для обратной совместимости.
  - `FailureMapper` помечен `@Deprecated('Используйте FailureMapper2')`.

- **`DomainExceptionFailureMapper`** — добавлен параметр `extraMappings`:
  - `Map<Type, Failure Function(Object)>` — кастомные маппинги для исключений приложения.
  - Позволяет расширять маппер без модификации исходного кода nexo.

- **Улучшены Hive/Isar/Drift мапперы** — заменён текстовый хевристик на stackTrace:
  - `HiveFailureMapper`: проверка `traceStr.contains('package:hive')` вместо `runtimeType`.
  - `IsarFailureMapper`: проверка `traceStr.contains('package:isar')`.
  - `DriftFailureMapper`: проверка `traceStr.contains('package:drift')`.

### nexo_cli — новые флаги

- **`--admin-crud`** — генерирует фичу с `NexoAdminCrudBloc` (implies `--bloc`).
- **`--usecase-gen`** — генерирует `@NexoUseCaseAnnotation` abstract class.
- **`--paginated`** — генерирует BLoC с `NexoPaginatedMixin`.

### Зависимости

- Добавлена dev-зависимость `source_gen: ^4.2.4` для codegen.

## 0.0.5-beta.0

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
- `nexo_errors`: **breadcrumbs** — лента последних событий перед сбоем: новая модель `NexoBreadcrumb` (категория, уровень, данные, timestamp) и метод `recordBreadcrumb` в `NexoCrashReporter`; `CollectingNexoCrashReporter` держит кольцевой буфер (`maxBreadcrumbs`, по умолчанию 50) и отдаёт снимок через `breadcrumbTrail`; `NexoBlocObserver` пишет ошибки блоков в ленту автоматически.
  **Breaking** для своих реализаций `NexoCrashReporter`: добавьте пустой `recordBreadcrumb`.
- Обновлены зависимости: `flutter_secure_storage` `^9.2.4` → `^11.0.0` (без изменений в API датасорса), dev-зависимость `freezed` `^3.2.5` → `^4.0.0` с регенерацией `failure.freezed.dart`; остальные пакеты — минорные апгрейды.
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
