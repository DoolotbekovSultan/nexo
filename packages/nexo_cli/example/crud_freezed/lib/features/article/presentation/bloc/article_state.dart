import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexo/nexo_errors.dart';

import '../../domain/entities/article_entity.dart';

part 'article_state.freezed.dart';

@freezed
abstract class ArticleState with _$ArticleState {
  const factory ArticleState.loading() = _ArticleStateLoading;
  const factory ArticleState.success({required List<ArticleEntity> data}) =
      _ArticleStateSuccess;
  const factory ArticleState.error({Failure? failure}) = _ArticleStateError;
}
