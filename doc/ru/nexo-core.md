# Ядро: Cubit, UseCase, сеть, датасорсы

---

## NexoCubit — базовый Cubit

Абстрактный базовый класс с встроенной обработкой ошибок через `Result<T>`.

```dart
class CounterCubit extends NexoCubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  Future<void> fetchValue(int id) async {
    await executeEither(
      action: () => api.getValue(id),
      onLoading: () => state, // не меняем состояние
      onSuccess: (data) => data,
      onError: (failure) => state, // не меняем состояние
    );
  }
}
```

### Методы execute

```dart
// 1. execute — action возвращает T
await execute<int>(
  action: () => computeHeavyTask(),
  onLoading: () => State.loading(),
  onSuccess: (data) => State.loaded(data),
  onError: (failure) => State.error(failure),
);

// 2. executeEither — action возвращает Result<T>
await executeEither<User>(
  action: () => getUserUseCase(userId),
  onLoading: () => State.loading(),
  onSuccess: (user) => State.loaded(user),
  onError: (failure) => State.error(failure),
);

// 3. subscribe — подписка на Stream<T>
await subscribe<Message>(
  stream: () => webSocketStream,
  onData: (msg) => State.messageReceived(msg),
  onError: (failure) => State.error(failure),
);

// 4. subscribeEither — подписка на Stream<Result<T>>
await subscribeEither<ChatEvent>(
  stream: () => chatRepository.watchEvents(chatId),
  onData: (event) => State.eventReceived(event),
  onError: (failure) => State.error(failure),
);
```

---

## NexoAsyncCubit — кубит для типичного экрана

Готовый кубит для экранов с одним асинхронным источником данных.

```dart
class UserProfileCubit extends NexoAsyncCubit<UserProfile> {
  UserProfileCubit(this._getUserProfile) : super();

  final GetUserProfileUseCase _getUserProfile;

  @override
  Future<Result<UserProfile>> fetch() => _getUserProfile('current_user');
}

// Использование:
final cubit = context.read<UserProfileCubit>();
cubit.load();     // Полная загрузка: Loading → Success/Failure
cubit.retry();    // Повтор после ошибки
cubit.refresh();  // Тихое обновление (без Loading)
```

### Состояния

```dart
NexoAsyncState<T> state;

// Проверка типа
state.isLoading  // true если загружается
state.isSuccess  // true если успех
state.isFailure  // true если ошибка
state.isIdle     // true если ещё не загружалось

// Извлечение данных
final data = state.dataOrNull;      // T? или null
final failure = state.failureOrNull; // Failure? или null
```

---

## NexoAsyncState — sealed-состояния

```dart
sealed class NexoAsyncState<T> {}
  NexoAsyncIdle<T>()      // Начальное состояние
  NexoAsyncLoading<T>()   // Загрузка
  NexoAsyncSuccess<T>(data) // Успех
  NexoAsyncFailure<T>(failure) // Ошибка
```

---

## UseCase — слой бизнес-логики

### Одноразовая операция

```dart
class GetUserUseCase extends NexoUseCase<User, String> {
  GetUserUseCase(super.logger);

  @override
  Future<User> execute(String userId) async {
    final response = await dio.get('/users/$userId');
    return User.fromJson(response.data);
  }
}

// Вызов:
final result = await GetUserUseCase(logger)('user_123');
result.fold(
  onFailure: (f) => showSnackBar(f.userMessage),
  onSuccess: (user) => showProfile(user),
);
```

### Потоковая операция

```dart
class WatchMessagesUseCase extends NexoStreamUseCase<Message, String> {
  WatchMessagesUseCase(super.logger);

  @override
  Stream<Message> build(String chatId) {
    return messageRepository.watchMessages(chatId);
  }
}

// Вызов:
await for (final result in WatchMessagesUseCase(logger)('chat_123')) {
  result.fold(
    onFailure: (f) => showError(f.userMessage),
    onSuccess: (msg) => addMessage(msg),
  );
}
```

### UseCase без параметров

