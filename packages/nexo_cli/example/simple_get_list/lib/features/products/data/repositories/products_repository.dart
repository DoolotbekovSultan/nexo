import 'package:injectable/injectable.dart';

import '../../domain/entities/products_entity.dart';
import '../../domain/repositories/i_products_repository.dart';
import '../datasources/i_remote_products_data_source.dart';

@LazySingleton(as: IProductsRepository)
class ProductsRepository implements IProductsRepository {
  ProductsRepository({required this._remoteDatasource});

  final IRemoteProductsDataSource _remoteDatasource;

  @override
  Future<List<ProductsEntity>> getAll() async {
    final models = await _remoteDatasource.getAll();
    return models.toDomain();
  }
}
