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

class _Flaky extends NexoUseCase<int, int> {
  _Flaky(super.logger);

  var calls = 0;

  @override
  Future<int> execute(int params) async {
    calls++;
    if (calls < 2) {
      throw const Failure.network(type: NetworkFailure.timeout);
    }
    return 99;
  }
}

void main() {
  test('callWithRetry succeeds after transient failure', () async {
    final uc = _Flaky(_FakeLogger());
    final r = await uc.callWithRetry(
      0,
      maxAttempts: 3,
      baseDelay: Duration.zero,
    );
    expect(r, const Right(99));
    expect(uc.calls, 2);
  });
}
