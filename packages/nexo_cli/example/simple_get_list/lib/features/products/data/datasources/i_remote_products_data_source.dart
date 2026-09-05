import '../models/products_model.dart';

abstract interface class IRemoteProductsDataSource {
  Future<List<ProductsModel>> getAll();
}
