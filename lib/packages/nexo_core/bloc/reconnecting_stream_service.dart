import 'dart:async';

abstract class StreamFactory<T> {
  Stream<T> create();
}

class ReconnectingStreamService<T> {
  ReconnectingStreamService({
    required this.factory,
    this.retryDelay = const Duration(seconds: 2),
  });

  final StreamFactory<T> factory;
  final Duration retryDelay;

  Stream<T> connect() async* {
    while (true) {
      try {
        yield* factory.create();
      } catch (_) {
        await Future<void>.delayed(retryDelay);
      }
    }
  }
}
