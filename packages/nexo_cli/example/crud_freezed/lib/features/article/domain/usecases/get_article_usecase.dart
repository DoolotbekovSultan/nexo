import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/article_entity.dart';
import '../repositories/i_article_repository.dart';

@injectable
class GetArticleUseCase extends NexoUseCase<List<ArticleEntity>, NoParams> {
  GetArticleUseCase(super._logger, {required IArticleRepository repository})
    : _repository = repository;

  final IArticleRepository _repository;

  @override
  Future<List<ArticleEntity>> execute(NoParams params) async {
    return await _repository.getAll();
  }
}
