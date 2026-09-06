import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/article_entity.dart';
import '../repositories/i_article_repository.dart';

@injectable
class CreateArticleUseCase
    extends NexoUseCase<ArticleEntity, CreateArticleParams> {
  CreateArticleUseCase(super._logger, {required IArticleRepository repository})
    : _repository = repository;

  final IArticleRepository _repository;

  @override
  Future<ArticleEntity> execute(CreateArticleParams params) async {
    // TODO(nexo): implement create.
    return (await _repository.getAll()).first;
  }
}

@injectable
class UpdateArticleUseCase
    extends NexoUseCase<ArticleEntity, UpdateArticleParams> {
  UpdateArticleUseCase(super._logger, {required IArticleRepository repository})
    : _repository = repository;

  final IArticleRepository _repository;

  @override
  Future<ArticleEntity> execute(UpdateArticleParams params) async {
    // TODO(nexo): implement update.
    return (await _repository.getAll()).first;
  }
}

@injectable
class DeleteArticleUseCase extends NexoUseCase<void, String> {
  DeleteArticleUseCase(super._logger, {required IArticleRepository repository})
    : _repository = repository;

  final IArticleRepository _repository;

  @override
  Future<void> execute(String id) async {
    // TODO(nexo): implement delete.
    await _repository.getAll();
  }
}
