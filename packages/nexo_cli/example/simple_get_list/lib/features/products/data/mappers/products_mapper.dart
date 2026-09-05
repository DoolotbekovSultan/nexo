import '../models/products_model.dart';
import '../entities/products_entity.dart';

extension ProductsMapper on ProductsModel {
  ProductsEntity toDomain() => ProductsEntity(id: id);
}

extension ProductsListMapper on List<ProductsModel> {
  List<ProductsEntity> toDomain() => map((e) => e.toDomain()).toList();
}
