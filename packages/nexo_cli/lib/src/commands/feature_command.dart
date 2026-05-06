import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../feature_plan.dart';
import '../file_generator.dart';
import '../name_utils.dart';
import '../template_renderer.dart';

/// `nexo feature <name>` — prints a plan and optionally scaffolds Dart files.
class FeatureCommand extends Command<int> {
  FeatureCommand() {
    argParser
      ..addFlag(
        'bloc',
        defaultsTo: true,
        negatable: true,
        help:
            'Generate Bloc (presentation/bloc). Default: on. Use --no-bloc to disable.',
      )
      ..addFlag(
        'cubit',
        defaultsTo: false,
        negatable: true,
        help: 'Generate Cubit (presentation/cubit). Default: off.',
      )
      ..addFlag(
        'local',
        defaultsTo: false,
        negatable: false,
        help: 'Include local datasource in the scaffold.',
      )
      ..addFlag(
        'ui',
        defaultsTo: false,
        negatable: false,
        help: 'Include page and widget files in the scaffold.',
      )
      ..addFlag(
        'tests',
        defaultsTo: false,
        negatable: false,
        help: 'Include planned test files under test/features/<feature>/.',
      )
      ..addFlag(
        'dry-run',
        abbr: 'n',
        defaultsTo: false,
        negatable: false,
        help: 'Print what would be created without writing files.',
      )
      ..addFlag(
        'overwrite',
        defaultsTo: false,
        negatable: false,
        help: 'Overwrite existing files; otherwise skip them.',
      );
  }

  @override
  final name = 'feature';

  @override
  final description =
      'Plan and scaffold a Clean Architecture feature (templated Dart files).';

  @override
  Future<int> run() async {
    final rest = argResults!.rest;
    if (rest.isEmpty) {
      throw UsageException('Missing feature name.', usage);
    }
    if (rest.length > 1) {
      throw UsageException(
        'Too many arguments. Expected a single feature name.',
        usage,
      );
    }

    final rawName = rest.single;
    final names = NameUtils.fromFeatureInput(rawName);

    final bloc = argResults!['bloc'] as bool;
    final cubit = argResults!['cubit'] as bool;
    final validation = FeaturePlan.validatePresentation(
      bloc: bloc,
      cubit: cubit,
    );
    if (validation != null) {
      stderr.writeln(validation);
      stderr.writeln();
      stderr.writeln(usage);
      return 64;
    }

    final options = FeatureOptions(
      bloc: bloc,
      cubit: cubit,
      local: argResults!['local'] as bool,
      ui: argResults!['ui'] as bool,
      tests: argResults!['tests'] as bool,
      dryRun: argResults!['dry-run'] as bool,
      overwrite: argResults!['overwrite'] as bool,
    );

    stdout.writeln('Planned feature: ${names.snakeCase}');
    stdout.writeln('Root: lib/features/${names.snakeCase}/');
    stdout.writeln();
    stdout.writeln('Options:');
    stdout.writeln('  bloc: ${options.bloc}');
    stdout.writeln('  cubit: ${options.cubit}');
    stdout.writeln('  local: ${options.local}');
    stdout.writeln('  ui: ${options.ui}');
    stdout.writeln('  tests: ${options.tests}');
    stdout.writeln('  dry-run: ${options.dryRun}');
    stdout.writeln('  overwrite: ${options.overwrite}');
    stdout.writeln();
    stdout.writeln(
      'Planned structure (relative to lib/features/${names.snakeCase}/):',
    );
    for (final path in FeaturePlan.plannedLibPaths(names, options)) {
      stdout.writeln('  - $path');
    }
    final testPaths = FeaturePlan.plannedTestPaths(names, options);
    if (testPaths.isNotEmpty) {
      stdout.writeln();
      stdout.writeln(
        'Planned tests (relative to test/features/${names.snakeCase}/):',
      );
      for (final path in testPaths) {
        stdout.writeln('  - $path');
      }
    }
    stdout.writeln();
    stdout.writeln(
      '# classes (illustrative): ${FeaturePlan.illustrativeClasses(names, options)}',
    );
    stdout.writeln();

    final projectRoot = Directory.current.path;
    final libRoot = p.join(projectRoot, 'lib', 'features', names.snakeCase);
    final testRoot = p.join(projectRoot, 'test', 'features', names.snakeCase);
    final absolutePaths = <String>[
      ...FeaturePlan.plannedLibPaths(
        names,
        options,
      ).map((r) => p.join(libRoot, r)),
      ...FeaturePlan.plannedTestPaths(
        names,
        options,
      ).map((r) => p.join(testRoot, r)),
    ];

    final existedBefore = <String, bool>{
      for (final path in absolutePaths) path: File(path).existsSync(),
    };

    final generator = FileGenerator(log: stdout.writeln);
    await generator.generate(
      absolutePaths,
      dryRun: options.dryRun,
      overwrite: options.overwrite,
    );

    if (!options.dryRun) {
      final ctx = p.Context();
      for (final abs in absolutePaths) {
        final hadExisted = existedBefore[abs]!;
        if (hadExisted && !options.overwrite) {
          continue;
        }
        final normalized = p.normalize(File(abs).absolute.path);
        final libNorm = p.normalize(libRoot);
        final testNorm = p.normalize(testRoot);
        final relative = ctx.isWithin(libNorm, normalized)
            ? ctx.relative(normalized, from: libNorm).replaceAll(r'\', '/')
            : ctx.isWithin(testNorm, normalized)
            ? ctx.relative(normalized, from: testNorm).replaceAll(r'\', '/')
            : normalized.replaceAll(r'\', '/');
        final body = TemplateRenderer.render(relative, names);
        await File(abs).writeAsString(body);
      }
    }

    if (options.dryRun) {
      stdout.writeln();
      stdout.writeln('Dry run: no files were written.');
    } else {
      stdout.writeln();
      stdout.writeln('Scaffold complete.');
    }

    return 0;
  }
}
