import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:injectable/injectable.dart';

import 'i_remote_article_data_source.dart';
import '../models/article_model.dart';

@LazySingleton(as: IRemoteArticleDataSource, env: [AppEnvironment.prod])
class ArticleRemoteDataSource extends BaseRemoteDataSource
    implements IRemoteArticleDataSource {
  ArticleRemoteDataSource(super.client, {required super.logger});

  @override
  Future<List<ArticleModel>> getAll() async {
    final response = await get('article/');
    final data = response.data;
    if (data is! List) return const [];
    return List.from(
      data,
    ).whereType<Map<String, dynamic>>().map(ArticleModel.fromJson).toList();
  }
}
