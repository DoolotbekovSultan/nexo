import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nexo_bloc/src/pagination_controller.dart';

/// Миксин для добавления пагинации в BLoC/Cubit.
///
/// Инкапсулирует состояние пагинации через [PaginationController] и предоставляет
/// метод [loadMore] для автоматической загрузки следующей страницы с маппингом
/// состояний: загрузка, готовность, ошибка.
///
/// ## Параметры
///
/// - [T] — тип элементов.
/// - [Cursor] — тип курсора (обычно `String` или `int`).
///
/// ## Пример использования
///
/// ```dart
/// class ClipsFeedBloc extends NexoBloc<ClipsFeedEvent, ClipsFeedState>
///     with NexoPaginatedMixin<ClipFeedEntity, int> {
///
///   ClipsFeedBloc({required GetClipsFeedUseCase getClipsFeedUseCase})
///       : _getClipsFeedUseCase = getClipsFeedUseCase,
///         super(const ClipsFeedState.loading()) {
///     on<ClipsFeedEvent>(_onEvent);
///   }
///
///   final GetClipsFeedUseCase _getClipsFeedUseCase;
///
///   Future<void> _onLoadMore(Emitter<ClipsFeedState> emit) async {
///     await loadMore(
///       emit: emit,
///       loader: (cursor) async {
///         final result = await _getClipsFeedUseCase(
///           GetClipsFeedParams(cursor: cursor),
///         );
///         return result.fold(
///           onFailure: (f) => throw Exception(f.userMessage),
///           onSuccess: (data) => PageChunk(
///             items: data.clips,
///             nextCursor: data.nextCursor,
///             hasMore: data.hasMore,
///           ),
///         );
///       },
///       onReady: (items, hasMore) => ClipsFeedState.ready(
///         clips: items,
///         hasMore: hasMore,
///       ),
///     );
///   }
/// }
/// ```
///
/// См. также: [PaginationController], [PageChunk].
mixin NexoPaginatedMixin<T, Cursor> {
  /// Контроллер пагинации.
  final PaginationController<T, Cursor> _paginationController =
      PaginationController();

  /// Текущий список загруженных элементов.
  List<T> get paginatedItems => _paginationController.items;

  /// Курсор для загрузки следующей страницы.
  Cursor? get nextCursor => _paginationController.nextCursor;

  /// `true`, если есть ещё данные для загрузки.
  bool get hasMore => _paginationController.hasMore;

  /// `true`, если сейчас выполняется загрузка страницы.
  bool get isPaginatedLoading => _paginationController.isLoading;

  /// Загружает следующую страницу данных.
  ///
  /// [emit] — emitter для отправки состояний.
  /// [loader] — функция загрузки страницы, принимающая курсор и возвращающая
  /// [PageChunk] с элементами и информацией о следующей странице.
  /// [onReady] — функция создания состояния из загруженных элементов и флага
  /// наличия данных для загрузки.
  ///
  /// Автоматически обрабатывает ошибки и управляет состоянием загрузки.
  Future<void> loadMore<S>({
    required Emitter<S> emit,
    required Future<PageChunk<T, Cursor>> Function(Cursor? cursor) loader,
    required S Function(List<T> items, bool hasMore) onReady,
  }) async {
    if (_paginationController.isLoading || !_paginationController.hasMore) {
      return;
    }

    try {
      final page = await _paginationController.loadNext(loader: loader);
      if (page != null && !emit.isDone) {
        emit(
          onReady(_paginationController.items, _paginationController.hasMore),
        );
      }
    } catch (e) {
      if (!emit.isDone) {
        // В случае ошибки просто пропускаем — состояние остаётся прежним
        // Пользователь может повторить попытку
        return;
      }
    }
  }

  /// Заменяет все загруженные данные новыми.
  ///
  /// [items] — новые элементы.
  /// [nextCursor] — курсор для следующей страницы (опционально).
  /// [hasMore] — флаг наличия данных для загрузки.
  void replaceAllPaginated(
    List<T> items, {
    Cursor? nextCursor,
    required bool hasMore,
  }) {
    _paginationController.replaceAll(
      items,
      nextCursor: nextCursor,
      hasMore: hasMore,
    );
  }

  /// Сбрасывает состояние пагинации.
  void resetPagination() {
    _paginationController.reset();
  }
}
