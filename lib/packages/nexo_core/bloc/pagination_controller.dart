class PageChunk<T, Cursor> {
  final List<T> items;
  final Cursor? nextCursor;
  final bool hasMore;

  const PageChunk({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });
}

class PaginationController<T, Cursor> {
  List<T> _items = [];
  Cursor? _nextCursor;
  bool _hasMore = true;
  bool _isLoading = false;

  List<T> get items => List.unmodifiable(_items);
  Cursor? get nextCursor => _nextCursor;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  void reset() {
    _items = [];
    _nextCursor = null;
    _hasMore = true;
    _isLoading = false;
  }

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

  void replaceAll(List<T> items, {Cursor? nextCursor, required bool hasMore}) {
    _items = [...items];
    _nextCursor = nextCursor;
    _hasMore = hasMore;
  }
}
