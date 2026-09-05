# Example 7: NexoListCubit Feature

Feature using NexoListCubit for simple list loading.

## Command

```bash
nexo_cli feature notification --list-cubit --freezed --injectable --get --list true
```

## Generated Structure

```
lib/features/notification/
├── data/
│   ├── datasources/
│   │   ├── i_remote_notification_data_source.dart
│   │   ├── i_local_notification_data_source.dart
│   │   ├── notification_remote_datasource.dart
│   │   ├── mock_notification_remote_data_source.dart
│   │   ├── notification_local_datasource.dart
│   │   └── mock_notification_local_data_source.dart
│   ├── models/
│   │   ├── notification_model.dart
│   │   ├── notification_model.freezed.dart
│   │   └── notification_model.g.dart
│   ├── mappers/
│   │   └── notification_mapper.dart
│   └── repositories/
│       └── notification_repository.dart
├── domain/
│   ├── entities/
│   │   ├── notification_entity.dart
│   │   └── notification_entity.freezed.dart
│   ├── repositories/
│   │   └── i_notification_repository.dart
│   └── usecases/
│       └── get_notification_usecase.dart
└── presentation/
    └── cubit/
        └── notification_cubit.dart
```

## What's Different

- **Cubit**: `NotificationCubit extends NexoListCubit<NotificationEntity>`
- **No state file**: NexoListCubit manages its own state
- **Simple fetch**: Just implement `fetch()` method
- **Built-in loading/error**: Handled by NexoListCubit

## Generated Cubit

```dart
@injectable
class NotificationCubit extends NexoListCubit<NotificationEntity> {
  NotificationCubit({
    required GetNotificationUseCase getNotificationUseCase,
  }) : _getNotificationUseCase = getNotificationUseCase;

  final GetNotificationUseCase _getNotificationUseCase;

  @override
  Future<List<NotificationEntity>> fetch() async {
    return await _getNotificationUseCase(const NoParams());
  }
}
```
