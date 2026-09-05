# Архитектура и паттерны

---

## Структура приложения

```
lib/
├── core/
│   ├── di/              # Dependency Injection (GetIt, Riverpod и т.д.)
│   ├── network/         # Dio, интерсепторы
│   └── storage/         # Датасорсы (Hive, SharedPreferences, SecureStorage)
├── features/
│   └── [feature]/
│       ├── data/        # Репозитории, датасорсы, модели
│       ├── domain/      # UseCase, entities
│       └── presentation/# Cubit/Bloc, UI
├── l10n/                # Локализация
└── app.dart
```

---

## Поток данных

```
UI → Cubit → UseCase → Repository → DataSource → API/DB
  ←         ←         ←            ←             ←
  State     Result    Result       Data          Response
```

### Пример полного потока

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

## Паттерн: UseCase

### Правила

1. **Один UseCase — одно действие** (Single Responsibility)
2. **UseCase не знает про UI** — возвращает `Result<T>`
3. **UseCase не меняет состояние** — это делает Cubit
4. **UseCase переиспользуется** — разные Cubit могут вызывать один UseCase

### Структура

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

### Когда НЕ нужен UseCase

- Простые операции ( increment, toggle)
- CRUD без бизнес-логики
- Прямые вызовы репозитория в Cubit

```dart
// ❌ Не нужен UseCase
class ToggleDarkModeUseCase extends NexoUseCase<bool, NoParams> {
  @override
  Future<bool> execute(NoParams params) async => !currentValue;
}

// ✅ Просто метод в Cubit
void toggleDarkMode() => emit(!state);
```

---

## Паттерн: Ошибки

### Единый поток ошибок

```
Исключение → FailureMapper → Failure → Result → UI
```

### Где маппить ошибки

| Слой | Что делать |
|------|-----------|
| **DataSource** | Пробрасывать исключения наверх |
| **Repository** | Пробрасывать или маппить в Domain-исключения |
| **UseCase** | Автоматически маппится в `Result` через `call()` |
| **Cubit** | Автоматически маппится через `executeEither` |
| **UI** | Показывать `failure.userMessage` |

### Исключения из правила

- **Аутентификация**: маппить в UseCase/Repository
- **Валидация**: маппить в Repository (сервер → Domain)
- **Кэш**: маппить в DataSource (fallback на сеть)

```dart
// Repository с fallback
Future<User> getUser(String id) async {
  try {
    return await _remote.getUser(id);
  } on AuthAppException {
    rethrow; // маппится в Failure через FailureMapper
  } catch (e) {
    // Fallback на кэш
    final cached = await _local.get(id);
    if (cached != null) return cached;
    rethrow;
  }
}
```

---

## Паттерн: Состояния

### NexoAsyncState — для одного значения

```dart
// ✅ Правильно
sealed class MyState {}
class Initial extends MyState {}
class Loading extends MyState {}
class Loaded extends MyState { final User user; }
class Error extends MyState { final Failure failure; }

// Или используйте NexoAsyncState<User>
class UserCubit extends NexoAsyncCubit<User> { ... }
```

### Для списков

```dart
// Вариант 1: NexoAsyncState<List<User>>
class UsersCubit extends NexoAsyncCubit<List<User>> {
  @override
  Future<Result<List<User>>> fetch() => _getUsers(NoParams());
}

// Вариант 2: Свой state (если нужна пагинация)
sealed class UsersState {}
class UsersInitial extends UsersState {}
class UsersLoading extends UsersState { final List<User> items; }
class UsersLoaded extends UsersState { final List<User> items; final bool hasMore; }
class UsersError extends UsersState { final Failure failure; final List<User> items; }
```

---

## Паттерн: Dependency Injection

### С GetIt

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

### С Riverpod

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

## Паттерн: Оффлайн-first

```dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;
  final UserLocalDataSource _local;

  @override
  Future<User> getUser(String id) async {
    // 1. Пробуем сеть
    try {
      final user = await _remote.getUser(id);
      await _local.put(id, user); // кэшируем
      return user;
    } catch (e) {
      // 2. Fallback на кэш
      final cached = await _local.get(id);
      if (cached != null) return cached;
      rethrow; // 3. Нет ни сети, ни кэша
    }
  }
}
```

Или используйте готовые функции:

```dart
// Cache-first стратегия
final user = await fetchCacheThenNetwork<User>(
  loadCache: () => localDataSource.getUser(id),
  loadNetwork: () => remoteDataSource.getUser(id),
  saveCache: (user) => localDataSource.put(id, user),
);

// Network-first стратегия
final user = await fetchNetworkThenCache<User>(
  loadNetwork: () => remoteDataSource.getUser(id),
  saveCache: (user) => localDataSource.put(id, user),
  onNetworkFailureLoadCache: () => localDataSource.getUser(id),
);
```

---

## Паттерн: Оптимистичные обновления

```dart
// 1. Сразу обновляем UI
final previousState = state;
emit(state.copyWith(isLiked: true));

// 2. Отправляем на сервер
final result = await likePostUseCase(postId);

// 3. При ошибке — откат
if (result.isFailure) {
  emit(previousState);
  showSnackBar(result.failureOrNull!.userMessage);
}
```

Или используйте хелпер:

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

## Паттерн: Пагинация

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

## Чек-лист по архитектуре

- [ ] Один UseCase — одно действие
- [ ] UseCase возвращает `Result<T>`, не бросает исключений
- [ ] Cubit маппит `Result` в состояние через `executeEither`
- [ ] DataSource пробрасывает исключения, не маппит в Failure
- [ ] UI показывает `failure.userMessage`, не технические детали
- [ ] Диагональные зависимости отсутствуют (UI → Domain ← Data)
- [ ] Кэш-first или Network-first — осознанный выбор
- [ ] Ошибки логируются на каждом уровне
