import 'package:injectable/injectable.dart';

import 'i_remote_products_data_source.dart';
import '../models/products_model.dart';

@LazySingleton(as: IRemoteProductsDataSource, env: [AppEnvironment.mock])
class MockProductsRemoteDataSource implements IRemoteProductsDataSource {
  @override
  Future<List<ProductsModel>> getAll() async {
    return const [];
  }
}
