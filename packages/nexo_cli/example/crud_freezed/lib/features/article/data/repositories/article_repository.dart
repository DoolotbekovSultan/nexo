import 'package:injectable/injectable.dart';

import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/i_article_repository.dart';
import '../datasources/i_remote_article_data_source.dart';

@LazySingleton(as: IArticleRepository)
class ArticleRepository implements IArticleRepository {
  ArticleRepository({required this._remoteDatasource});

  final IRemoteArticleDataSource _remoteDatasource;

  @override
  Future<List<ArticleEntity>> getAll() async {
    final models = await _remoteDatasource.getAll();
    return models.toDomain();
  }
}
