import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_article_request.freezed.dart';
part 'create_article_request.g.dart';

@freezed
abstract class CreateArticleRequest with _$CreateArticleRequest {
  const factory CreateArticleRequest({required String id}) =
      _CreateArticleRequest;

  factory CreateArticleRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateArticleRequestFromJson(json);
}
