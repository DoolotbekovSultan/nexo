# NEXO — Полное руководство

Модульный Flutter-тулкит для архитектуры приложений: обработка ошибок, логирование, UI-компоненты и вспомогательные утилиты.

---

## Быстрый старт

```yaml
# pubspec.yaml
dependencies:
  nexo:
    git:
      url: https://github.com/DoolotbekovSultan/nexo
```

```dart
import 'package:nexo/nexo.dart';

void main() {
  // Установка глобального обработчика ошибок Flutter
  NexoFlutterErrors.install(
    logger: TalkerLoggerAdapter(Talker()),
    crashReporter: NoOpNexoCrashReporter(),
  );

  runApp(const MyApp());
}
```

---

## Модули

| Модуль | Назначение | Импорт |
|--------|-----------|--------|
| **nexo_core** | Cubit/Bloc, UseCase, сеть, датасорсы, валидация | `package:nexo/nexo_core.dart` |
| **nexo_errors** | `Failure`, `Result`, мапперы ошибок, локализация | `package:nexo/nexo_errors.dart` |
| **nexo_logger** | Абстракция логгера + адаптер Talker | `package:nexo/nexo_logger.dart` |
| **nexo_ui** | Готовые виджеты и расширения | `package:nexo/nexo_ui.dart` |
| **nexo_testing** | Матчеры для тестов | `package:nexo/nexo_testing.dart` |

Или импортируйте всё сразу:
```dart
import 'package:nexo/nexo.dart';
```

---

## Содержание

1. [Установка и настройка](getting-started.md)
2. [Обработка ошибок: Failure и Result](nexo-errors.md)
3. [Ядро: Cubit, UseCase, сеть](nexo-core.md)
4. [Логирование](nexo-logger.md)
5. [UI-компоненты](nexo-ui.md)
6. [Тестирование](nexo-testing.md)
7. [Архитектура и паттерны](architecture.md)

---

## Архитектура пакета

```
lib/
├── nexo.dart                    # Главный barrel (всё сразу)
├── nexo_core.dart               # Ядро: Cubit, UseCase, сеть, датасорсы
├── nexo_errors.dart             # Ошибки: Failure, Result, мапперы
├── nexo_logger.dart             # Логирование
├── nexo_ui.dart                 # UI-компоненты
├── nexo_testing.dart            # Тестовые матчеры
└── packages/
    ├── nexo_core/               # Реализация ядра
    │   ├── bloc/                # Cubit/Bloc обёртки
    │   ├── state/               # NexoAsyncState
    │   ├── usecase/             # UseCase слой
    │   ├── network/             # Dio клиент, интерсепторы
    │   ├── datasources/         # Базовые датасорсы
    │   ├── sync/                # Outbox очередь
    │   └── validation/          # Валидаторы
    ├── nexo_errors/             # Реализация ошибок
    │   ├── failure.dart         # Failure sealed-класс
    │   ├── result.dart          # Result<T>
    │   ├── mappers/             # Мапперы ошибок
    │   ├── types/               # Типы ошибок (15 enum-ов)
    │   ├── exceptions/          # AppException
    │   └── localization/        # Локализация сообщений
    ├── nexo_logger/             # Реализация логгера
    ├── nexo_testing/            # Тестовые матчеры
    └── nexo_ui/                 # UI-компоненты
```

---

## Зависимости

| Пакет | Зачем |
|-------|-------|
| `flutter_bloc` | База для `NexoCubit` / `NexoBloc` |
| `bloc_concurrency` | Трансформеры событий |
| `dio` | HTTP-клиент |
| `freezed_annotation` | Генерация `Failure` и `NexoListState` |
| `hive` | Локальное хранилище |
| `isar` | Локальная БД |
| `shared_preferences` | Простые настройки |
| `flutter_secure_storage` | Безопасное хранилище (токены) |
| `talker` | Реализация логгера |
| `firebase_auth` | Маппер ошибок Firebase Auth |
| `firebase_core` | Маппер ошибок Firebase Messaging |
