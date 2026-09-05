import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/article_entity.dart';
import '../../domain/usecases/get_article_usecase.dart';
import 'article_event.dart';
import 'article_state.dart';

@injectable
class ArticleBloc extends NexoBloc<ArticleEvent, ArticleState> {
  ArticleBloc({
    required GetArticleUseCase getArticleUseCase,
  })  : _getArticleUseCase = getArticleUseCase,
        super(const ArticleState.loading()) {
    on<ArticleEvent>(_onEvent);
  }

  final GetArticleUseCase _getArticleUseCase;

  Future<void> _onEvent(
    ArticleEvent event,
    Emitter<ArticleState> emit,
  ) async {
    await event.when(load: () => _onLoad(emit));
  }

  Future<void> _onLoad(Emitter<ArticleState> emit) async {
    await executeEither<List<ArticleEntity>>(
      emit: emit,
      action: () => _getArticleUseCase(const NoParams()),
      onLoading: () => const ArticleState.loading(),
      onSuccess: (data) => ArticleState.success(data: data),
      onError: (failure) => ArticleState.error(failure: failure),
    );
  }
}
