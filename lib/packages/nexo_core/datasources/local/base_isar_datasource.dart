import 'package:isar/isar.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

abstract class BaseIsarDataSource {
  final Isar isar;
  final NexoLogger _logger;

  const BaseIsarDataSource(this.isar, {required NexoLogger logger})
    : _logger = logger;

  String _tag(String message) => '[Isar] $message';

  Future<R> _run<R>(String action, Future<R> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      _logger.error(
        message: _tag(action),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  R _runSync<R>(String action, R Function() operation) {
    try {
      return operation();
    } catch (error, stackTrace) {
      _logger.error(
        message: _tag(action),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<T> read<T>(Future<T> Function(Isar isar) action) {
    return _run('Read failed', () => action(isar));
  }

  Future<T> write<T>(Future<T> Function(Isar isar) action) {
    return _run(
      'Write transaction failed',
      () => isar.writeTxn<T>(() => action(isar)),
    );
  }

  Stream<T> watch<T>(Stream<T> Function(Isar isar) watcher) {
    return _runSync('Watch setup failed', () => watcher(isar));
  }
}