```dart
class GetCurrentUserUseCase extends NexoUseCase<User, NoParams> {
  GetCurrentUserUseCase(super.logger);

  @override
  Future<User> execute(NoParams params) async {
    return await userRepository.getCurrentUser();
  }
}

// Вызов:
final result = await GetCurrentUserUseCase(logger)(const NoParams());
```

### Retry с экспоненциальной задержкой

```dart
final result = await GetUserUseCase(logger).callWithRetry(
  'user_123',
  maxAttempts: 3,
  baseDelay: Duration(seconds: 1),
  backoffMultiplier: 2.0,
);
```

---

## NexoBloc — для BLoC с событиями

Аналог `NexoCubit`, но для паттерна Event → State.

```dart
// События
sealed class UserEvent {}
class FetchUser extends UserEvent { final String userId; FetchUser(this.userId); }
class RefreshUser extends UserEvent {}

// BLoC
class UserBloc extends NexoBloc<UserEvent, UserState> {
  UserBloc() : super(UserState.initial());

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    switch (event) {
      case FetchUser(:final userId):
        await execute<User>(
          emit: emit,
          action: () => api.getUser(userId),
          onLoading: () => UserState.loading(),
          onSuccess: (user) => UserState.loaded(user),
          onError: (failure) => UserState.error(failure),
        );
      case RefreshUser:
        // ...
    }
  }
}
```

---

## Трансформеры событий

```dart
// Отменяет предыдущее при новом (для поиска)
on<SearchEvent>(
  _onSearch,
  transformer: debounceRestartable(Duration(milliseconds: 300)),
);

// Обрабатывает строго по очереди
on<SaveEvent>(
  _onSave,
  transformer: sequentialTransformer(),
);

// Отбрасывает новые во время обработки
on<UploadEvent>(
  _onUpload,
  transformer: droppableTransformer(),
);
```

---

## FailureSupport — миксин для маппинга ошибок

Миксин, добавляющий единообразное преобразование ошибок в `Failure`. Используется в `NexoBloc` и `NexoCubit` для гарантии, что все ошибки конвертируются в `Failure` — либо проходя через существующий `Failure`, либо маппясь через `FailureMapperExtension`.

```dart
mixin FailureSupport {
  Failure toFailure(Object error, StackTrace stackTrace) {
    return error is Failure ? error : error.toFailure(stackTrace);
  }
}
```

### Использование

```dart
class MyBloc extends NexoBloc<Event, State> {
  void handleError(Object error, StackTrace stackTrace) {
    final failure = toFailure(error, stackTrace);
    // обработка failure...
  }
}
```

`NexoBloc` и `NexoCubit` уже используют `FailureSupport`, поэтому `toFailure` доступен напрямую внутри этих классов.

---

## PaginationController — постраничная навигация

### PageChunk

Страница данных, возвращаемая функцией загрузки.

```dart
class PageChunk<T, Cursor> {
  final List<T> items;
  final Cursor? nextCursor;
  final bool hasMore;

  const PageChunk({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}
```

### PaginationController

Управляет состоянием пагинации: накопленные элементы, курсор следующей страницы и флаг загрузки.

```dart
final controller = PaginationController<User, String>();

// Загрузка первой страницы
final firstPage = await controller.loadNext(
  loader: (cursor) => api.getUsers(cursor: cursor),
);

// Загрузка следующей страницы
if (controller.hasMore) {
  await controller.loadNext(
    loader: (cursor) => api.getUsers(cursor: cursor),
  );
}

// Все загруженные элементы
final users = controller.items;
```

### Свойства

| Свойство | Тип | Описание |
|----------|-----|----------|
| `items` | `List<T>` | Неизменяемый список загруженных элементов |
| `nextCursor` | `Cursor?` | Курсор для следующей страницы; `null` когда все загружено |
| `hasMore` | `bool` | `true` если доступны ещё страницы |
| `isLoading` | `bool` | `true` во время загрузки страницы |

### Методы

