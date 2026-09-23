import 'package:flutter_test/flutter_test.dart';
import 'package:nexo_errors/nexo_errors.dart';
import 'package:nexo_logger/nexo_logger.dart';
import 'package:nexo_usecase/nexo_usecase.dart';

class _FakeLogger implements NexoLogger {
  @override
  void debug(String message) {}

  @override
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  }) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}
}

class _AddOne extends NexoUseCase<int, int> {
  _AddOne(super.logger);

  @override
  Future<int> execute(int params) async => params + 1;
}

void main() {
  test('NexoUseCase returns success on happy path', () async {
    final uc = _AddOne(_FakeLogger());
    final r = await uc(41);
    expect(r, const Right(42));
  });

  test('NexoUseCase returns failure on thrown exception', () async {
    final uc = _Throwing(_FakeLogger());
    final r = await uc(0);
    expect(r.isFailure, isTrue);
  });
}

class _Throwing extends NexoUseCase<int, int> {
  _Throwing(super.logger);

  @override
  Future<int> execute(int params) async => throw StateError('boom');
}
