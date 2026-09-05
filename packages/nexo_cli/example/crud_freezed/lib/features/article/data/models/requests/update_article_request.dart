import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_article_request.freezed.dart';
part 'update_article_request.g.dart';

@freezed
abstract class UpdateArticleRequest with _$UpdateArticleRequest {
  const factory UpdateArticleRequest({required String id}) =
      _UpdateArticleRequest;

  factory UpdateArticleRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateArticleRequestFromJson(json);
}
