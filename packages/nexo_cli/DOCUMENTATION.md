# nexo_cli — Полная документация

CLI-генератор feature-модулей для Flutter-проектов на архитектуре Clean Architecture с пакетом [nexo](https://pub.dev/packages/nexo).

---

## Содержание

1. [Установка](#установка)
2. [Быстрый старт](#быстрый-старт)
3. [Все флаги](#все-флаги)
4. [Архитектура генерируемых фич](#архитектура-генерируемых-фич)
5. [Примеры команд](#примеры-команд)
6. [Структура файлов](#структура-файлов)
7. [JSON-поля](#json-поля)
8. [CRUD операции](#crud-операции)
9. [Тип данных: список vs объект](#тип-данных-список-vs-объект)
10. [Шаблоны кода](#шаблоны-кода)
11. [Зависимости](#зависимости)
12. [Пост-генерация](#пост-генерация)
13. [Частые вопросы](#частые-вопросы)

---

## Установка

```bash
dart pub global activate nexo_cli
```

Проверка:

```bash
nexo_cli --help
nexo_cli feature --help
```

---

## Быстрый старт

```bash
# 1. Перейди в корень Flutter-проекта (где pubspec.yaml)
cd my_flutter_app

# 2. Сгенерируй фичу
nexo_cli feature auth --get --create --list true

# 3. Запусти build_runner (если используешь freezed/injectable)
dart run build_runner build --delete-conflicting-outputs
```

Результат:

```
lib/features/auth/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── mappers/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    └── auth_screen.dart
```

---

## Все флаги

### Стиль presentation

| Флаг | По умолчанию | Описание |
|------|-------------|----------|
| `--bloc` | выкл | Bloc с events + states |
| `--cubit` | вкл (если ничего не выбрано) | Cubit с state |
| `--list-cubit` | выкл | NexoListCubit (для простых списков) |
| `--presentation-only` | выкл | Только presentation/, без data/domain |

### Формат кода

| Флаг | По умолчанию | Описание |
|------|-------------|----------|
| `--freezed` / `--no-freezed` | вкл | `@freezed` для entity, model, events, states |
| `--injectable` / `--no-injectable` | вкл | `@injectable` / `@LazySingleton` аннотации |
| `--mapper` / `--no-mapper` | вкл | `data/mappers/` с extension `toDomain()` |
| `--mock` / `--no-mock` | вкл | Mock datasource |

### Дополнительные слои

| Флаг | По умолчанию | Описание |
|------|-------------|----------|
| `--local` | выкл | Local datasource (i_local + impl) |
| `--preferences` | выкл | `<feature>_preferences.dart` |
| `--extensions` | выкл | `<feature>_extensions.dart` на entity |

### CRUD операции

| Флаг | Описание |
|------|----------|
| `--get` | Use case для чтения (get all / get by id) |
| `--create` | Use case + request DTO + params |
| `--update` | Use case + request DTO + params |
| `--delete` | Use case для удаления |

### Данные

| Флаг | Описание |
|------|----------|
| `--json '{...}'` | Поля модели из JSON |
| `--json @file.json` | Поля модели из файла |
| `--list true` | Работа со списком (по умолчанию) |
| `--list false` | Работа с одним объектом |

### UI

| Флаг | Описание |
|------|----------|
| `--ui` | `pages/` и `widgets/` |

### Управление

| Флаг | Описание |
|------|----------|
| `--tests` | Тестовые файлы |
| `--dry-run` / `-n` | Превью без записи |
| `--overwrite` | Перезапись существующих файлов |
| `--root` | Базовая директория вывода (по умолчанию: `lib/features`) |

---

## Архитектура генерируемых фич

```
feature/
├── data/                          ← Источники данных
│   ├── datasources/
│   │   ├── i_remote_...           ← Интерфейс (абстракция)
│   │   ├── i_local_...            ← Интерфейс (локальный)
│   │   ├── ..._remote_datasource  ← Реализация (API)
│   │   ├── ..._local_datasource   ← Реализация (локально)
│   │   ├── mock_..._remote        ← Мок (для dev)
│   │   └── mock_..._local         ← Мок (для dev)
│   ├── models/
│   │   └── ..._model.dart         ← Data-модель (fromJson)
│   ├── models/requests/           ← Request DTOs (для CRUD)
│   ├── mappers/
│   │   └── ..._mapper.dart        ← Extension toDomain()
│   └── repositories/
│       └── ..._repository.dart    ← Реализация repository
│
├── domain/                        ← Бизнес-логика
│   ├── entities/
│   │   └── ..._entity.dart        ← Domain-модель (чистый Dart)
│   ├── repositories/
│   │   └── i_..._repository.dart  ← Интерфейс repository
│   ├── usecases/
│   │   ├── get_..._usecase.dart   ← Use case (чтение)
│   │   └── ..._usecases.dart      ← CRUD use cases
│   └── parameters/
│       ├── create_..._params.dart ← Параметры для create
│       └── update_..._params.dart ← Параметры для update
│
└── presentation/                  ← UI
    ├── bloc/                      ← Bloc (events + states)
    │   ├── ..._bloc.dart
    │   ├── ..._event.dart
    │   └── ..._state.dart
    ├── cubit/                     ← Cubit (state)
    │   ├── ..._cubit.dart
    │   └── ..._state.dart
    ├── ..._screen.dart            ← Главный экран
    ├── pages/                     ← Страницы (--ui)
    └── widgets/                   ← Виджеты (--ui)
```

### Поток данных

```
UI (Screen)
  ↓ вызов
Cubit/Bloc
  ↓ вызов
UseCase
  ↓ вызов
Repository (интерфейс)
  ↓ делегирует
Repository (реализация)
  ↓ вызов
DataSource (интерфейс)
  ↓ делегирует
DataSource (реализация: API / Local / Mock)
  ↓ возвращает
Model (fromJson)
  ↓ mapper.toDomain()
Entity (чистый Dart)
```

---

## Примеры команд

### Минимальная фича

```bash
nexo_cli feature splash --presentation-only
```

```
lib/features/splash/
└── presentation/
    └── splash_screen.dart
```

### GET список (по умолчанию)

```bash
nexo_cli feature products --get
```

### GET один объект

```bash
nexo_cli feature profile --get --list false
```

### Полный CRUD

```bash
nexo_cli feature article --get --create --update --delete
```

### CRUD с freezed

```bash
nexo_cli feature article --get --create --update --delete --freezed
```

### Модель из JSON

```bash
nexo_cli feature product --get \
  --json '{"id": "String", "name": "String", "price": "double", "isActive": "bool"}'
```

### Все опции

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
  --json '{"id": "String", "total": "double"}'
```

### Превью без записи

```bash
nexo_cli feature order --get --create --dry-run
```

---

## Структура файлов

### Полная (все флаги включены)

```
lib/features/order/
├── data/
│   ├── datasources/
│   │   ├── i_remote_order_data_source.dart
│   │   ├── i_local_order_data_source.dart
│   │   ├── order_remote_datasource.dart
│   │   ├── order_local_datasource.dart
│   │   ├── mock_order_remote_data_source.dart
│   │   └── mock_order_local_data_source.dart
│   ├── models/
│   │   ├── order_model.dart
│   │   ├── order_model.freezed.dart      # если --freezed
│   │   ├── order_model.g.dart            # если --freezed
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
```

### Минимальная

```bash
nexo_cli feature auth --get --no-freezed --no-injectable --no-mock --no-mapper
```

```
lib/features/auth/
├── data/
│   ├── datasources/
│   │   └── auth_remote_datasource.dart
│   ├── models/
│   │   └── auth_model.dart
│   └── repositories/
│       └── auth_repository.dart
├── domain/
│   ├── entities/
│   │   └── auth_entity.dart
│   ├── repositories/
│   │   └── i_auth_repository.dart
│   └── usecases/
│       └── get_auth_usecase.dart
└── presentation/
    ├── cubit/
    │   ├── auth_cubit.dart
    │   └── auth_state.dart
    └── auth_screen.dart
```

---

## JSON-поля

### Формат

```bash
nexo_cli feature product --json '{"id": "String", "name": "String", "price": "double"}'
```

### Типы

| JSON значение | Dart тип | Пример |
|---------------|----------|--------|
| `"строка"` | `String` | `"name": "String"` |
| `42` | `int` | `"count": "int"` |
| `3.14` | `double` | `"price": "double"` |
| `true` | `bool` | `"isActive": "bool"` |
| `[]` | `List<dynamic>` | `"tags": "List<dynamic>"` |
| `{}` | `Map<String, dynamic>` | `"meta": "Map<String, dynamic>"` |
| `null` | `String?` | `"avatar": "String?"` |

### Результат

Команда:
```bash
nexo_cli feature product --get \
  --json '{"id": "String", "name": "String", "price": "double", "isActive": "bool"}'
```

Сгенерированный model:

```dart
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
  });

  final String id;
  final String name;
  final double price;
  final bool isActive;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'isActive': isActive};
  }
}
```

Сгенерированный entity:

```dart
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
  });

  final String id;
  final String name;
  final double price;
  final bool isActive;
}
```

Сгенерированный mapper:

```dart
extension ProductMapper on ProductModel {
  ProductEntity toDomain() => ProductEntity(
    id: id,
    name: name,
    price: price,
    isActive: isActive,
  );
}
```

### Чтение из файла

```bash
nexo_cli feature product --get --json @api_response.json
```

Файл `api_response.json`:

```json
{
  "id": 1,
  "title": "Товар",
  "price": 99.99,
  "inStock": true
}
```

---

## CRUD операции

### Флаги

| Флаг | Генерирует |
|------|-----------|
| `--get` | `Get<Feature>UseCase`, метод `getAll()` в repository |
| `--create` | `Create<Feature>UseCase`, `Create<Feature>Request`, `Create<Feature>Params` |
| `--update` | `Update<Feature>UseCase`, `Update<Feature>Request`, `Update<Feature>Params` |
| `--delete` | `Delete<Feature>UseCase` |

### Пример: только GET

```bash
nexo_cli feature products --get
```

Repository interface:

```dart
abstract interface class IProductsRepository {
  Future<List<ProductsEntity>> getAll();
}
```

### Пример: полный CRUD

```bash
nexo_cli feature products --get --create --update --delete
```

Repository interface:

```dart
abstract interface class IProductsRepository {
  Future<List<ProductsEntity>> getAll();
  // + Create/Update/Delete use cases генерируются отдельно
}
```

Use cases:

```dart
// get_products_usecase.dart
class GetProductsUseCase extends NexoUseCase<List<ProductsEntity>, NoParams> {
  @override
  Future<List<ProductsEntity>> execute(NoParams params) async {
    return await _repository.getAll();
  }
}

// product_usecases.dart
class CreateProductUseCase extends NexoUseCase<ProductEntity, CreateProductParams> {
  @override
  Future<ProductEntity> execute(CreateProductParams params) async {
    // TODO: implement
  }
}

class UpdateProductUseCase extends NexoUseCase<ProductEntity, UpdateProductParams> {
  @override
  Future<ProductEntity> execute(UpdateProductParams params) async {
    // TODO: implement
  }
}

class DeleteProductUseCase extends NexoUseCase<void, String> {
  @override
  Future<void> execute(String id) async {
    // TODO: implement
  }
}
```

---

## Тип данных: список vs объект

### `--list true` (по умолчанию)

Для коллекций (список товаров, список заказов):

```bash
nexo_cli feature products --get --list true
```

```dart
// UseCase
class GetProductsUseCase extends NexoUseCase<List<ProductsEntity>, NoParams> {
  @override
  Future<List<ProductsEntity>> execute(NoParams params) async {
    return await _repository.getAll();
  }
}

// Repository
abstract interface class IProductsRepository {
  Future<List<ProductsEntity>> getAll();
}

// State
typedef ProductsState = NexoAsyncState<List<ProductsEntity>>;
```

### `--list false`

Для единичных объектов (профиль, настройки):

```bash
nexo_cli feature profile --get --list false
```

```dart
// UseCase
class GetProfileUseCase extends NexoUseCase<ProfileEntity, NoParams> {
  @override
  Future<ProfileEntity> execute(NoParams params) async {
    return await _repository.get();
  }
}

// Repository
abstract interface class IProfileRepository {
  Future<ProfileEntity> get();
}

// State
typedef ProfileState = NexoAsyncState<ProfileEntity>;
```

---

## Шаблоны кода

### Entity (с --freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_entity.freezed.dart';

@freezed
abstract class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required String id,
    required String name,
  }) = _ProductEntity;
}
```

### Entity (без --freezed)

```dart
class ProductEntity {
  const ProductEntity({required this.id, required this.name});
  final String id;
  final String name;
}
```

### Model (с --freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
```

### Model (без --freezed)

```dart
class ProductModel {
  const ProductModel({required this.id, required this.name});
  final String id;
  final String name;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

### Mapper

```dart
import '../models/product_model.dart';
import '../entities/product_entity.dart';

extension ProductMapper on ProductModel {
  ProductEntity toDomain() => ProductEntity(id: id, name: name);
}

extension ProductListMapper on List<ProductModel> {
  List<ProductEntity> toDomain() => map((e) => e.toDomain()).toList();
}
```

### Repository Interface

```dart
import '../entities/product_entity.dart';

abstract interface class IProductRepository {
  Future<List<ProductEntity>> getAll();
}
```

### Repository Impl

```dart
import 'package:injectable/injectable.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../datasources/i_remote_product_data_source.dart';

@LazySingleton(as: IProductRepository)
class ProductRepository implements IProductRepository {
  ProductRepository({required this._remoteDatasource});

  final IRemoteProductDataSource _remoteDatasource;

  @override
  Future<List<ProductEntity>> getAll() async {
    final models = await _remoteDatasource.getAll();
    return models.toDomain();  // ← mapper extension
  }
}
```

### UseCase

```dart
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/product_entity.dart';
import '../repositories/i_product_repository.dart';

@injectable
class GetProductUseCase extends NexoUseCase<List<ProductEntity>, NoParams> {
  GetProductUseCase(
    super._logger, {
    required IProductRepository repository,
  }) : _repository = repository;

  final IProductRepository _repository;

  @override
  Future<List<ProductEntity>> execute(NoParams params) async {
    return await _repository.getAll();
  }
}
```

### Cubit

```dart
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_product_usecase.dart';
import 'product_state.dart';

@injectable
class ProductCubit extends NexoCubit<ProductState> {
  ProductCubit({
    required GetProductUseCase getProductUseCase,
  })  : _getProductUseCase = getProductUseCase,
        super(const ProductState.loading());

  final GetProductUseCase _getProductUseCase;

  Future<void> load() async {
    await executeEither<List<ProductEntity>>(
      action: () => _getProductUseCase(const NoParams()),
      onLoading: () => const ProductState.loading(),
      onSuccess: (data) => ProductState.success(data: data),
      onError: (failure) => ProductState.error(failure: failure),
    );
  }
}
```

### State (с --freezed)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexo/nexo_errors.dart';

import '../../domain/entities/product_entity.dart';

part 'product_state.freezed.dart';

@freezed
abstract class ProductState with _$ProductState {
  const factory ProductState.loading() = _ProductStateLoading;
  const factory ProductState.success({required List<ProductEntity> data}) =
      _ProductStateSuccess;
  const factory ProductState.error({Failure? failure}) = _ProductStateError;
}
```

### State (без --freezed)

```dart
import 'package:nexo/nexo_core.dart';

import '../../domain/entities/product_entity.dart';

typedef ProductState = NexoAsyncState<List<ProductEntity>>;
```

### Datasource Interface

```dart
import '../models/product_model.dart';

abstract interface class IRemoteProductDataSource {
  Future<List<ProductModel>> getAll();
}
```

### Datasource Impl

```dart
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:injectable/injectable.dart';

import 'i_remote_product_data_source.dart';
import '../models/product_model.dart';

@LazySingleton(as: IRemoteProductDataSource, env: [AppEnvironment.prod])
class ProductRemoteDataSource extends BaseRemoteDataSource
    implements IRemoteProductDataSource {
  ProductRemoteDataSource(super.client, {required super.logger});

  @override
  Future<List<ProductModel>> getAll() async {
    final response = await get('product/');
    final data = response.data;
    if (data is! List) return const [];
    return List.from(data)
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }
}
```

### Mock Datasource

```dart
import 'package:injectable/injectable.dart';

import 'i_remote_product_data_source.dart';
import '../models/product_model.dart';

@LazySingleton(as: IRemoteProductDataSource, env: [AppEnvironment.mock])
class MockProductRemoteDataSource implements IRemoteProductDataSource {
  @override
  Future<List<ProductModel>> getAll() async {
    return const [];
  }
}
```

---

## Зависимости

### pubspec.yaml (с --freezed --injectable)

```yaml
dependencies:
  nexo: ^0.0.5-beta.0
  injectable: ^2.5.0
  freezed_annotation: ^3.1.0
  json_annotation: ^4.11.0

dev_dependencies:
  build_runner: ^2.13.1
  freezed: ^4.0.0
  json_serializable: ^6.13.1
  injectable_generator: ^2.7.0
```

### pubspec.yaml (без freezed/injectable)

```yaml
dependencies:
  nexo: ^0.0.5-beta.0

dev_dependencies:
  # не требуются
```

---

## Пост-генерация

### 1. Установи зависимости

```bash
flutter pub get
```

### 2. Запусти build_runner (если есть freezed/injectable)

```bash
dart run build_runner build --delete-conflicting-outputs
```

Это создаст файлы:
- `*.freezed.dart` — immutable-классы
- `*.g.dart` — JSON-сериализация
- `*.config.dart` — DI-регистрации

### 3. Подключи DI

В файле инициализации DI (обычно `lib/core/di/di.dart`):

```dart
import 'package:injectable/injectable.dart';

@injectableInit
Future<void> configureDependencies(String env) async =>
    GetIt.instance.init(environment: env);
```

### 4. Реализуй бизнес-логику

Замени `// TODO(nexo): implement` на реальный код:

```dart
@override
Future<List<ProductEntity>> getAll() async {
  final response = await get('products/');
  final data = response.data;
  if (data is! List) return const [];
  return List.from(data)
      .whereType<Map<String, dynamic>>()
      .map(ProductModel.fromJson)
      .toList();
}
```

---

## Частые вопросы

### Как выбрать между Bloc и Cubit?

| Критерий | Bloc | Cubit |
|----------|------|-------|
| Сложные event-driven логика | + | |
| Простой load/refresh | | + |
| Несколько источников событий | + | |
| Похожие на RPC-вызовы | | + |

### Зачем нужен mapper?

Mapper отделяет **data-слой** от **domain-слоя**:

```
Без mapper:
  API → Model → UseCase → UI
       ↑ все знают про JSON

С mapper:
  API → Model → Mapper → Entity → UseCase → UI
       ↑ JSON       ↑ чистый Dart
```

Если API поменяет формат — меняешь только mapper.

### Когда использовать --presentation-only?

Для фич, которые **потребляют** чужие cubit/bloc:

```bash
nexo_cli feature order_list --presentation-only --ui
```

Фича не имеет自己的 data/domain — только UI, который использует cubit из другой фичи.

### Как добавить навигацию?

После генерации добавь вручную:

```dart
// В screen файле
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OrderCubit>()..load(),
      child: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          return state.when(
            loading: () => const CircularProgressIndicator(),
            success: (data) => OrderList(items: data),
            error: (failure) => ErrorView(failure: failure),
          );
        },
      ),
    );
  }
}
```

### Как изменить API endpoint?

В datasource:

```dart
// Было
final response = await get('product/');

// Стало
final response = await get('v2/products/');
```

Изменение затрагивает **только datasource** — всё остальное работает.

---

## Сводка всех комбинаций

| # | Команда | Результат |
|---|---------|-----------|
| 1 | `feature splash --presentation-only` | Только экран |
| 2 | `feature auth --get` | GET список |
| 3 | `feature profile --get --list false` | GET объект |
| 4 | `feature product --get --create --update --delete` | Полный CRUD |
| 5 | `feature order --get --json '{"id":"String"}'` | Поля из JSON |
| 6 | `feature item --get --no-freezed` | Без @freezed |
| 7 | `feature data --get --no-injectable` | Без DI |
| 8 | `feature simple --get --no-freezed --no-injectable --no-mock --no-mapper` | Минимум |
| 9 | `feature full --bloc --freezed --json '...' --get --create --update --delete --tests` | Максимум |
| 10 | `feature list --list-cubit --get` | NexoListCubit |
