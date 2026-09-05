# Example 1: Simple Feature (Get List)

Minimal feature with only GET operation returning a list.

## Command

```bash
nexo_cli feature products --get --list true
```

## Generated Structure

```
lib/features/products/
├── data/
│   ├── datasources/
│   │   ├── i_remote_products_data_source.dart
│   │   ├── i_local_products_data_source.dart
│   │   ├── products_remote_datasource.dart
│   │   ├── mock_products_remote_data_source.dart
│   │   ├── products_local_datasource.dart
│   │   └── mock_products_local_data_source.dart
│   ├── models/
│   │   └── products_model.dart
│   ├── mappers/
│   │   └── products_mapper.dart
│   └── repositories/
│       └── products_repository.dart
├── domain/
│   ├── entities/
│   │   └── products_entity.dart
│   ├── repositories/
│   │   └── i_products_repository.dart
│   └── usecases/
│       └── get_products_usecase.dart
└── presentation/
    ├── cubit/
    │   ├── products_cubit.dart
    │   └── products_state.dart
    └── products_screen.dart
```

## What's Generated

- **Model**: Plain class with `fromJson`/`toJson` (default fields: `id`)
- **Entity**: Plain class with same fields
- **Mapper**: Extension `toDomain()` mapping model -> entity
- **Repository**: Interface + implementation
- **UseCase**: `GetProductsUseCase` extends `NexoUseCase<List<ProductsEntity>, NoParams>`
- **Cubit**: `ProductsCubit` with `load()` method
- **State**: `ProductsState` = `NexoAsyncState<List<ProductsEntity>>`
