# Example 6: Bloc Feature with Extensions

Feature using Bloc pattern with entity extensions.

## Command

```bash
nexo_cli feature order --bloc --freezed --injectable --extensions --get --create --list true
```

## Generated Structure

```
lib/features/order/
├── data/
│   ├── datasources/
│   │   ├── i_remote_order_data_source.dart
│   │   ├── i_local_order_data_source.dart
│   │   ├── order_remote_datasource.dart
│   │   ├── mock_order_remote_data_source.dart
│   │   ├── order_local_datasource.dart
│   │   └── mock_order_local_data_source.dart
│   ├── models/
│   │   ├── order_model.dart
│   │   ├── order_model.freezed.dart
│   │   ├── order_model.g.dart
│   │   └── requests/
│   │       ├── create_order_request.dart
│   │       ├── create_order_request.freezed.dart
│   │       └── create_order_request.g.dart
│   ├── mappers/
│   │   └── order_mapper.dart
│   └── repositories/
│       └── order_repository.dart
├── domain/
│   ├── entities/
│   │   ├── order_entity.dart
│   │   ├── order_entity.freezed.dart
│   │   └── order_extensions.dart
│   ├── repositories/
│   │   └── i_order_repository.dart
│   ├── usecases/
│   │   ├── get_order_usecase.dart
│   │   └── order_usecases.dart
│   └── parameters/
│       └── create_order_params.dart
└── presentation/
    ├── bloc/
    │   ├── order_bloc.dart
    │   ├── order_event.dart
    │   ├── order_event.freezed.dart
    │   ├── order_state.dart
    │   └── order_state.freezed.dart
    └── order_screen.dart
```

## Key Features

- **Bloc**: `OrderBloc` with events and states
- **Events**: `@freezed` sealed union (`OrderEvent.load()`)
- **States**: `@freezed` sealed union (`loading`, `success`, `error`)
- **Extensions**: `OrderExtensions` on `OrderEntity`
- **Full CRUD**: Get, Create operations