| Метод | Описание |
|-------|----------|
| `reset()` | Очищает элементы, сбрасывает курсор и флаги в начальное состояние |
| `loadNext()` | Загружает следующую страницу через колбэк `loader`. Возвращает `PageChunk?` или `null`, если уже загружается или все загружено |
| `replaceAll()` | Заменяет все загруженные элементы новым списком, опционально сбрасывая курсор и флаг `hasMore` |

---

## Оптимистичные обновления

### OptimisticUpdateResult

Результат оптимистичного обновления — содержит либо финальное состояние, либо состояние отката с ошибкой.

```dart
class OptimisticUpdateResult<TState> {
  final TState state;
  final Failure? failure;

  const OptimisticUpdateResult({required this.state, this.failure});
}
```

### performOptimistic

Выполняет оптимистичное обновление:

1. Мгновенно применяет `optimisticState` к UI.
2. Запускает `action` в фоне.
3. При успехе — трансформирует результат через `onSuccess` для получения финального состояния.
4. При ошибке — откатывается к `rollbackState` и прикрепляет `Failure`.

```dart
final result = await performOptimistic(
  optimisticState: state.copyWith(isLoading: true),
  rollbackState: state,
  action: () => api.likePost(postId),
  onSuccess: (likes) => state.copyWith(likes: likes),
);

if (result.failure != null) {
  showError(result.failure!.userMessage);
}
emit(result.state);
```

### Параметры

| Параметр | Тип | Описание |
|----------|-----|----------|
| `optimisticState` | `TState` | Состояние, применяемое мгновенно (оптимистичное обновление) |
| `rollbackState` | `TState` | Состояние для отката при ошибке |
| `action` | `Future<TResult> Function()` | Асинхронная операция, которая может завершиться ошибкой |
| `onSuccess` | `TState Function(TResult result)` | Трансформирует результат операции в финальное состояние |

---

## Оффлайн-first хелперы

### fetchCacheThenNetwork

Возвращает кэшированные данные, если доступны; иначе загружает из сети и опционально сохраняет в кэш.

```dart
final data = await fetchCacheThenNetwork(
  loadCache: () async => await hiveStore.get('users'),
  loadNetwork: () async => await api.getUsers(),
  saveCache: (users) async => await hiveStore.put('users', users),
);
```

| Параметр | Тип | Описание |
|----------|-----|----------|
| `loadCache` | `Future<T?> Function()` | Загружает данные из локального кэша; возвращает `null` если недоступны |
| `loadNetwork` | `Future<T> Function()` | Загружает свежие данные из сети |
| `saveCache` | `Future<void> Function(T)?` | Сохраняет сетевые данные в кэш (опционально) |

### fetchNetworkThenCache

Загружает из сети и сохраняет в кэш. При сетевой ошибке опционально использует устаревший кэш.

```dart
final data = await fetchNetworkThenCache(
  loadNetwork: () async => await api.getUsers(),
  saveCache: (users) async => await hiveStore.put('users', users),
  onNetworkFailureLoadCache: () async => await hiveStore.get('users'),
);
```

| Параметр | Тип | Описание |
|----------|-----|----------|
| `loadNetwork` | `Future<T> Function()` | Загружает свежие данные из сети |
| `saveCache` | `Future<void> Function(T)` | Сохраняет сетевые данные в кэш |
| `onNetworkFailureLoadCache` | `Future<T?> Function()?` | Загружает устаревший кэш при сетевой ошибке (опционально) |

---

## Network: DioClient

Обёртка над `Dio` с типизированными методами.

```dart
final client = DioClient(
  Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  )),
);

// GET
final response = await client.get<List<dynamic>>('/users');
final users = response.data!.map((e) => User.fromJson(e)).toList();

// POST
final response = await client.post<User>(
  '/users',
  data: {'name': 'John', 'email': 'john@example.com'},
);

// С progress callback
await client.post(
  '/upload',
  data: formData,
  onSendProgress: (sent, total) => print('$sent / $total'),
);
```

---

## Интерсепторы

### NexoAuthInterceptor — аутентификация

