/// Порция данных при постраничной загрузке.
///
/// [T] — тип элементов, [Cursor] — тип курсора для следующей страницы.
///
/// ## Пример
///
/// ```dart
/// final page = PageChunk(
///   items: [User(name: 'Alice'), User(name: 'Bob')],
///   nextCursor: 'page_2',
///   hasMore: true,
/// );
/// ```
class PageChunk<T, Cursor> {
  /// Элементы текущей страницы.
  final List<T> items;

  /// Курсор для загрузки следующей страницы; `null` если данных больше нет.
  final Cursor? nextCursor;

  /// `true`, если есть ещё данные для загрузки.
  final bool hasMore;

  /// Создаёт порцию данных [PageChunk].
  const PageChunk({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}

/// Контроллер постраничной загрузки данных.
///
/// Управляет состоянием пагинации: хранит загруженные элементы,
/// курсор следующей страницы и флаг наличия данных. Предоставляет
/// методы для загрузки следующей страницы и сброса состояния.
///
/// ## Параметры
///
/// - [T] — тип элементов.
/// - [Cursor] — тип курсора (обычно `String` или `int`).
///
/// ## Пример использования
///
/// ```dart
/// final controller = PaginationController<User, String>();
///
/// // Загрузка первой страницы
/// final firstPage = await controller.loadNext(
///   loader: (cursor) => api.getUsers(cursor: cursor),
/// );
///
/// // Загрузка следующей страницы
/// if (controller.hasMore) {
///   await controller.loadNext(
///     loader: (cursor) => api.getUsers(cursor: cursor),
///   );
/// }
///
/// // Все загруженные элементы
/// final users = controller.items;
/// ```
class PaginationController<T, Cursor> {
  List<T> _items = [];
  Cursor? _nextCursor;
  bool _hasMore = true;
  bool _isLoading = false;

  /// Неизменяемый список загруженных элементов.
  List<T> get items => List.unmodifiable(_items);

  /// Курсор для загрузки следующей страницы; `null` если данных больше нет.
  Cursor? get nextCursor => _nextCursor;

  /// `true`, если есть ещё данные для загрузки.
  bool get hasMore => _hasMore;

  /// `true`, если сейчас выполняется загрузка страницы.
  bool get isLoading => _isLoading;

  /// Сбрасывает состояние контроллера.
  ///
  /// Очищает загруженные элементы, сбрасывает курсор и флаги.
  void reset() {
    _items = [];
    _nextCursor = null;
    _hasMore = true;
    _isLoading = false;
  }

  /// Загружает следующую страницу данных.
  ///
  /// [loader] — функция загрузки страницы, принимающая курсор и возвращающая
  /// [PageChunk] с элементами и информацией о следующей странице.
  ///
  /// **Возвращает:** [Future] с загруженной порцией или `null`, если
  /// загрузка уже идёт или данные закончились.
  Future<PageChunk<T, Cursor>?> loadNext({
    required Future<PageChunk<T, Cursor>> Function(Cursor? cursor) loader,
  }) async {
    if (_isLoading || !_hasMore) return null;

    _isLoading = true;
    try {
      final page = await loader(_nextCursor);
      _items = [..._items, ...page.items];
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      return page;
    } finally {
      _isLoading = false;
    }
  }

  /// Заменяет все загруженные данные новыми.
  ///
  /// [items] — новые элементы.
  /// [nextCursor] — курсор для следующей страницы (опционально).
  /// [hasMore] — флаг наличия данных для загрузки.
  void replaceAll(List<T> items, {Cursor? nextCursor, required bool hasMore}) {
    _items = [...items];
    _nextCursor = nextCursor;
    _hasMore = hasMore;
  }
}
