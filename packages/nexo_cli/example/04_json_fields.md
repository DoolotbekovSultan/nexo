# Example 4: Feature with JSON Fields

Feature with pre-defined model fields from JSON.

## Command

```bash
nexo_cli feature product --get --create --json '{"id": "String", "name": "String", "price": "double", "isActive": "bool", "tags": "List<dynamic>"}'
```

## Generated Model

```dart
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    required this.tags,
  });

  final String id;
  final String name;
  final double price;
  final bool isActive;
  final List<dynamic> tags;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
      tags: json['tags'] as List<dynamic>? ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'isActive': isActive, 'tags': tags};
  }
}
```

## Generated Entity

```dart
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.isActive,
    required this.tags,
  });

  final String id;
  final String name;
  final double price;
  final bool isActive;
  final List<dynamic> tags;
}
```

## Generated Mapper

```dart
extension ProductMapper on ProductModel {
  ProductEntity toDomain() => ProductEntity(
    id: id,
    name: name,
    price: price,
    isActive: isActive,
    tags: tags,
  );
}
```

## JSON Field Types

| JSON Type | Dart Type |
|-----------|-----------|
| `"string"` | `String` |
| `42` | `int` |
| `3.14` | `double` |
| `true` | `bool` |
| `[]` | `List<dynamic>` |
| `{}` | `Map<String, dynamic>` |
| `null` | `String?` |
