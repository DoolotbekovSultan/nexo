# Architecture and Patterns

---

## App Structure

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt, Riverpod, etc.)
│   ├── network/         # Dio, interceptors
│   └── storage/         # Data sources (Hive, SharedPreferences, SecureStorage)
├── features/
│   └── [feature]/
│       ├── data/        # Repositories, data sources, models
│       ├── domain/      # UseCase, entities
│       └── presentation/# Cubit/Bloc, UI
├── l10n/                # Localization
└── app.dart
```

---

## Data Flow

```
UI → Cubit → UseCase → Repository → DataSource → API/DB
  ←         ←         ←            ←             ←
  State     Result    Result       Data          Response
```

### Full flow example

```dart
// 1. UI → Cubit
context.read<UserCubit>().load();

// 2. Cubit → UseCase
await executeEither<User>(
  action: () => _getUserUseCase(userId),
  ...
);

// 3. UseCase → Repository
Future<User> execute(String userId) async {
  return await _userRepository.getUser(userId);
}

// 4. Repository → DataSource
Future<User> getUser(String id) async {
  final response = await _remoteDataSource.get<User>('/users/$id');
  await _localDataSource.put(id, response);
  return response;
}

// 5. DataSource → API
Future<Response<T>> get<T>(String path) async {
  return await client.get<T>(path);
}
```

---

## Pattern: UseCase

### Rules

1. **One UseCase — one action** (Single Responsibility)
2. **UseCase knows nothing about UI** — returns `Result<T>`
3. **UseCase never mutates state** — that's the Cubit's job
4. **UseCase is reusable** — different Cubits can call the same UseCase

### Structure

```dart
// Domain layer
class GetUserUseCase extends NexoUseCase<User, String> {
  GetUserUseCase(this._repository, super.logger);

  final UserRepository _repository;

  @override
  Future<User> execute(String userId) async {
    return await _repository.getUser(userId);
  }
}

// Presentation layer
class UserCubit extends NexoAsyncCubit<User> {
  UserCubit(this._getUser) : super();
  final GetUserUseCase _getUser;

  @override
  Future<Result<User>> fetch() => _getUser('current_user');
}
```

### When NOT to use a UseCase

- Simple operations (increment, toggle)
- CRUD without business logic
- Direct repository calls in a Cubit

```dart
// ❌ UseCase not needed
class ToggleDarkModeUseCase extends NexoUseCase<bool, NoParams> {
  @override
  Future<bool> execute(NoParams params) async => !currentValue;
}

// ✅ Just a method in the Cubit
void toggleDarkMode() => emit(!state);
```

---

## Pattern: Error Handling

### Unified error flow

```
Exception → FailureMapper → Failure → Result → UI
```

### Where to map errors

| Layer | What to do |
|-------|-----------|
| **DataSource** | Let exceptions bubble up |
| **Repository** | Let them bubble up or map to domain exceptions |
| **UseCase** | Automatically mapped to `Result` via `call()` |
| **Cubit** | Automatically mapped via `executeEither` |
| **UI** | Display `failure.userMessage` |

### Exceptions to the rule

- **Authentication**: map in UseCase/Repository
- **Validation**: map in Repository (server → domain)
- **Cache**: map in DataSource (fallback to network)

```dart
// Repository with fallback
Future<User> getUser(String id) async {
  try {
    return await _remote.getUser(id);
  } on AuthAppException {
    rethrow; // mapped to Failure via FailureMapper
  } catch (e) {
    // Fallback to cache
    final cached = await _local.get(id);
    if (cached != null) return cached;
    rethrow;
  }
}
```

---

## Pattern: State

### NexoAsyncState — for a single value

```dart
// ✅ Correct
sealed class MyState {}
class Initial extends MyState {}
class Loading extends MyState {}
class Loaded extends MyState { final User user; }
class Error extends MyState { final Failure failure; }

// Or use NexoAsyncState<User>
class UserCubit extends NexoAsyncCubit<User> { ... }
```

### For lists

```dart
// Option 1: NexoAsyncState<List<User>>
class UsersCubit extends NexoAsyncCubit<List<User>> {
  @override
  Future<Result<List<User>>> fetch() => _getUsers(NoParams());
}

