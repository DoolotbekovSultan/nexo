# Example 8: Minimal Feature (No nexo)

Feature without nexo package dependencies — plain Dart classes.

## Command

```bash
nexo_cli feature simple_item --no-freezed --no-injectable --no-mapper --no-mock --get --list false
```

## Generated Structure

```
lib/features/simple_item/
├── data/
│   ├── datasources/
│   │   └── simple_item_remote_datasource.dart
│   ├── models/
│   │   └── simple_item_model.dart
│   └── repositories/
│       └── simple_item_repository.dart
├── domain/
│   ├── entities/
│   │   └── simple_item_entity.dart
│   ├── repositories/
│   │   └── i_simple_item_repository.dart
│   └── usecases/
│       └── get_simple_item_usecase.dart
└── presentation/
    ├── cubit/
    │   ├── simple_item_cubit.dart
    │   └── simple_item_state.dart
    └── simple_item_screen.dart
```

## What's Generated

- **Model**: Plain Dart class with manual `fromJson`/`toJson`
- **Entity**: Plain Dart class
- **No mapper**: Direct mapping in repository
- **No DI annotations**: Manual dependency injection
- **No mock**: Only real datasource
- **Repository**: Plain class implementing interface
- **UseCase**: Extends `NexoUseCase` (still requires nexo for base class)

## Key Differences

| Option | With nexo | Without nexo |
|--------|-----------|--------------|
| Model | `@freezed` + `fromJson` | Plain class |
| Entity | `@freezed` | Plain class |
| DI | `@injectable` | Manual |
| Mapper | Extension method | Inline in repository |
| Mock | Generated | Not generated |
