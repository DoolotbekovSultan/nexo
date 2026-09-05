import '../models/products_model.dart';

abstract interface class ILocalProductsDataSource {
  Future<List<ProductsModel>> getAll();
}
