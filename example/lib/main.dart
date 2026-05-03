import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';
import 'package:talker/talker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexoExampleApp());
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
            const Text('Logger + BlocObserver'),
            const SizedBox(height: 8),
            _LoggerDemo(),
          ],
        ),
      ),
    );
  }
}

class _LoggerDemo extends StatefulWidget {
  @override
  State<_LoggerDemo> createState() => _LoggerDemoState();
}

class _LoggerDemoState extends State<_LoggerDemo> {
  late final Talker _talker;
  late final NexoLogger _logger;

  @override
  void initState() {
    super.initState();
    _talker = Talker();
    _logger = TalkerLoggerAdapter(_talker);
    Bloc.observer = NexoBlocObserver(_logger, logEvents: false);
    _logger.debug('Example started');
  }

  @override
  Widget build(BuildContext context) {
    return Text('Open console for Talker / BlocObserver logs.');
  }
}
