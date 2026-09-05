# Example 3: CRUD Feature with Freezed

Full CRUD feature with freezed models and injectable DI.

## Command

```bash
nexo_cli feature article --get --create --update --delete --freezed --injectable --mapper --mock
```

## Generated Structure

```
lib/features/article/
├── data/
│   ├── datasources/
│   │   ├── i_remote_article_data_source.dart
│   │   ├── i_local_article_data_source.dart
│   │   ├── article_remote_datasource.dart
│   │   ├── mock_article_remote_data_source.dart
│   │   ├── article_local_datasource.dart
│   │   └── mock_article_local_data_source.dart
│   ├── models/
│   │   ├── article_model.dart                  # @freezed + fromJson
│   │   ├── article_model.freezed.dart          # generated
│   │   ├── article_model.g.dart                # generated
│   │   └── requests/
│   │       ├── create_article_request.dart      # @freezed
│   │       ├── create_article_request.freezed.dart
│   │       ├── create_article_request.g.dart
│   │       ├── update_article_request.dart      # @freezed
│   │       ├── update_article_request.freezed.dart
│   │       └── update_article_request.g.dart
│   ├── mappers/
│   │   └── article_mapper.dart
│   └── repositories/
│       └── article_repository.dart
├── domain/
│   ├── entities/
│   │   ├── article_entity.dart                  # @freezed
│   │   └── article_entity.freezed.dart          # generated
│   ├── repositories/
│   │   └── i_article_repository.dart
│   ├── usecases/
│   │   ├── get_article_usecase.dart
│   │   └── article_usecases.dart                # Create/Update/Delete
│   └── parameters/
│       ├── create_article_params.dart
│       └── update_article_params.dart
└── presentation/
    ├── cubit/
    │   ├── article_cubit.dart
    │   └── article_state.dart                   # @freezed union
    └── article_screen.dart
```

## What's Generated

- **Model**: `@freezed` with auto-generated `fromJson`/`toJson`
- **Entity**: `@freezed` data class
- **Request DTOs**: `@freezed` for create and update
- **Mapper**: Extension mapping model -> entity
- **Repository**: Interface + implementation
- **UseCases**:
  - `GetArticleUseCase` - returns list
  - `CreateArticleUseCase` - takes `CreateArticleParams`
  - `UpdateArticleUseCase` - takes `UpdateArticleParams`
  - `DeleteArticleUseCase` - takes `String` (id)
- **Parameters**: `CreateArticleParams`, `UpdateArticleParams`
- **State**: `@freezed` union with `loading`, `success`, `error`
