import 'dart:io';

import 'package:args/command_runner.dart';

import 'commands/feature_command.dart';
import 'commands/fix_command.dart';
import 'commands/init_command.dart';

/// Runs the `nexo_cli` [CommandRunner] (built-in global `--help` / `-h` and `help` subcommand).
Future<int> runNexoCli(List<String> args) async {
  final runner =
      CommandRunner<int>(
          'nexo_cli',
          'CLI tools for the nexo ecosystem (skeleton).',
        )
        ..addCommand(FeatureCommand())
        ..addCommand(FixCommand())
        ..addCommand(InitCommand());

  try {
    final code = await runner.run(args);
    return code ?? 0;
  } on UsageException catch (e) {
    stderr.writeln(e);
    return 64;
  }
}
