import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_event.freezed.dart';

@freezed
abstract class ArticleEvent with _$ArticleEvent {
  const factory ArticleEvent.load() = _ArticleLoad;
}
