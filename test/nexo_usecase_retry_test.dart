import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_core/usecase/nexo_usecase.dart';
import 'package:nexo/packages/nexo_core/usecase/nexo_usecase_retry.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

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