// Option 2: Custom state (when pagination is needed)
sealed class UsersState {}
class UsersInitial extends UsersState {}
class UsersLoading extends UsersState { final List<User> items; }
class UsersLoaded extends UsersState { final List<User> items; final bool hasMore; }
class UsersError extends UsersState { final Failure failure; final List<User> items; }
```

---

## Pattern: Dependency Injection

### With GetIt

```dart
// di.dart
final getIt = GetIt.instance;

void setupDI() {
  // Core
  getIt.registerLazySingleton<Dio>(() => createDio());
  getIt.registerLazySingleton<NexoLogger>(() => TalkerLoggerAdapter(Talker()));

  // Data sources
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(getIt(), logger: getIt()),
  );
  getIt.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSource(logger: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt(), getIt()),
  );

  // Use cases
  getIt.registerFactory(() => GetUserUseCase(getIt(), getIt()));

  // Cubits
  getIt.registerFactory(() => UserCubit(getIt()));
}
```

### With Riverpod

```dart
// providers.dart
final loggerProvider = Provider<NexoLogger>((ref) {
  return TalkerLoggerAdapter(Talker());
});

final dioProvider = Provider<Dio>((ref) {
  return createDio();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remote: ref.watch(userRemoteDataSourceProvider),
    local: ref.watch(userLocalDataSourceProvider),
  );
});

final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.watch(userRepositoryProvider), ref.watch(loggerProvider));
});
```

---

## Pattern: Offline-First

```dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;
  final UserLocalDataSource _local;

  @override
  Future<User> getUser(String id) async {
    // 1. Try network
    try {
      final user = await _remote.getUser(id);
      await _local.put(id, user); // cache it
      return user;
    } catch (e) {
      // 2. Fallback to cache
      final cached = await _local.get(id);
      if (cached != null) return cached;
      rethrow; // 3. Neither network nor cache available
    }
  }
}
```

Or use the built-in helpers:

```dart
// Cache-first strategy
final user = await fetchCacheThenNetwork<User>(
  loadCache: () => localDataSource.getUser(id),
  loadNetwork: () => remoteDataSource.getUser(id),
  saveCache: (user) => localDataSource.put(id, user),
);

// Network-first strategy
final user = await fetchNetworkThenCache<User>(
  loadNetwork: () => remoteDataSource.getUser(id),
  saveCache: (user) => localDataSource.put(id, user),
  onNetworkFailureLoadCache: () => localDataSource.getUser(id),
);
```

---

## Pattern: Optimistic Updates

```dart
// 1. Update UI immediately
final previousState = state;
emit(state.copyWith(isLiked: true));

// 2. Send to server
final result = await likePostUseCase(postId);

// 3. Rollback on failure
if (result.isFailure) {
  emit(previousState);
  showSnackBar(result.failureOrNull!.userMessage);
}
```

Or use the helper:

```dart
final result = await performOptimistic<PostState, bool>(
  optimisticState: state.copyWith(isLiked: true),
  rollbackState: state,
  action: () => likePostUseCase(postId),
  onSuccess: (liked) => state.copyWith(isLiked: liked),
);

emit(result.state);
if (result.failure != null) {
  showSnackBar(result.failure!.userMessage);
}
```

---

## Pattern: Pagination

```dart
class UsersCubit extends NexoCubit<UsersState> {
  UsersCubit(this._getUsers) : super(UsersState.initial());

  final GetUsersUseCase _getUsers;
  final _pagination = PaginationController<User, String>();

  List<User> get users => _pagination.items;
  bool get hasMore => _pagination.hasMore;
  bool get isLoadingMore => _pagination.isLoading;

  Future<void> loadFirstPage() async {
    _pagination.reset();
    await loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (_pagination.isLoading || !_pagination.hasMore) return;

    emit(UsersState.loading(users: users));

    final page = await _pagination.loadNext(
      loader: (cursor) => _getUsers(GetUsersParams(cursor: cursor)),
    );

    if (page != null) {
      emit(UsersState.loaded(users: users, hasMore: page.hasMore));
    }
  }
}
```

---

## Architecture Review Checklist

- [ ] One UseCase — one action
- [ ] UseCase returns `Result<T>`, never throws exceptions
- [ ] Cubit maps `Result` into state via `executeEither`
- [ ] DataSource lets exceptions bubble up, does not map to Failure
- [ ] UI displays `failure.userMessage`, not technical details
- [ ] No diagonal dependencies (UI → Domain ← Data)
- [ ] Cache-first or network-first is a deliberate choice
- [ ] Errors are logged at every layer
