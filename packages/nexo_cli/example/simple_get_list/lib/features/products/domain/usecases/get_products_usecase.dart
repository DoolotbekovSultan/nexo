import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/products_entity.dart';
import '../repositories/i_products_repository.dart';

@injectable
class GetProductsUseCase extends NexoUseCase<List<ProductsEntity>, NoParams> {
  GetProductsUseCase(
    super._logger, {
    required IProductsRepository repository,
  }) : _repository = repository;

  final IProductsRepository _repository;

  @override
  Future<List<ProductsEntity>> execute(NoParams params) async {
    return await _repository.getAll();
  }
}
