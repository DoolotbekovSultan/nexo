import 'dart:io';

import 'package:args/command_runner.dart';

/// Patches known issues in generated files (e.g. freezed 3.x bug).
class FixCommand extends Command<int> {
  @override
  String get name => 'fix';

  @override
  String get description => 'Patch known issues in generated files.';

  @override
  Future<int> run() async {
    final dir = Directory.current;
    var patched = 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.freezed.dart')) continue;

      final content = await entity.readAsString();
      // freezed 3.x bug: "required final  List<T>" → "required  List<T>"
      final patchedContent = content.replaceAll(
        RegExp(r'required\s+final\s+(\s+)'),
        r'required $1',
      );

      if (patchedContent != content) {
        await entity.writeAsString(patchedContent);
        patched++;
        stdout.writeln('  patched: ${entity.path}');
      }
    }

    if (patched == 0) {
      stdout.writeln('No freezed files to patch.');
    } else {
      stdout.writeln('Patched $patched file(s).');
    }

    return 0;
  }
}
