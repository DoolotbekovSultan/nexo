import '../models/product_model.dart';
import '../entities/product_entity.dart';

extension ProductMapper on ProductModel {
  ProductEntity toDomain() => ProductEntity(
    id: id,
    name: name,
    price: price,
    isActive: isActive,
    tags: tags,
  );
}

extension ProductListMapper on List<ProductModel> {
  List<ProductEntity> toDomain() => map((e) => e.toDomain()).toList();
}
