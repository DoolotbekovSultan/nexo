import 'package:injectable/injectable.dart';

import 'i_local_products_data_source.dart';
import '../models/products_model.dart';

@LazySingleton(as: ILocalProductsDataSource, env: [AppEnvironment.mock])
class MockProductsLocalDataSource implements ILocalProductsDataSource {
  @override
  Future<List<ProductsModel>> getAll() async {
    return const [];
  }
}
