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
