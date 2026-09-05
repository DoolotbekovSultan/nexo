import '../models/article_model.dart';
import '../entities/article_entity.dart';

extension ArticleMapper on ArticleModel {
  ArticleEntity toDomain() => ArticleEntity(id: id);
}

extension ArticleListMapper on List<ArticleModel> {
  List<ArticleEntity> toDomain() => map((e) => e.toDomain()).toList();
}
