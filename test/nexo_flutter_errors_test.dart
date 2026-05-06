import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';

class _FakeLogger implements NexoLogger {
  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}

  @override
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  }) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    NexoFlutterErrors.uninstall();
  });

  test('runAppInZone reports errors thrown from async body', () async {
    final logger = _FakeLogger();
    final crash = CollectingNexoCrashReporter();
    NexoFlutterErrors.install(logger: logger, crashReporter: crash);

    await NexoFlutterErrors.runAppInZone(() async {
      throw StateError('zone test');
    });
    expect(crash.recordedErrors, isNotEmpty);
    expect(crash.recordedErrors.first.error, isA<StateError>());
  });
}
