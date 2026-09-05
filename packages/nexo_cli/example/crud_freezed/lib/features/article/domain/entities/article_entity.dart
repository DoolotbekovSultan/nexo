import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_entity.freezed.dart';

@freezed
abstract class ArticleEntity with _$ArticleEntity {
  const factory ArticleEntity({required String id}) = _ArticleEntity;
}
