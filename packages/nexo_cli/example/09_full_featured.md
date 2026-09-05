# Example 9: Full-Featured CRUD with JSON

Maximum complexity: all flags enabled, JSON fields, full CRUD.

## Command

```bash
nexo_cli feature order \
  --bloc \
  --freezed \
  --injectable \
  --mapper \
  --mock \
  --local \
  --preferences \
  --extensions \
  --ui \
  --tests \
  --get \
  --create \
  --update \
  --delete \
  --list true \
  --json '{"id": "String", "customerName": "String", "total": "double", "items": "List<dynamic>", "isPaid": "bool", "createdAt": "String"}'
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
│   │       ├── create_order_request.g.dart
│   │       ├── update_order_request.dart
│   │       ├── update_order_request.freezed.dart
│   │       └── update_order_request.g.dart
│   ├── mappers/
│   │   └── order_mapper.dart
│   ├── repositories/
│   │   └── order_repository.dart
│   └── order_preferences.dart
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
│       ├── create_order_params.dart
│       └── update_order_params.dart
└── presentation/
    ├── bloc/
    │   ├── order_bloc.dart
    │   ├── order_event.dart
    │   ├── order_event.freezed.dart
    │   ├── order_state.dart
    │   └── order_state.freezed.dart
    ├── order_screen.dart
    ├── pages/
    │   └── order_page.dart
    └── widgets/
        └── order_widget.dart

test/features/order/
├── data/
│   ├── order_repository_test.dart
│   └── mappers/
│       └── order_mapper_test.dart
├── domain/
│   ├── get_order_usecase_test.dart
│   └── order_usecases_test.dart
└── presentation/
    └── order_bloc_test.dart
```

## Generated Model (with JSON fields)

```dart
@freezed
abstract class OrderModel with _$OrderModel {
  const factory OrderModel({
    required String id,
    required String customerName,
    required double total,
    required List<dynamic> items,
    required bool isPaid,
    required String createdAt,
  }) = _OrderModel;

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
}
```

## Generated Entity

```dart
@freezed
abstract class OrderEntity with _$OrderEntity {
  const factory OrderEntity({
    required String id,
    required String customerName,
    required double total,
    required List<dynamic> items,
    required bool isPaid,
    required String createdAt,
  }) = _OrderEntity;
}
```

## Generated State (freezed union)

```dart
@freezed
abstract class OrderState with _$OrderState {
  const factory OrderState.loading() = _OrderStateLoading;
  const factory OrderState.success({required List<OrderEntity> data}) =
      _OrderStateSuccess;
  const factory OrderState.error({Failure? failure}) = _OrderStateError;
}
```

## All Flags Used

| Flag | Value | Purpose |
|------|-------|---------|
| `--bloc` | true | Bloc pattern with events |
| `--freezed` | true | @freezed for all data classes |
| `--injectable` | true | @injectable / @LazySingleton |
| `--mapper` | true | Extension-based mapper |
| `--mock` | true | Mock datasources |
| `--local` | true | Local datasource |
| `--preferences` | true | SharedPreferences wrapper |
| `--extensions` | true | Entity extensions |
| `--ui` | true | Pages and widgets |
| `--tests` | true | Test files |
| `--get` | true | GET use case |
| `--create` | true | CREATE use case + request |
| `--update` | true | UPDATE use case + request |
| `--delete` | true | DELETE use case |
| `--list` | true | Returns List<OrderEntity> |
| `--json` | {...} | Model fields from JSON |
