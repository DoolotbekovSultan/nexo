import '../models/article_model.dart';

abstract interface class IRemoteArticleDataSource {
  Future<List<ArticleModel>> getAll();
}
