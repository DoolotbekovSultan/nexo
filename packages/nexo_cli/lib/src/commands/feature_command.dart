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
      // ── Presentation style ──
      ..addFlag(
        'bloc',
        defaultsTo: false,
        negatable: true,
        help: 'Generate Bloc (presentation/bloc/).',
      )
      ..addFlag(
        'cubit',
        defaultsTo: false,
        negatable: true,
        help: 'Generate Cubit with executeEither (presentation/cubit/).',
      )
      ..addFlag(
        'async-cubit',
        defaultsTo: false,
        negatable: true,
        help: 'Generate NexoAsyncCubit with fetch() (no state file needed).',
      )
      ..addFlag(
        'list-cubit',
        defaultsTo: false,
        negatable: true,
        help: 'Generate list cubit with executeEither (presentation/cubit/).',
      )
      ..addFlag(
        'presentation-only',
        defaultsTo: false,
        negatable: false,
        help: 'Only presentation layer -- no data/ or domain/.',
      )
      // ── Code format ──
      ..addFlag(
        'freezed',
        defaultsTo: true,
        negatable: true,
        help: 'Use @freezed for entities, models, events, states.',
      )
      ..addFlag(
        'injectable',
        defaultsTo: true,
        negatable: true,
        help: 'Use @injectable / @LazySingleton annotations.',
      )
      ..addFlag(
        'mapper',
        defaultsTo: true,
        negatable: true,
        help: 'Generate data/mappers/ with extension toDomain().',
      )
      ..addFlag(
        'mock',
        defaultsTo: true,
        negatable: true,
        help: 'Generate mock datasource alongside the real one.',
      )
      // ── Extra layers ──
      ..addFlag(
        'local',
        defaultsTo: false,
        negatable: false,
        help: 'Include local datasource in the scaffold.',
      )
      ..addOption(
        'local-storage',
        allowed: ['hive', 'shared-prefs', 'secure-storage'],
        help: 'Local storage backend (hive/shared-prefs/secure-storage).',
      )
      ..addFlag(
        'preferences',
        defaultsTo: false,
        negatable: false,
        help: 'Generate <feature>_preferences.dart.',
      )
      ..addFlag(
        'extensions',
        defaultsTo: false,
        negatable: false,
        help: 'Generate <feature>_extensions.dart on entity.',
      )
      // ── UI ──
      ..addFlag(
        'ui',
        defaultsTo: false,
        negatable: false,
        help: 'Include pages/ and widgets/ in the scaffold.',
      )
      // ── CRUD ──
      ..addFlag(
        'get',
        defaultsTo: false,
        negatable: false,
        help: 'Generate get all use case and repository method.',
      )
      ..addFlag(
        'get-by-id',
        defaultsTo: false,
        negatable: false,
        help: 'Generate get by id use case and repository method.',
      )
      ..addFlag(
        'create',
        defaultsTo: false,
        negatable: false,
        help: 'Generate create use case, request DTO, and params.',
      )
      ..addFlag(
        'update',
        defaultsTo: false,
        negatable: false,
        help: 'Generate update use case, request DTO, and params.',
      )
      ..addFlag(
        'delete',
        defaultsTo: false,
        negatable: false,
        help: 'Generate delete use case.',
      )
      // ── Nexo features ──
      ..addFlag(
        'pagination',
        defaultsTo: false,
        negatable: false,
        help: 'Generate paginated list with PaginationController.',
      )
      ..addFlag(
        'stream',
        defaultsTo: false,
        negatable: false,
        help: 'Generate NexoStreamUseCase for real-time features.',
      )
      ..addFlag(
        'stream-only',
        defaultsTo: false,
        negatable: false,
        help: 'Generate only stream use case (no getAll). Implies --stream.',
      )
      ..addFlag(
        'optimistic',
        defaultsTo: false,
        negatable: false,
        help: 'Generate OptimisticUpdateHelper in write use cases.',
      )
      ..addFlag(
        'validators',
        defaultsTo: false,
        negatable: false,
        help: 'Generate NexoValidators in create/update params.',
      )
      ..addOption(
        'json',
        help:
            'JSON string or file path to generate model fields from. '
            'E.g. \'{"id": "String", "title": "String"}\' or @file.json',
      )
      ..addOption(
        'list',
        allowed: ['true', 'false'],
        defaultsTo: 'true',
        help:
            'Whether the feature works with lists (true) or single objects (false).',
      )
      // ── Control ──
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
      )
      ..addOption(
        'root',
        defaultsTo: 'lib/features',
        help: 'Base output directory for generated files.',
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

    // Parse presentation style.
    final bloc = argResults!['bloc'] as bool;
    final cubit = argResults!['cubit'] as bool;
    final asyncCubit = argResults!['async-cubit'] as bool;
    final listCubit = argResults!['list-cubit'] as bool;
    final presentationOnly = argResults!['presentation-only'] as bool;

    final styleCount = [
      bloc,
      cubit,
      asyncCubit,
      listCubit,
    ].where((e) => e).length;
    if (styleCount > 1) {
      stderr.writeln(
        'Choose only one of --bloc, --cubit, --async-cubit, or --list-cubit.',
      );
      stderr.writeln();
      stderr.writeln(usage);
      return 64;
    }

    // Default to cubit if no style chosen and not presentation-only.
    final effectiveCubit = !presentationOnly && styleCount == 0;
    final style = bloc
        ? PresentationStyle.bloc
        : asyncCubit
        ? PresentationStyle.asyncCubit
        : listCubit
        ? PresentationStyle.listCubit
        : effectiveCubit
        ? PresentationStyle.cubit
        : PresentationStyle.none;

    final validation = FeaturePlan.validatePresentation(
      style: style,
      presentationOnly: presentationOnly,
    );
    if (validation != null) {
      stderr.writeln(validation);
      stderr.writeln();
      stderr.writeln(usage);
      return 64;
    }

    // Parse CRUD flags.
    final crudOps = <String>{};
    if (argResults!['get'] as bool) crudOps.add('get');
    if (argResults!['create'] as bool) crudOps.add('create');
    if (argResults!['update'] as bool) crudOps.add('update');
    if (argResults!['delete'] as bool) crudOps.add('delete');

    // Parse JSON fields.
    Map<String, String>? jsonFields;
    final jsonArg = argResults!['json'] as String?;
    if (jsonArg != null && jsonArg.isNotEmpty) {
      try {
        String jsonString;
        if (jsonArg.startsWith('@')) {
          // File reference: @file.json
          final filePath = jsonArg.substring(1);
          final file = File(filePath);
          if (!file.existsSync()) {
            stderr.writeln('JSON file not found: $filePath');
            return 64;
          }
          jsonString = file.readAsStringSync();
        } else {
          jsonString = jsonArg;
        }
        jsonFields = parseJsonToFields(jsonString);
      } catch (e) {
        stderr.writeln('Invalid JSON: $e');
        stderr.writeln();
        stderr.writeln(
          'Usage: --json \'{"id": "String", "title": "String"}\' or --json @file.json',
        );
        return 64;
      }
    }

    // Parse list/single.
    final isList = argResults!['list'] == 'true';

    // Parse local storage backend.
    final localStorageStr = argResults!['local-storage'] as String?;
    final localStorage = localStorageStr == 'hive'
        ? LocalStorageBackend.hive
        : localStorageStr == 'shared-prefs'
        ? LocalStorageBackend.sharedPrefs
        : localStorageStr == 'secure-storage'
        ? LocalStorageBackend.secureStorage
        : null;

    final options = FeatureOptions(
      presentationOnly: presentationOnly,
      presentationStyle: style,
      freezed: argResults!['freezed'] as bool,
      injectable: argResults!['injectable'] as bool,
      mapper: argResults!['mapper'] as bool,
      mock: argResults!['mock'] as bool,
      local: argResults!['local'] as bool,
      preferences: argResults!['preferences'] as bool,
      ui: argResults!['ui'] as bool,
      extensions: argResults!['extensions'] as bool,
      tests: argResults!['tests'] as bool,
      dryRun: argResults!['dry-run'] as bool,
      overwrite: argResults!['overwrite'] as bool,
      jsonFields: jsonFields,
      crudOperations: crudOps,
      isList: isList,
      root: argResults!['root'] as String,
      pagination: argResults!['pagination'] as bool,
      stream:
          argResults!['stream'] as bool || argResults!['stream-only'] as bool,
      streamOnly: argResults!['stream-only'] as bool,
      optimistic: argResults!['optimistic'] as bool,
      validators: argResults!['validators'] as bool,
      localStorage: localStorage,
      getById: argResults!['get-by-id'] as bool,
    );

    stdout.writeln('Planned feature: ${names.snakeCase}');
    stdout.writeln('Root: ${options.root}/${names.snakeCase}/');
    stdout.writeln();
    stdout.writeln('Options:');
    stdout.writeln('  presentation-only: ${options.presentationOnly}');
    stdout.writeln('  style: ${style.name}');
    stdout.writeln('  freezed: ${options.freezed}');
    stdout.writeln('  injectable: ${options.injectable}');
    stdout.writeln('  mapper: ${options.mapper}');
    stdout.writeln('  mock: ${options.mock}');
    stdout.writeln('  local: ${options.local}');
    if (options.localStorage != null) {
      stdout.writeln('  local-storage: ${options.localStorage!.name}');
    }
    stdout.writeln('  preferences: ${options.preferences}');
    stdout.writeln('  extensions: ${options.extensions}');
    stdout.writeln('  ui: ${options.ui}');
    stdout.writeln('  tests: ${options.tests}');
    stdout.writeln('  dry-run: ${options.dryRun}');
    stdout.writeln('  overwrite: ${options.overwrite}');
    stdout.writeln('  crud: ${crudOps.isEmpty ? "none" : crudOps.join(", ")}');
    stdout.writeln('  list: ${options.isList}');
    stdout.writeln('  pagination: ${options.pagination}');
    stdout.writeln('  stream: ${options.stream}');
    stdout.writeln('  stream-only: ${options.streamOnly}');
    stdout.writeln('  optimistic: ${options.optimistic}');
    stdout.writeln('  validators: ${options.validators}');
    stdout.writeln('  get-by-id: ${options.getById}');
    if (jsonFields != null) {
      stdout.writeln('  json fields: ${jsonFields.length} fields');
    }
    stdout.writeln();
    stdout.writeln(
      'Planned structure (relative to ${options.root}/${names.snakeCase}/):',
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

    // Read package name from pubspec.yaml.
    String? packageName;
    final pubspecFile = File(p.join(projectRoot, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      final pubspecContent = pubspecFile.readAsStringSync();
      final match = RegExp(
        r'^name:\s*(.+)$',
        multiLine: true,
      ).firstMatch(pubspecContent);
      if (match != null) {
        packageName = match.group(1)!.trim();
      }
    }

    final libRoot = p.join(projectRoot, options.root, names.snakeCase);
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
        final body = TemplateRenderer.render(
          relative,
          names,
          options,
          packageName: packageName,
        );
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
