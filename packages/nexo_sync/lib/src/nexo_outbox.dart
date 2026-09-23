import 'dart:async';

import 'package:nexo_errors/nexo_errors.dart';
import 'package:nexo_logger/nexo_logger.dart';

/// Элемент очереди офлайн-мутаций.
///
/// [id] передавайте на сервер как ключ идемпотентности
/// (например, заголовок `Idempotency-Key`), чтобы повторная доставка
/// после сбоя сети не создавала дубликатов.
final class OutboxEntry {
  /// Создаёт элемент очереди офлайн-мутаций.
  ///
  /// [id] — уникальный идентификатор (ключ идемпотентности).
  /// [path] — путь или логическое имя операции.
  /// [method] — HTTP-метод. По умолчанию: `POST`.
  /// [payload] — данные операции. По умолчанию: пустая карта.
  /// [createdAt] — момент постановки в очередь.
  /// [attempts] — количество попыток доставки. По умолчанию: 0.
  const OutboxEntry({
    required this.id,
    required this.path,
    this.method = 'POST',
    this.payload = const {},
    required this.createdAt,
    this.attempts = 0,
  });

  /// Создаёт элемент очереди с автоматической генерацией [id] и [createdAt].
  ///
  /// [path] — путь или логическое имя операции.
  /// [method] — HTTP-метод. По умолчанию: `POST`.
  /// [payload] — данные операции (опционально).
  /// [id] — кастомный идентификатор (опционально, если не задан — генерируется).
  factory OutboxEntry.create({
    required String path,
    String method = 'POST',
    Map<String, dynamic>? payload,
    String? id,
  }) {
    return OutboxEntry(
      id: id ?? _generateId(),
      path: path,
      method: method,
      payload: payload ?? const {},
      createdAt: DateTime.now(),
    );
  }

  /// Уникальный идентификатор операции (ключ идемпотентности).
  final String id;

  /// Путь или логическое имя операции; интерпретирует ваш [NexoOutbox.send].
  final String path;

  /// HTTP-метод (или аналог для не-REST бэкендов).
  final String method;

  /// Данные операции; должны быть JSON-сериализуемыми для персистентных хранилищ.
  final Map<String, dynamic> payload;

  /// Момент постановки в очередь.
  final DateTime createdAt;

  /// Сколько раз доставку уже пытались выполнить.
  final int attempts;

  static int _counter = 0;

  static String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

  /// Создаёт копию элемента с возможностью изменения [attempts].
  OutboxEntry copyWith({int? attempts}) => OutboxEntry(
    id: id,
    path: path,
    method: method,
    payload: payload,
    createdAt: createdAt,
    attempts: attempts ?? this.attempts,
  );

  /// Сериализует элемент в JSON-совместимую карту.
  Map<String, dynamic> toMap() => {
    'id': id,
    'path': path,
    'method': method,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
    'attempts': attempts,
  };

  /// Десериализует элемент из JSON-карты.
  ///
  /// Поддерживает ключи `created_at` и `createdAt` для обратной совместимости.
  factory OutboxEntry.fromMap(Map<String, dynamic> map) => OutboxEntry(
    id: map['id'] as String,
    path: map['path'] as String,
    method: (map['method'] as String?) ?? 'POST',
    payload: (map['payload'] as Map<String, dynamic>?) ?? const {},
    createdAt: DateTime.parse(
      map['created_at'] as String? ?? map['createdAt'] as String,
    ),
    attempts: (map['attempts'] as num?)?.toInt() ?? 0,
  );

  @override
  bool operator ==(Object other) =>
      other is OutboxEntry &&
      other.id == id &&
      other.path == path &&
      other.method == method &&
      other.attempts == attempts;

  @override
  int get hashCode => Object.hash(id, path, method, attempts);

  @override
  String toString() => 'OutboxEntry($id, $method $path, attempts: $attempts)';
}

/// Персистентное хранилище очереди; реализуйте поверх своей БД
/// (готовые датасорсы пакета: Hive / Isar / Drift / secure storage).
///
/// Контракт простой: [save] атомарно заменяет весь список, [load]
/// возвращает его же после перезапуска приложения.
abstract interface class OutboxStore {
  /// Загружает все элементы очереди из хранилища.
  Future<List<OutboxEntry>> load();

  /// Сохраняет все элементы очереди, заменяя предыдущее содержимое.
  Future<void> save(List<OutboxEntry> entries);
}

/// Реализация [OutboxStore] в памяти; подходит для тестов и как значение
/// по умолчанию. В продакшене используйте персистентное хранилище.
final class InMemoryOutboxStore implements OutboxStore {
  List<OutboxEntry> _entries = const [];

  /// Возвращает копию всех элементов очереди из памяти.
  @override
  Future<List<OutboxEntry>> load() async => List.of(_entries);

