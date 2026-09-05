# Core: Cubit, UseCase, Networking, Data Sources

---

## NexoCubit — Base Cubit

Abstract base class with built-in error handling via `Result<T>`.

```dart
class CounterCubit extends NexoCubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);

  Future<void> fetchValue(int id) async {
    await executeEither(
      action: () => api.getValue(id),
      onLoading: () => state, // don't change state
      onSuccess: (data) => data,
      onError: (failure) => state, // don't change state
    );
  }
}
```

### Execute Methods

```dart
// 1. execute — action returns T
await execute<int>(
  action: () => computeHeavyTask(),
  onLoading: () => State.loading(),
  onSuccess: (data) => State.loaded(data),
  onError: (failure) => State.error(failure),
);

// 2. executeEither — action returns Result<T>
await executeEither<User>(
  action: () => getUserUseCase(userId),
  onLoading: () => State.loading(),
  onSuccess: (user) => State.loaded(user),
  onError: (failure) => State.error(failure),
);

// 3. subscribe — subscribe to a Stream<T>
await subscribe<Message>(
  stream: () => webSocketStream,
  onData: (msg) => State.messageReceived(msg),
  onError: (failure) => State.error(failure),
);

// 4. subscribeEither — subscribe to a Stream<Result<T>>
await subscribeEither<ChatEvent>(
  stream: () => chatRepository.watchEvents(chatId),
  onData: (event) => State.eventReceived(event),
  onError: (failure) => State.error(failure),
);
```

---

## NexoAsyncCubit — Ready-Made Cubit for Typical Screens

A pre-built cubit for screens backed by a single async data source.

```dart
class UserProfileCubit extends NexoAsyncCubit<UserProfile> {
  UserProfileCubit(this._getUserProfile) : super();

  final GetUserProfileUseCase _getUserProfile;

  @override
  Future<Result<UserProfile>> fetch() => _getUserProfile('current_user');
}

// Usage:
final cubit = context.read<UserProfileCubit>();
cubit.load();     // Full load: Loading → Success/Failure
cubit.retry();    // Retry after failure
cubit.refresh();  // Silent refresh (no Loading state)
```

### States

```dart
NexoAsyncState<T> state;

// Type checks
state.isLoading  // true while loading
state.isSuccess  // true on success
state.isFailure  // true on error
state.isIdle     // true before first load

// Data extraction
final data = state.dataOrNull;      // T? or null
final failure = state.failureOrNull; // Failure? or null
```

---

## NexoAsyncState — Sealed States

```dart
sealed class NexoAsyncState<T> {}
  NexoAsyncIdle<T>()      // Initial state
  NexoAsyncLoading<T>()   // Loading
  NexoAsyncSuccess<T>(data) // Success
  NexoAsyncFailure<T>(failure) // Error
```

---

## UseCase — Business Logic Layer

### One-Shot Operation

```dart
class GetUserUseCase extends NexoUseCase<User, String> {
  GetUserUseCase(super.logger);

  @override
  Future<User> execute(String userId) async {
    final response = await dio.get('/users/$userId');
    return User.fromJson(response.data);
  }
}

// Invocation:
final result = await GetUserUseCase(logger)('user_123');
result.fold(
  onFailure: (f) => showSnackBar(f.userMessage),
  onSuccess: (user) => showProfile(user),
);
```

### Stream Operation

```dart
class WatchMessagesUseCase extends NexoStreamUseCase<Message, String> {
  WatchMessagesUseCase(super.logger);

  @override
  Stream<Message> build(String chatId) {
    return messageRepository.watchMessages(chatId);
  }
}

// Invocation:
await for (final result in WatchMessagesUseCase(logger)('chat_123')) {
  result.fold(
    onFailure: (f) => showError(f.userMessage),
    onSuccess: (msg) => addMessage(msg),
  );
}
```

### UseCase Without Parameters

```dart
class GetCurrentUserUseCase extends NexoUseCase<User, NoParams> {
  GetCurrentUserUseCase(super.logger);

  @override
  Future<User> execute(NoParams params) async {
    return await userRepository.getCurrentUser();
  }
}

// Invocation:
final result = await GetCurrentUserUseCase(logger)(const NoParams());
```

### Retry with Exponential Backoff

```dart
final result = await GetUserUseCase(logger).callWithRetry(
  'user_123',
  maxAttempts: 3,
  baseDelay: Duration(seconds: 1),
  backoffMultiplier: 2.0,
);
```

---

## NexoBloc — BLoC with Events

Analogous to `NexoCubit`, but for the Event → State pattern.

```dart
// Events
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

## Event Transformers

```dart
// Cancel previous on new event (for search)
on<SearchEvent>(
  _onSearch,
  transformer: debounceRestartable(Duration(milliseconds: 300)),
);

// Process strictly in order
on<SaveEvent>(
  _onSave,
  transformer: sequentialTransformer(),
);

