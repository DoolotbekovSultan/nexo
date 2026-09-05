import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/products_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_state.dart';

@injectable
class ProductsCubit extends NexoCubit<ProductsState> {
  ProductsCubit({required GetProductsUseCase getProductsUseCase})
    : _getProductsUseCase = getProductsUseCase,
      super(const NexoAsyncLoading());

  final GetProductsUseCase _getProductsUseCase;

  Future<void> load() async {
    await executeEither<List<ProductsEntity>>(
      action: () => _getProductsUseCase(const NoParams()),
      onLoading: () => const NexoAsyncLoading(),
      onSuccess: (data) => NexoAsyncSuccess(data),
      onError: (failure) => NexoAsyncFailure(failure),
    );
  }
}
