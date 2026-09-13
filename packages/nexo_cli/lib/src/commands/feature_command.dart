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
      ..addFlag('bloc', help: 'Generate Bloc (presentation/bloc/).')
      ..addFlag(
        'cubit',
        help: 'Generate Cubit with executeEither (presentation/cubit/).',
      )
      ..addFlag(
        'async-cubit',
        help: 'Generate NexoAsyncCubit with fetch() (no state file needed).',
      )
      ..addFlag(
        'list-cubit',
        help: 'Generate list cubit with executeEither (presentation/cubit/).',
      )
      ..addFlag(
        'presentation-only',
        negatable: false,
        help: 'Only presentation layer -- no data/ or domain/.',
      )
      // ── Code format ──
      ..addFlag(
        'freezed',
        defaultsTo: true,
        help: 'Use @freezed for entities, models, events, states.',
      )
      ..addFlag(
        'injectable',
        defaultsTo: true,
        help: 'Use @injectable / @LazySingleton annotations.',
      )
      ..addFlag(
        'mapper',
        defaultsTo: true,
        help: 'Generate data/mappers/ with extension toDomain().',
      )
      ..addFlag(
        'mock',
        defaultsTo: true,
        help: 'Generate mock datasource alongside the real one.',
      )
      // ── Extra layers ──
      ..addFlag(
        'local',
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
        negatable: false,
        help: 'Generate <feature>_preferences.dart.',
      )
      ..addFlag(
        'extensions',
        negatable: false,
        help: 'Generate <feature>_extensions.dart on entity.',
      )
      // ── UI ──
      ..addFlag(
        'ui',
        negatable: false,
        help: 'Include pages/ and widgets/ in the scaffold.',
      )
      // ── CRUD ──
      ..addFlag(
        'get',
        negatable: false,
        help: 'Generate get all use case and repository method.',
      )
      ..addFlag(
        'get-by-id',
        negatable: false,
        help: 'Generate get by id use case and repository method.',
      )
      ..addFlag(
        'create',
        negatable: false,
        help: 'Generate create use case, request DTO, and params.',
      )
      ..addFlag(
        'update',
        negatable: false,
        help: 'Generate update use case, request DTO, and params.',
      )
      ..addFlag('delete', negatable: false, help: 'Generate delete use case.')
      // ── Nexo features ──
      ..addFlag(
        'usecase-gen',
        negatable: false,
        help: 'Generate @NexoUseCase abstract class instead of manual UseCase.',
      )
      ..addFlag(
        'paginated',
        negatable: false,
        help:
            'Generate BLoC with NexoPaginatedMixin for cursor-based pagination.',
      )
      ..addFlag(
        'pagination',
        negatable: false,
        help: 'Generate paginated list with PaginationController.',
      )
      ..addFlag(
        'stream',
        negatable: false,
        help: 'Generate NexoStreamUseCase for real-time features.',
      )
      ..addFlag(
        'stream-only',
        negatable: false,
        help: 'Generate only stream use case (no getAll). Implies --stream.',
      )
      ..addFlag(
        'optimistic',
        negatable: false,
        help: 'Generate OptimisticUpdateHelper in write use cases.',
      )
      ..addFlag(
        'validators',
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
        negatable: false,
        help: 'Include planned test files under test/features/<feature>/.',
      )
      ..addFlag(
        'dry-run',
        abbr: 'n',
        negatable: false,
        help: 'Print what would be created without writing files.',
      )
      ..addFlag(
        'overwrite',
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
    final bloc = argResults!.flag('bloc');
    final cubit = argResults!.flag('cubit');
    final asyncCubit = argResults!.flag('async-cubit');
    final listCubit = argResults!.flag('list-cubit');
    final presentationOnly = argResults!.flag('presentation-only');

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
    final style = switch ((bloc, asyncCubit, listCubit, effectiveCubit)) {
      (true, _, _, _) => PresentationStyle.bloc,
      (_, true, _, _) => PresentationStyle.asyncCubit,
      (_, _, true, _) => PresentationStyle.listCubit,
      (_, _, _, true) => PresentationStyle.cubit,
      _ => PresentationStyle.none,
    };

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
    final crudOps = {
      if (argResults!.flag('get')) 'get',
      if (argResults!.flag('create')) 'create',
      if (argResults!.flag('update')) 'update',
      if (argResults!.flag('delete')) 'delete',
    };

    // Parse JSON fields.
    Map<String, String>? jsonFields;
    final jsonArg = argResults!['json'] as String?;
    if (jsonArg != null && jsonArg.isNotEmpty) {
      try {
        final jsonString = jsonArg.startsWith('@')
            ? File(jsonArg.substring(1)).readAsStringSync()
            : jsonArg;
        jsonFields = parseJsonToFields(jsonString);
      } on FormatException catch (e) {
        stderr.writeln('Invalid JSON: $e');
        stderr.writeln();
        stderr.writeln(
          'Usage: --json \'{"id": "String", "title": "String"}\' '
          'or --json @file.json',
        );
        return 64;
      }
    }

    // Parse list/single.
    final isList = argResults!['list'] == 'true';

    // Parse local storage backend.
    final localStorageStr = argResults!['local-storage'] as String?;
    final localStorage = switch (localStorageStr) {
      'hive' => LocalStorageBackend.hive,
      'shared-prefs' => LocalStorageBackend.sharedPrefs,
      'secure-storage' => LocalStorageBackend.secureStorage,
      _ => null,
    };

    final options = FeatureOptions(
      presentationOnly: presentationOnly,
      presentationStyle: style,
      freezed: argResults!.flag('freezed'),
      injectable: argResults!.flag('injectable'),
      mapper: argResults!.flag('mapper'),
      mock: argResults!.flag('mock'),
      local: argResults!.flag('local'),
      preferences: argResults!.flag('preferences'),
      ui: argResults!.flag('ui'),
      extensions: argResults!.flag('extensions'),
      tests: argResults!.flag('tests'),
      dryRun: argResults!.flag('dry-run'),
      overwrite: argResults!.flag('overwrite'),
      jsonFields: jsonFields,
      crudOperations: crudOps,
      isList: isList,
      root: argResults!.option('root') ?? 'lib/features',
      pagination: argResults!.flag('pagination'),
      stream: argResults!.flag('stream') || argResults!.flag('stream-only'),
      streamOnly: argResults!.flag('stream-only'),
      optimistic: argResults!.flag('optimistic'),
      validators: argResults!.flag('validators'),
      localStorage: localStorage,
      getById: argResults!.flag('get-by-id'),
      usecaseGen: argResults!.flag('usecase-gen'),
      paginated: argResults!.flag('paginated'),
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
    stdout.writeln('  usecase-gen: ${options.usecaseGen}');
    stdout.writeln('  paginated: ${options.paginated}');
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
