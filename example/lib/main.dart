import 'package:flutter/material.dart';
import 'package:nexo/nexo.dart';
import 'package:nexo_example/async_demo_page.dart';
import 'package:nexo_example/feedback_demo_page.dart';
import 'package:nexo_example/form_demo_page.dart';
import 'package:nexo_example/outbox_demo_page.dart';
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
    runApp(const NexoExampleApp());
  });
}

class NexoExampleApp extends StatelessWidget {
  const NexoExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nexo example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const DemoShell(),
    );
  }
}

class DemoShell extends StatefulWidget {
  const DemoShell({super.key});

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  var _index = 0;

  static const _pages = [
    AsyncDemoPage(),
    FormDemoPage(),
    FeedbackDemoPage(),
    OutboxDemoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('nexo example')),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            label: 'Экран',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            label: 'Форма',
          ),
          NavigationDestination(
            icon: Icon(Icons.error_outline),
            label: 'Ошибки',
          ),
          NavigationDestination(
            icon: Icon(Icons.outbox_outlined),
            label: 'Outbox',
          ),
        ],
      ),
    );
  }
}
