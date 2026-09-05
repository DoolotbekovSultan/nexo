# Examples — Реальные сгенерированные структуры

Эти папки содержат **реальный код**, сгенерированный `nexo_cli`. Каждая папка — это готовая feature с полной структурой файлов.

## Примеры

### 1. `simple_get_list/`
**Команда:** `nexo_cli feature products --get`

Простой feature с GET-операцией, возвращающей список. Минимальная настройка.

### 2. `crud_freezed/`
**Команда:** `nexo_cli feature article --get --create --update --delete --freezed`

Полный CRUD с `@freezed` моделями, events/states, request DTOs.

### 3. `json_fields/`
**Команда:** `nexo_cli feature product --get --json '{"id": "String", "name": "String", "price": "double", "isActive": "bool", "tags": "List<dynamic>"}'`

Feature с полями модели, сгенерированными из JSON.

## Зависимости (pubspec.yaml)

Каждый пример уже содержит `pubspec.yaml` с необходимыми зависимостями:

```yaml
dependencies:
  nexo: ^0.0.5-beta.0        # Основной пакет nexo
  injectable: ^2.5.0          # DI аннотации
  freezed_annotation: ^3.1.0  # @freezed аннотации
  json_annotation: ^4.11.0    # JSON аннотации

dev_dependencies:
  build_runner: ^2.13.1
  freezed: ^4.0.0
  json_serializable: ^6.13.1
  injectable_generator: ^2.7.0
```

## Как использовать

1. Скопируйте нужную папку в свой проект
2. Запустите `flutter pub get`
3. Запустите `build_runner` для генерации freezed-файлов:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. Начните реализовывать бизнес-логику

## Типы полей JSON

| JSON | Dart |
|------|------|
| `"string"` | `String` |
| `42` | `int` |
| `3.14` | `double` |
| `true` | `bool` |
| `[]` | `List<dynamic>` |
| `{}` | `Map<String, dynamic>` |
| `null` | `String?` |

## Как генерируются эти файлы

Каждый файл в этих папках — это **точный результат** работы `nexo_cli`. Например:

```bash
# Создаёт simple_get_list/
nexo_cli feature products --get

# Создаёт crud_freezed/
nexo_cli feature article --get --create --update --delete --freezed

# Создаёт json_fields/
nexo_cli feature product --get --json '{"id": "String", "name": "String", "price": "double"}'
```

CLI генерирует:
- Структуру папок
- Все Dart-файлы с шаблонным кодом
- Аннотации `@freezed`, `@injectable`, `@LazySingleton`
- Mapper extensions
- UseCase классы
- Bloc/Cubit с state management