// Drop new events while processing
on<UploadEvent>(
  _onUpload,
  transformer: droppableTransformer(),
);
```

---

## FailureSupport — Error Mapping Mixin

A mixin that adds uniform error-to-`Failure` conversion. Used by `NexoBloc` and `NexoCubit` to ensure all errors are converted to `Failure` objects, either by passing through an existing `Failure` or by mapping via `FailureMapperExtension`.

```dart
mixin FailureSupport {
  Failure toFailure(Object error, StackTrace stackTrace) {
    return error is Failure ? error : error.toFailure(stackTrace);
  }
}
```

### Usage

```dart
class MyBloc extends NexoBloc<Event, State> {
  void handleError(Object error, StackTrace stackTrace) {
    final failure = toFailure(error, stackTrace);
    // handle failure...
  }
}
```

`NexoBloc` and `NexoCubit` already mix in `FailureSupport`, so `toFailure` is available directly inside those classes.

---

## PaginationController — Cursor-Based Pagination

### PageChunk

A data page returned by a loader function.

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

Manages pagination state: accumulated items, next cursor, and loading flag.

```dart
final controller = PaginationController<User, String>();

// Load first page
final firstPage = await controller.loadNext(
  loader: (cursor) => api.getUsers(cursor: cursor),
);

// Load next page
if (controller.hasMore) {
  await controller.loadNext(
    loader: (cursor) => api.getUsers(cursor: cursor),
  );
}

// All loaded items
final users = controller.items;
```

### Properties

| Property      | Type          | Description                                        |
|---------------|---------------|----------------------------------------------------|
| `items`       | `List<T>`     | Immutable list of loaded items                     |
| `nextCursor`  | `Cursor?`     | Cursor for the next page; `null` when exhausted    |
| `hasMore`     | `bool`        | `true` if more pages are available                 |
| `isLoading`   | `bool`        | `true` while a page load is in progress            |

### Methods

| Method       | Description                                                             |
|--------------|-------------------------------------------------------------------------|
| `reset()`    | Clears items, resets cursor and flags to initial state.                  |
| `loadNext()` | Loads the next page via the `loader` callback. Returns `PageChunk?` or `null` if already loading or exhausted. |
| `replaceAll()` | Replaces all loaded items with a new list, optionally resetting the cursor and `hasMore` flag. |

---

## Optimistic Updates

### OptimisticUpdateResult

The result of an optimistic update — contains either the final state or a rollback state with a failure.

```dart
class OptimisticUpdateResult<TState> {
  final TState state;
  final Failure? failure;

  const OptimisticUpdateResult({required this.state, this.failure});
}
```

### performOptimistic

Executes an optimistic update:

1. Instantly applies `optimisticState` to the UI.
2. Runs `action` in the background.
3. On success — maps the result via `onSuccess` to produce the final state.
4. On error — rolls back to `rollbackState` and attaches the `Failure`.

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

### Parameters

| Parameter         | Type                                 | Description                                    |
|-------------------|--------------------------------------|------------------------------------------------|
| `optimisticState` | `TState`                             | State applied immediately (the optimistic update) |
| `rollbackState`   | `TState`                             | State to revert to on error                    |
| `action`          | `Future<TResult> Function()`         | The async operation that may fail              |
| `onSuccess`       | `TState Function(TResult result)`    | Maps the operation result to the final state   |

---

## Offline-First Helpers

### fetchCacheThenNetwork

Returns cached data if available; otherwise fetches from network and optionally persists to cache.

```dart
final data = await fetchCacheThenNetwork(
  loadCache: () async => await hiveStore.get('users'),
  loadNetwork: () async => await api.getUsers(),
  saveCache: (users) async => await hiveStore.put('users', users),
);
```

| Parameter      | Type                              | Description                                      |
|----------------|-----------------------------------|--------------------------------------------------|
| `loadCache`    | `Future<T?> Function()`           | Loads data from local cache; returns `null` if unavailable |
| `loadNetwork`  | `Future<T> Function()`            | Fetches fresh data from the network              |
| `saveCache`    | `Future<void> Function(T)?`       | Persists network data to cache (optional)        |

### fetchNetworkThenCache

Fetches from network and saves to cache. On network failure, optionally falls back to stale cache data.

```dart
final data = await fetchNetworkThenCache(
  loadNetwork: () async => await api.getUsers(),
  saveCache: (users) async => await hiveStore.put('users', users),
  onNetworkFailureLoadCache: () async => await hiveStore.get('users'),
);
```

| Parameter                   | Type                              | Description                                              |
|-----------------------------|-----------------------------------|----------------------------------------------------------|
| `loadNetwork`               | `Future<T> Function()`            | Fetches fresh data from the network                      |
| `saveCache`                 | `Future<void> Function(T)`        | Persists network data to cache                           |
| `onNetworkFailureLoadCache` | `Future<T?> Function()?`          | Loads stale cache on network failure (optional)          |

---

## Network: DioClient

Wrapper around `Dio` with typed methods.

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

// With progress callback
await client.post(
  '/upload',
  data: formData,
  onSendProgress: (sent, total) => print('$sent / $total'),
);
```

---

## Interceptors

