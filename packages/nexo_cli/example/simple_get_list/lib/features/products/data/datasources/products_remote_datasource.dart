import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:injectable/injectable.dart';

import 'i_remote_products_data_source.dart';
import '../models/products_model.dart';

@LazySingleton(as: IRemoteProductsDataSource, env: [AppEnvironment.prod])
class ProductsRemoteDataSource extends BaseRemoteDataSource
    implements IRemoteProductsDataSource {
  ProductsRemoteDataSource(super.client, {required super.logger});

  @override
  Future<List<ProductsModel>> getAll() async {
    final response = await get('products/');
    final data = response.data;
    if (data is! List) return const [];
    return List.from(data)
        .whereType<Map<String, dynamic>>()
        .map(ProductsModel.fromJson)
        .toList();
  }
}
