import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_core/bloc/pagination_controller.dart';

void main() {
  group('PaginationController', () {
    test('loadNext appends items and respects hasMore', () async {
      final c = PaginationController<int, int>();
      var calls = 0;

      final first = await c.loadNext(
        loader: (cursor) async {
          calls++;
          expect(cursor, isNull);
          return const PageChunk(items: [1, 2], nextCursor: 2, hasMore: true);
        },
      );

      expect(first?.items, [1, 2]);
      expect(c.items, [1, 2]);
      expect(c.hasMore, isTrue);
      expect(c.nextCursor, 2);
      expect(calls, 1);

      await c.loadNext(
        loader: (cursor) async {
          expect(cursor, 2);
          return const PageChunk(items: [3], nextCursor: null, hasMore: false);
        },
      );

      expect(c.items, [1, 2, 3]);
      expect(c.hasMore, isFalse);
    });

    test('returns null when hasMore is false', () async {
      final c = PaginationController<int, int>();
      await c.loadNext(
        loader: (_) async =>
            const PageChunk(items: [1], nextCursor: null, hasMore: false),
      );
      final second = await c.loadNext(
        loader: (_) async =>
            const PageChunk(items: [99], nextCursor: null, hasMore: false),
      );
      expect(second, isNull);
      expect(c.items, [1]);
    });

    test('reset clears state', () async {
      final c = PaginationController<int, int>();
      await c.loadNext(
        loader: (_) async =>
            const PageChunk(items: [1], nextCursor: 1, hasMore: true),
      );
      c.reset();
      expect(c.items, isEmpty);
      expect(c.hasMore, isTrue);
      expect(c.isLoading, isFalse);
    });
  });
}
