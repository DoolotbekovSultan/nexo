import '../entities/products_entity.dart';

abstract interface class IProductsRepository {
  Future<List<ProductsEntity>> getAll();
}