```dart
final dio = Dio();
dio.interceptors.add(
  NexoAuthInterceptor(
    dio: dio,
    getToken: () async => await secureStorage.read('access_token'),
    refreshToken: () async {
      final response = await authApi.refreshToken();
      await secureStorage.write('access_token', response.accessToken);
      return response.accessToken;
    },
    onTokenExpired: () async {
      // Перенаправить на экран входа
      navigator.pushReplacement('/login');
    },
    onLog: (msg) => print('[Auth] $msg'),
  ),
);
```

### NexoLoggingInterceptor — логирование

```dart
dio.interceptors.add(
  NexoLoggingInterceptor(
    logger: logger,
    logRequests: true,
    logResponses: true,
    logErrors: true,
    sensitiveFields: {'password', 'token', 'secret'},
  ),
);
```

### NexoRetryInterceptor — повторные попытки

```dart
dio.interceptors.add(
  NexoRetryInterceptor(
    dio: dio,
    maxRetries: 3,
    baseDelay: Duration(milliseconds: 500),
    backoffMultiplier: 2.0,
    onRetry: (attempt, delay, error) {
      logger.warning('Retry $attempt after ${delay.inMilliseconds}ms');
    },
  ),
);
```

### NexoRequestIdInterceptor — идентификатор запроса

```dart
dio.interceptors.add(
  NexoRequestIdInterceptor(
    logger: logger,
    // generateId: () => uuid.v4(), // опционально
  ),
);
```

### Порядок интерсепторов

```dart
dio.interceptors.addAll([
  NexoRequestIdInterceptor(logger: logger),   // 1. ID запроса
  NexoLoggingInterceptor(logger: logger),      // 2. Логирование
  NexoRetryInterceptor(dio: dio),              // 3. Retry
  NexoAuthInterceptor(                         // 4. Auth (последний)
    dio: dio,
    getToken: () => ...,
    refreshToken: () => ...,
    onTokenExpired: () => ...,
  ),
]);
```

---

## Датасорсы

### BaseRemoteDataSource — удалённый источник

```dart
class UsersRemoteDataSource extends BaseRemoteDataSource {
  UsersRemoteDataSource(super.client, {required super.logger});

  Future<List<User>> getUsers() async {
    final response = await get<List<dynamic>>('/users');
    return response.data!.map((e) => User.fromJson(e)).toList();
  }

  Future<User> createUser(CreateUserRequest request) async {
    final response = await post<User>(
      '/users',
      data: request.toJson(),
    );
    return response.data!;
  }
}
```

### BaseIsarDataSource — локальное хранилище Isar

Базовый класс для локального хранилища на основе Isar. Предоставляет обёртки для транзакций чтения/записи и реактивных подписок.

```dart
class UserIsarDataSource extends BaseIsarDataSource {
  UserIsarDataSource(super.isar, {required super.logger});

  Future<List<User>> getAllUsers() {
    return read((isar) => isar.users.where().findAll());
  }

  Future<void> saveUser(User user) {
    return write((isar) => isar.users.put(user));
  }

  Stream<List<User>> watchAllUsers() {
    return watch((isar) => isar.users.where().watchLazy());
  }
}
```

#### Конструктор

```dart
const BaseIsarDataSource(Isar isar, {required NexoLogger logger});
```

#### Методы

| Метод | Сигнатура | Описание |
|-------|-----------|----------|
| `read` | `Future<T> read<T>(Future<T> Function(Isar) action)` | Выполняет операцию чтения внутри транзакции Isar |
| `write` | `Future<T> write<T>(Future<T> Function(Isar) action)` | Выполняет транзакцию записи в Isar |
| `watch` | `Stream<T> watch<T>(Stream<T> Function(Isar) watcher)` | Подписывается на реактивные изменения данных в Isar |

Все операции логируют ошибки через `NexoLogger` и пробрасывают исключение дальше.

### BaseHiveDataSource — Hive хранилище

```dart
class UserHiveDataSource extends BaseHiveDataSource<User, String> {
  UserHiveDataSource({required super.logger}) : super('users');

  // Уже есть: put, get, getAll, delete, findWhere, watchKey, watchAll
}

final dataSource = UserHiveDataSource(logger: logger);
await dataSource.put('user_1', User(name: 'John'));
final user = await dataSource.get('user_1');
await dataSource.watchKey('user_1').listen((user) => print(user));
```

