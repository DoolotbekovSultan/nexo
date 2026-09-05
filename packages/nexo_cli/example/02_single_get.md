# Example 2: Single Object Feature (Get)

Feature that works with a single object, not a list.

## Command

```bash
nexo_cli feature user_profile --get --list false
```

## Generated Structure

```
lib/features/user_profile/
├── data/
│   ├── datasources/
│   │   ├── i_remote_user_profile_data_source.dart
│   │   ├── i_local_user_profile_data_source.dart
│   │   ├── user_profile_remote_datasource.dart
│   │   ├── mock_user_profile_remote_data_source.dart
│   │   ├── user_profile_local_datasource.dart
│   │   └── mock_user_profile_local_data_source.dart
│   ├── models/
│   │   └── user_profile_model.dart
│   ├── mappers/
│   │   └── user_profile_mapper.dart
│   └── repositories/
│       └── user_profile_repository.dart
├── domain/
│   ├── entities/
│   │   └── user_profile_entity.dart
│   ├── repositories/
│   │   └── i_user_profile_repository.dart
│   └── usecases/
│       └── get_user_profile_usecase.dart
└── presentation/
    ├── cubit/
    │   ├── user_profile_cubit.dart
    │   └── user_profile_state.dart
    └── user_profile_screen.dart
```

## Key Differences from List Feature

- **UseCase**: Returns `UserProfileEntity` instead of `List<UserProfileEntity>`
- **State**: `NexoAsyncState<UserProfileEntity>` instead of `NexoAsyncState<List<UserProfileEntity>>`
- **Repository**: Returns single object
