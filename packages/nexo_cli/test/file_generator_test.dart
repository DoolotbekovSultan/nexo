import 'dart:io';

import 'package:nexo_cli/src/file_generator.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('nexo_cli_gen_');
  });

  tearDown(() async {
    if (tmp.existsSync()) {
      await tmp.delete(recursive: true);
    }
  });

  test('dry-run does not create files', () async {
    final target = p.join(tmp.path, 'a', 'b', 'c.dart');
    final logs = <String>[];
    final gen = FileGenerator(log: logs.add);

    await gen.generate([target], dryRun: true, overwrite: false);

    expect(File(target).existsSync(), isFalse);
    expect(logs, contains('would create: ${File(target).absolute.path}'));
  });

  test('without overwrite existing file is not overwritten', () async {
    final target = p.join(tmp.path, 'x', 'file.dart');
    await File(target).create(recursive: true);
    await File(target).writeAsString('original');

    final logs = <String>[];
    final gen = FileGenerator(log: logs.add);
    await gen.generate([target], dryRun: false, overwrite: false);

    expect(await File(target).readAsString(), 'original');
    expect(logs, contains('skipped: ${File(target).absolute.path}'));
  });

  test('with overwrite existing file is replaced by empty file', () async {
    final target = p.join(tmp.path, 'y', 'file.dart');
    await File(target).create(recursive: true);
    await File(target).writeAsString('original');

    final logs = <String>[];
    final gen = FileGenerator(log: logs.add);
    await gen.generate([target], dryRun: false, overwrite: true);

    expect(await File(target).readAsString(), '');
    expect(logs, contains('created: ${File(target).absolute.path}'));
  });
}
