import '../entities/article_entity.dart';

abstract interface class IArticleRepository {
  Future<List<ArticleEntity>> getAll();
}
