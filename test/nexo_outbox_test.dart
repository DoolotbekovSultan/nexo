import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_sync/nexo_sync.dart';
import 'package:nexo_errors/nexo_errors.dart';

class _FailingThenOkSender {
  final sent = <OutboxEntry>[];

  bool failOnNext;

  _FailingThenOkSender({this.failOnNext = false});

  Future<void> call(OutboxEntry entry) async {
    if (failOnNext) {
      failOnNext = false;
      throw StateError('network is down');
    }
    sent.add(entry);
  }
}

void main() {
  test('пустой outbox: flush завершается без отправок', () async {
    final outbox = NexoOutbox(store: InMemoryOutboxStore(), send: (_) async {});

    final result = await outbox.flush();

    expect(result.sent, 0);
    expect(result.remaining, 0);
    expect(result.isComplete, isTrue);
    expect(await outbox.size, 0);
  });

  test('enqueue копит операции, flush доставляет в порядке FIFO', () async {
    final sender = _FailingThenOkSender();
    final outbox = NexoOutbox(store: InMemoryOutboxStore(), send: sender.call);

    await outbox.enqueue(path: '/posts/1/like');
    await outbox.enqueue(path: '/posts', payload: {'title': 'a'});
    await outbox.enqueue(path: '/posts/2', method: 'DELETE');

    expect(await outbox.size, 3);

    final result = await outbox.flush();

    expect(result.sent, 3);
    expect(result.isComplete, isTrue);
    expect(sender.sent.map((e) => e.path), [
      '/posts/1/like',
      '/posts',
      '/posts/2',
    ]);
    expect(await outbox.size, 0);
  });

  test(
    'ошибка на первой операции: очередь не тронута, attempts растёт',
    () async {
      final sender = _FailingThenOkSender(failOnNext: true);
      final outbox = NexoOutbox(
        store: InMemoryOutboxStore(),
        send: sender.call,
      );

      final first = await outbox.enqueue(path: '/a');
      await outbox.enqueue(path: '/b');

      final result = await outbox.flush();

      expect(sender.sent, isEmpty);
      expect(result.sent, 0);
      expect(result.remaining, 2);
      expect(result.failure, isNotNull);
      expect(result.failure!.code, isNotEmpty);

      final entries = await (outbox.store as InMemoryOutboxStore).load();
      expect(entries.first.id, first.id);
      expect(entries.first.attempts, 1, reason: 'счётчик попыток увеличен');
      expect(entries.map((e) => e.path), ['/a', '/b']);
    },
  );

  test('после сбоя повторный flush довозит всю очередь в порядке', () async {
    final sender = _FailingThenOkSender(failOnNext: true);
    final outbox = NexoOutbox(store: InMemoryOutboxStore(), send: sender.call);

    await outbox.enqueue(path: '/a');
    await outbox.enqueue(path: '/b');

    await outbox.flush();
    final retry = await outbox.flush();

    expect(retry.sent, 2);
    expect(retry.isComplete, isTrue);
    expect(sender.sent.map((e) => e.path), ['/a', '/b']);
  });

  test(
    'ошибка в середине: хвост не выполняется, порядок сохраняется',
    () async {
      var calls = 0;
      final sent = <String>[];
      final outbox = NexoOutbox(
        store: InMemoryOutboxStore(),
        send: (entry) async {
          calls++;
          if (calls == 2) throw Exception('server 500');
          sent.add(entry.path);
        },
      );

      await outbox.enqueue(path: '/first');
      await outbox.enqueue(path: '/second');
      await outbox.enqueue(path: '/third');

      final failed = await outbox.flush();

      expect(sent, ['/first'], reason: 'третья операция не должна была уйти');
      expect(failed.sent, 1);
      expect(failed.remaining, 2);

      final recovered = await outbox.flush();

      expect(recovered.isComplete, isTrue);
      expect(sent, ['/first', '/second', '/third']);
    },
  );

  test('брошенный Failure проходит насквозь без изменений', () async {
    const failure = Failure.sync(type: SyncFailure.timeout);
    final outbox = NexoOutbox(
      store: InMemoryOutboxStore(),
      send: (_) => throw failure,
    );
    await outbox.enqueue(path: '/x');

    final result = await outbox.flush();

    expect(result.failure, failure);
    expect(result.failure!.isRetryable, isTrue);
  });

  test('toMap/fromMap — обратимый roundtrip', () {
    final entry = OutboxEntry.create(
      path: '/posts',
      payload: {'title': 'привет'},
      id: 'fixed-id',
    );

    final restored = OutboxEntry.fromMap(entry.toMap());

    expect(restored.id, entry.id);
    expect(restored.path, entry.path);
    expect(restored.method, entry.method);
    expect(restored.payload, entry.payload);
    expect(restored.createdAt, entry.createdAt);
    expect(restored.attempts, entry.attempts);
  });

  test('store персистентен между экземплярами сервиса', () async {
    final store = InMemoryOutboxStore();
    final writer = NexoOutbox(store: store, send: (_) async {});

    await writer.enqueue(path: '/kept');

    final reader = NexoOutbox(store: store, send: (_) async {});
    expect(await reader.size, 1);
  });
}
