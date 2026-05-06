import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';
import 'package:talker/talker.dart';

Future<void> main() async {
  await NexoFlutterErrors.runAppInZone(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final talker = Talker();
    final logger = TalkerLoggerAdapter(talker);
    const crashReporter = NoOpNexoCrashReporter();
    NexoFlutterErrors.install(logger: logger, crashReporter: crashReporter);
    Bloc.observer = NexoBlocObserver(
      logger,
      crashReporter: crashReporter,
      logEvents: false,
    );
    logger.debug('Example starting (NexoFlutterErrors + NexoBlocObserver)');
    runApp(const NexoExampleApp());
  });
}

class NexoExampleApp extends StatelessWidget {
  const NexoExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'nexo example', home: const _FailureDemoPage());
  }
}

class _FailureDemoPage extends StatelessWidget {
  const _FailureDemoPage();

  @override
  Widget build(BuildContext context) {
    const failure = Failure.network(type: NetworkFailure.noInternet);
    const ru = RuFailureUserMessages();
    const en = EnFailureUserMessages();

    return Scaffold(
      appBar: AppBar(title: const Text('nexo example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('userMessage (default RU): ${failure.userMessage}'),
            const SizedBox(height: 8),
            Text('EN catalog: ${failure.localizedMessage(en)}'),
            const SizedBox(height: 8),
            Text('RU catalog: ${failure.localizedMessage(ru)}'),
            const SizedBox(height: 8),
            Text('isRetryable: ${failure.isRetryable}'),
            const SizedBox(height: 8),
            Text('logCategory: ${failure.logCategory}'),
            const Divider(),
            const Text('Logger + BlocObserver (see console)'),
            const SizedBox(height: 8),
            const _LoggerDemo(),
          ],
        ),
      ),
    );
  }
}

class _LoggerDemo extends StatelessWidget {
  const _LoggerDemo();

  @override
  Widget build(BuildContext context) {
    return const Text('Global handlers installed in main().');
  }
}