  /// Сохраняет элементы в память (заменяет предыдущее содержимое).
  @override
  Future<void> save(List<OutboxEntry> entries) async {
    _entries = List.of(entries);
  }
}

/// Итог прохода [NexoOutbox.flush].
final class OutboxFlushResult {
  const OutboxFlushResult({
    required this.sent,
    required this.remaining,
    this.failure,
  });

  /// Сколько операций доставлено за этот вызов.
  final int sent;

  /// Сколько операций осталось в очереди.
  final int remaining;

  /// Ошибка, остановившая доставку; `null` — очередь пуста.
  final Failure? failure;

  /// `true`, если все операции доставлены успешно и очередь пуста.
  bool get isComplete => remaining == 0 && failure == null;

  @override
  String toString() =>
      'OutboxFlushResult(sent: $sent, remaining: $remaining, '
      'failure: ${failure?.code})';
}

/// Очередь офлайн-мутаций (паттерн outbox): действия пользователя попадают
/// в локальную очередь мгновенно, а [flush] доставляет их на сервер, когда
/// появится сеть.
///
/// ```dart
/// final outbox = NexoOutbox(
///   store: InMemoryOutboxStore(), // в проде — своя реализация поверх БД
///   send: (entry) => dio.request(
///     entry.path,
///     options: Options(method: entry.method),
///     data: entry.payload,
///     // ключ идемпотентности, чтобы ретраи не создавали дубликаты:
///     // headers не задаются здесь — добавьте их внутри send при необходимости
///   ),
///   logger: logger,
/// );
///
/// // Пользовательское действие — «успех» для UI сразу:
/// await outbox.enqueue(path: '/posts', payload: {'title': 'Привет'});
///
/// // По возврату сети (connectivity_plus) или на старте приложения:
/// final result = await outbox.flush();
/// if (!result.isComplete) showFailureSnackBar(context, result.failure!);
/// ```
///
/// Гарантии: операции доставляются строго в порядке постановки в очередь;
/// при ошибке доставка останавливается на текущей операции (последующие не
/// выполняются), счётчик [OutboxEntry.attempts] растёт, ошибка возвращается
/// маппнутой в [Failure].
class NexoOutbox {
  /// Создаёт очередь офлайн-мутаций.
  ///
  /// [store] — хранилище очереди (персистентное или in-memory).
  /// [send] — функция доставки одной операции; броски маппятся в [Failure].
  /// [logger] — логгер (опционально).
  NexoOutbox({required this.store, required this.send, this.logger});

  /// Хранилище очереди.
  final OutboxStore store;

  /// Доставка одной операции; броски маппятся в [Failure].
  final Future<void> Function(OutboxEntry entry) send;

  /// Логгер; опционален.
  final NexoLogger? logger;

  List<OutboxEntry>? _cache;

  Future<List<OutboxEntry>> _entries() async {
    return _cache ??= await store.load();
  }

  Future<void> _persist(List<OutboxEntry> entries) async {
    _cache = entries;
    await store.save(entries);
  }

  /// Количество операций в очереди.
  Future<int> get size async => (await _entries()).length;

  /// Кладёт операцию в конец очереди; для UI это уже «успех».
  Future<OutboxEntry> enqueue({
    required String path,
    String method = 'POST',
    Map<String, dynamic>? payload,
    String? id,
  }) async {
    final entry = OutboxEntry.create(
      path: path,
      method: method,
      payload: payload,
      id: id,
    );
    final entries = await _entries()
      ..add(entry);
    await _persist(entries);

    logger?.debug(
      'Outbox enqueued ${entry.method} ${entry.path} '
      '(${entries.length} pending)',
    );
    return entry;
  }

  /// Доставляет операции из головы очереди, пока не опустеет либо не
  /// произойдёт ошибка. Безопасно вызывать повторно (в т.ч. параллельно
  /// не нужно: каждый вызов работает по актуальному снимку очереди).
  Future<OutboxFlushResult> flush() async {
    var sent = 0;

    while (true) {
      final entries = await _entries();
      if (entries.isEmpty) {
        return OutboxFlushResult(sent: sent, remaining: 0);
      }

      final entry = entries.first;
      try {
        await send(entry);
      } catch (e, s) {
        final failure = e is Failure ? e : e.toFailure(s);
        final updated = [
          entry.copyWith(attempts: entry.attempts + 1),
          ...entries.skip(1),
        ];
        await _persist(updated);

        logger?.debug(
          'Outbox flush stopped: ${failure.code} '
          '(sent: $sent, pending: ${updated.length})',
        );
        return OutboxFlushResult(
          sent: sent,
          remaining: updated.length,
          failure: failure,
        );
      }

      await _persist(entries.sublist(1));
      sent++;
      logger?.debug('Outbox sent ${entry.method} ${entry.path}');
    }
  }
}
