import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:injectable/injectable.dart';

import 'i_local_products_data_source.dart';
import '../models/products_model.dart';

@LazySingleton(as: ILocalProductsDataSource, env: [AppEnvironment.prod])
class ProductsLocalDataSource extends BaseLocalDataSource
    implements ILocalProductsDataSource {
  ProductsLocalDataSource({required super.logger});

  @override
  Future<List<ProductsModel>> getAll() async {
    // TODO(nexo): implement local storage read.
    return const [];
  }
}
