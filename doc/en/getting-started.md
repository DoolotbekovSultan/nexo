# Installation and Setup

## 1. Adding the dependency

### Via Git (recommended for the latest version)

```yaml
# pubspec.yaml
dependencies:
  nexo:
    git:
      url: https://github.com/DoolotbekovSultan/nexo
      ref: main  # or a specific tag/commit
```

### Via path (for monorepos)

```yaml
dependencies:
  nexo:
    path: ../nexo
```

## 2. Installing dependencies

```bash
flutter pub get
```

## 3. Basic app setup

```dart
import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

void main() {
  // 1. Initialize the logger
  final talker = Talker();
  final logger = TalkerLoggerAdapter(talker);

  // 2. Install the global Flutter error handler
  NexoFlutterErrors.install(
    logger: logger,
    crashReporter: NoOpNexoCrashReporter(), // or your own implementation
  );

  // 3. Set up the BLoC observer (optional)
  Bloc.observer = NexoBlocObserver(
    logger,
    crashReporter: NoOpNexoCrashReporter(),
    logLifecycle: true,
    logEvents: true,
    logChanges: true,
    logErrors: true,
  );

  runApp(const MyApp());
}
```

## 4. Importing modules

```dart
// Everything at once (simpler, but increases analysis time)
import 'package:nexo/nexo.dart';

// Or individually (recommended for production)
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:nexo/nexo_ui.dart';

// Only for tests
import 'package:nexo/nexo_testing.dart';
```

---

## Minimal example

```dart
import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

// 1. UseCase
class GetUserUseCase extends NexoUseCase<User, String> {
  GetUserUseCase(super.logger);

  @override
  Future<User> execute(String userId) async {
    // API request
    final response = await dio.get('/users/$userId');
    return User.fromJson(response.data);
  }
}

// 2. Cubit
class UserCubit extends NexoAsyncCubit<User> {
  UserCubit(this._getUser) : super();

  final GetUserUseCase _getUser;

  @override
  Future<Result<User>> fetch() => _getUser('current_user_id');
}

// 3. Screen
class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(
        context.read<GetUserUseCase>(),
      )..load(),
      child: Scaffold(
        body: NexoAsyncStateBuilder<User>(
          state: context.watch<UserCubit>().state,
          onSuccess: (user) => Text(user.name),
          onLoading: () => const CircularProgressIndicator(),
          onFailure: (failure) => NexoFailureView(
            failure: failure,
            onRetry: () => context.read<UserCubit>().retry(),
          ),
        ),
      ),
    );
  }
}
```

---

## Next steps

- [Error handling](nexo-errors.md) — `Failure`, `Result`, mappers
- [Core: Cubit and UseCase](nexo-core.md) — architectural building blocks
- [Logging](nexo-logger.md) — setup and usage
- [UI components](nexo-ui.md) — ready-made widgets
- [Testing](nexo-testing.md) — testing helpers and utilities
- [Architecture](architecture.md) — full architectural overview
