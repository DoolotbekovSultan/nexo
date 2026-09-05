import 'package:injectable/injectable.dart';

import 'i_remote_article_data_source.dart';
import '../models/article_model.dart';

@LazySingleton(as: IRemoteArticleDataSource, env: [AppEnvironment.mock])
class MockArticleRemoteDataSource implements IRemoteArticleDataSource {
  @override
  Future<List<ArticleModel>> getAll() async {
    return const [];
  }
}