### BaseSharedPreferencesDataSource — настройки

```dart
class SettingsDataSource extends BaseSharedPreferencesDataSource {
  SettingsDataSource({required super.prefs, required super.logger});

  bool get isDarkMode => getBool('dark_mode') ?? false;
  Future<void> setDarkMode(bool value) => setBool('dark_mode', value);

  String get locale => getStringOrEmpty('locale');
  Future<void> setLocale(String value) => setString('locale', value);
}
```

### BaseSecureStorageDataSource — безопасное хранилище

```dart
class AuthSecureStorage extends BaseSecureStorageDataSource {
  AuthSecureStorage({required super.logger})
      : super(const FlutterSecureStorage());

  Future<void> saveTokens(String access, String refresh) async {
    await write('access_token', access);
    await write('refresh_token', refresh);
  }

  Future<String?> getAccessToken() => read('access_token');
  Future<void> clearTokens() => deleteAll();
}
```

---

## ReconnectingStreamService — автоматическое переподключение к потокам

### StreamFactory

Абстрактная фабрика для создания экземпляров потоков. Используется с `ReconnectingStreamService` для установки новых соединений при разрыве.

```dart
abstract class StreamFactory<T> {
  Stream<T> create();
}
```

### ReconnectingStreamService

Автоматически переподключается к потоку при ошибке или разрыве с настраиваемой задержкой.

```dart
class MessagesStreamFactory implements StreamFactory<Message> {
  @override
  Stream<Message> create() => socketService.watchMessages();
}

final service = ReconnectingStreamService(
  factory: MessagesStreamFactory(),
  retryDelay: Duration(seconds: 3),
);

await for (final message in service.connect()) {
  // обработка сообщений...
}
```

#### Конструктор

```dart
ReconnectingStreamService({
  required StreamFactory<T> factory,
  Duration retryDelay = const Duration(seconds: 2),
});
```

#### Методы

| Метод | Описание |
|-------|----------|
| `connect()` | Возвращает бесконечный `Stream<T>`, который переподключается при ошибках после `retryDelay` |

---

## Валидация

```dart
// Встроенные валидаторы
final validators = NexoValidators.compose([
  NexoValidators.requiredField(),
  NexoValidators.email(),
  NexoValidators.minLength(8),
]);

final error = validators('test@example.com');
if (error != null) {
  showError(error); // "Обязательное поле" / "Неверный формат email"
}

// Кастомный валидатор
NexoValidator<String> phoneValidator() {
  return (value) {
    if (value == null || value.isEmpty) return 'Обязательное поле';
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) return 'Неверный формат телефона';
    return null;
  };
}
```

---

## Outbox — очередь офлайн-мутаций

```dart
final outbox = NexoOutbox(
  store: HiveOutboxStore(), // ваша реализация OutboxStore
  send: (entry) async {
    await dio.request(
      entry.path,
      options: Options(method: entry.method),
      data: entry.payload,
    );
  },
  logger: logger,
);

// Пользовательское действие — «успех» для UI сразу
await outbox.enqueue(
  path: '/posts',
  method: 'POST',
  payload: {'title': 'Привет', 'body': 'Мир'},
);

// По возврату сети
final result = await outbox.flush();
if (!result.isComplete) {
  showSnackBar('Не удалось отправить: ${result.failure!.userMessage}');
}
```

---

## SubscriptionMixin — управление подписками

```dart
class ChatCubit extends NexoCubit<ChatState> with SubscriptionMixin {
  void subscribeToChat(String chatId) {
    subscribe<String>(
      subscriptionKey: 'chat_$chatId',
      stream: () => chatRepository.watchMessages(chatId),
      onData: (msg) => emit(ChatState.messageReceived(msg)),
      onError: (f) => emit(ChatState.error(f)),
    );
  }

  // Подписка автоматически отменяется при повторном вызове с тем же ключом
  // и при close() кубита
}
```
