/// CLI tools for the nexo ecosystem (skeleton).
library;

import 'src/runner.dart';

/// Invoked from [bin/nexo_cli.dart]. Returns a process exit code.
Future<int> run(List<String> arguments) => runNexoCli(arguments);
