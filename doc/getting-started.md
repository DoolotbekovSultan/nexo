# Установка и настройка

## 1. Добавление зависимости

### Через Git (рекомендуется для последней версии)

```yaml
# pubspec.yaml
dependencies:
  nexo:
    git:
      url: https://github.com/DoolotbekovSultan/nexo
      ref: main  # или конкретный тег/коммит
```

### Через path (для монорепозитория)

```yaml
dependencies:
  nexo:
    path: ../nexo
```

## 2. Установка зависимостей

```bash
flutter pub get
```

## 3. Базовая настройка приложения

```dart
import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

void main() {
  // 1. Инициализация логгера
  final talker = Talker();
  final logger = TalkerLoggerAdapter(talker);

  // 2. Установка глобального обработчика ошибок Flutter
  NexoFlutterErrors.install(
    logger: logger,
    crashReporter: NoOpNexoCrashReporter(), // или вашу реализацию
  );

  // 3. Настройка BLoC-наблюдателя (опционально)
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

## 4. Импорт модулей

```dart
// Всё сразу (проще, но увеличивает время анализа)
import 'package:nexo/nexo.dart';

// Или по отдельности (рекомендуется для продакшена)
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:nexo/nexo_ui.dart';

// Только для тестов
import 'package:nexo/nexo_testing.dart';
```

---

## Минимальный пример

```dart
import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

// 1. UseCase
class GetUserUseCase extends NexoUseCase<User, String> {
  GetUserUseCase(super.logger);

  @override
  Future<User> execute(String userId) async {
    // Запрос к API
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

// 3. Экран
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

## Следующие шаги

- [Обработка ошибок](nexo-errors.md) — `Failure`, `Result`, мапперы
- [Ядро: Cubit и UseCase](nexo-core.md) — архитектурные строительные блоки
- [Логирование](nexo-logger.md) — настройка и использование
- [UI-компоненты](nexo-ui.md) — готовые виджеты