### NexoAuthInterceptor — Authentication

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
      // Redirect to login screen
      navigator.pushReplacement('/login');
    },
    onLog: (msg) => print('[Auth] $msg'),
  ),
);
```

### NexoLoggingInterceptor — Logging

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

### NexoRetryInterceptor — Retries

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

### NexoRequestIdInterceptor — Request ID

```dart
dio.interceptors.add(
  NexoRequestIdInterceptor(
    logger: logger,
    // generateId: () => uuid.v4(), // optional
  ),
);
```

### Interceptor Order

```dart
dio.interceptors.addAll([
  NexoRequestIdInterceptor(logger: logger),   // 1. Request ID
  NexoLoggingInterceptor(logger: logger),      // 2. Logging
  NexoRetryInterceptor(dio: dio),              // 3. Retry
  NexoAuthInterceptor(                         // 4. Auth (last)
    dio: dio,
    getToken: () => ...,
    refreshToken: () => ...,
    onTokenExpired: () => ...,
  ),
]);
```

---

## Data Sources

### BaseRemoteDataSource — Remote Source

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

### BaseIsarDataSource — Isar Local Storage

Base class for Isar-backed local storage. Provides wrappers for read/write transactions and reactive watchers.

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

#### Constructor

```dart
const BaseIsarDataSource(Isar isar, {required NexoLogger logger});
```

#### Methods

| Method  | Signature                                                       | Description                                          |
|---------|-----------------------------------------------------------------|------------------------------------------------------|
| `read`  | `Future<T> read<T>(Future<T> Function(Isar) action)`            | Runs a read operation inside an Isar transaction.     |
| `write` | `Future<T> write<T>(Future<T> Function(Isar) action)`           | Runs a write transaction in Isar.                    |
| `watch` | `Stream<T> watch<T>(Stream<T> Function(Isar) watcher)`          | Subscribes to reactive data changes in Isar.         |

All operations log errors via `NexoLogger` and rethrow the original exception.

### BaseHiveDataSource — Hive Storage

```dart
class UserHiveDataSource extends BaseHiveDataSource<User, String> {
  UserHiveDataSource({required super.logger}) : super('users');

  // Built-in: put, get, getAll, delete, findWhere, watchKey, watchAll
}

final dataSource = UserHiveDataSource(logger: logger);
await dataSource.put('user_1', User(name: 'John'));
final user = await dataSource.get('user_1');
await dataSource.watchKey('user_1').listen((user) => print(user));
```

### BaseSharedPreferencesDataSource — Preferences

```dart
class SettingsDataSource extends BaseSharedPreferencesDataSource {
  SettingsDataSource({required super.prefs, required super.logger});

  bool get isDarkMode => getBool('dark_mode') ?? false;
  Future<void> setDarkMode(bool value) => setBool('dark_mode', value);

  String get locale => getStringOrEmpty('locale');
  Future<void> setLocale(String value) => setString('locale', value);
}
```

### BaseSecureStorageDataSource — Secure Storage

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

## ReconnectingStreamService — Auto-Reconnect for Streams

### StreamFactory

Abstract factory for creating stream instances. Used with `ReconnectingStreamService` to establish new connections on disconnect.

```dart
abstract class StreamFactory<T> {
  Stream<T> create();
}
```

### ReconnectingStreamService

Automatically reconnects to a stream on error or disconnect with a configurable delay.

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
  // process messages...
}
```

#### Constructor

```dart
ReconnectingStreamService({
  required StreamFactory<T> factory,
  Duration retryDelay = const Duration(seconds: 2),
});
```

#### Methods

| Method    | Description                                                                          |
|-----------|--------------------------------------------------------------------------------------|
| `connect()` | Returns an infinite `Stream<T>` that reconnects on errors after `retryDelay`.       |

---

## Validation

```dart
// Built-in validators
final validators = NexoValidators.compose([
  NexoValidators.requiredField(),
  NexoValidators.email(),
  NexoValidators.minLength(8),
]);

final error = validators('test@example.com');
if (error != null) {
  showError(error); // "Required field" / "Invalid email format"
}

// Custom validator
NexoValidator<String> phoneValidator() {
  return (value) {
    if (value == null || value.isEmpty) return 'Required field';
    if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) return 'Invalid phone format';
    return null;
  };
}
```

---

## Outbox — Offline Mutation Queue

```dart
final outbox = NexoOutbox(
  store: HiveOutboxStore(), // your OutboxStore implementation
  send: (entry) async {
    await dio.request(
      entry.path,
      options: Options(method: entry.method),
      data: entry.payload,
    );
  },
  logger: logger,
);

// User action — UI gets "success" immediately
await outbox.enqueue(
  path: '/posts',
  method: 'POST',
  payload: {'title': 'Hello', 'body': 'World'},
);

// When network is back
final result = await outbox.flush();
if (!result.isComplete) {
  showSnackBar('Failed to send: ${result.failure!.userMessage}');
}
```

---

## SubscriptionMixin — Subscription Management

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

  // Subscription is automatically cancelled when called again with the same key
  // and when the cubit is closed
}
```
