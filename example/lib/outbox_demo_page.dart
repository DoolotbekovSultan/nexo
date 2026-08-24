import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';

class OutboxDemoPage extends StatefulWidget {
  const OutboxDemoPage({super.key});

  @override
  State<OutboxDemoPage> createState() => _OutboxDemoPageState();
}

class _OutboxDemoPageState extends State<OutboxDemoPage> {
  late final _outbox = NexoOutbox(store: InMemoryOutboxStore(), send: _send);

  var _offline = false;
  var _pending = 0;
  OutboxFlushResult? _lastResult;
  var _counter = 0;

  Future<void> _send(OutboxEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (_offline) {
      throw const Failure.network(type: NetworkFailure.noInternet);
    }
  }

  Future<void> _enqueue() async {
    _counter++;
    await _outbox.enqueue(
      path: '/posts',
      payload: {'title': 'Запись $_counter'},
    );
    await _updatePending();
  }

  Future<void> _flush() async {
    final result = await _outbox.flush();
    if (!mounted) return;

    setState(() => _lastResult = result);
    if (!result.isComplete && result.failure != null) {
      showFailureSnackBar(
        context,
        result.failure!,
        actionLabel: 'Ещё раз',
        onAction: _flush,
      );
    }
    await _updatePending();
  }

  Future<void> _updatePending() async {
    final size = await _outbox.size;
    if (!mounted) return;
    setState(() => _pending = size);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Офлайн-режим'),
          subtitle: const Text('send() бросает NetworkFailure'),
          value: _offline,
          onChanged: (value) => setState(() => _offline = value),
        ),
        const SizedBox(height: 8),
        Text('В очереди: $_pending'),
        Text('Последний flush: ${_lastResult ?? '—'}'),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _enqueue,
              icon: const Icon(Icons.add),
              label: const Text('enqueue()'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _flush,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('flush()'),
            ),
          ],
        ),
      ],
    );
  }
}
