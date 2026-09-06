import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../file_generator.dart';
import '../init_plan.dart';
import '../init_template_renderer.dart';

/// `nexo init` — scaffolds app-level infrastructure using nexo.
///
/// Creates DI, networking, storage, logging, error handling, and optionally
/// routing configuration. All based on nexo's built-in capabilities.
class InitCommand extends Command<int> {
  InitCommand() {
    argParser
      ..addOption(
        'name',
        defaultsTo: 'MyApp',
        help: 'App name used in MaterialApp.title.',
      )
      ..addOption(
        'routing',
        allowed: ['none', 'auto_route', 'go_router'],
        defaultsTo: 'none',
        help: 'Routing solution to scaffold.',
      )
      ..addFlag(
        'mock',
        defaultsTo: true,
        negatable: true,
        help: 'Use mock datasources by default (debug).',
      )
      ..addFlag(
        'prod',
        defaultsTo: false,
        negatable: false,
        help: 'Use prod datasources by default (overrides --mock).',
      )
      ..addFlag(
        'sentry',
        defaultsTo: false,
        negatable: false,
        help: 'Add Sentry crash reporting integration.',
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
  final name = 'init';

  @override
  final description =
      'Initialize nexo app infrastructure (DI, network, storage, logger, errors).';

  @override
  Future<int> run() async {
    final appName = argResults!['name'] as String;
    final routingStr = argResults!['routing'] as String;
    final routing = routingStr == 'auto_route'
        ? RoutingType.autoRoute
        : routingStr == 'go_router'
        ? RoutingType.goRouter
        : RoutingType.none;
    final mockByDefault = !(argResults!['prod'] as bool);
    final sentry = argResults!['sentry'] as bool;
    final dryRun = argResults!['dry-run'] as bool;
    final overwrite = argResults!['overwrite'] as bool;

    final options = InitOptions(
      appName: appName,
      routing: routing,
      mockByDefault: mockByDefault,
      sentry: sentry,
      overwrite: overwrite,
      dryRun: dryRun,
    );

    // ── Print plan ──
    final paths = InitPlan.plannedPaths(options);
    stdout.writeln('Initializing nexo app: $appName');
    stdout.writeln('Routing: $routingStr');
    stdout.writeln('Default env: ${mockByDefault ? "mock" : "prod"}');
    if (sentry) stdout.writeln('Sentry: enabled');
    stdout.writeln();
    stdout.writeln('Files to create:');
    for (final path in paths) {
      stdout.writeln('  - $path');
    }
    stdout.writeln();

    // ── Compute absolute paths ──
    final projectRoot = Directory.current.path;
    final absolutePaths = paths.map((r) => p.join(projectRoot, r)).toList();

    final existedBefore = <String, bool>{
      for (final path in absolutePaths) path: File(path).existsSync(),
    };

    // ── Create empty files / dirs ──
    final generator = FileGenerator(log: stdout.writeln);
    await generator.generate(
      absolutePaths,
      dryRun: dryRun,
      overwrite: overwrite,
    );

    // ── Write rendered content ──
    if (!dryRun) {
      for (final abs in absolutePaths) {
        final hadExisted = existedBefore[abs]!;
        if (hadExisted && !overwrite) continue;

        final normalized = p.normalize(File(abs).absolute.path);
        final relative = p
            .normalize(p.relative(normalized, from: projectRoot))
            .replaceAll(r'\', '/');

        final body = InitTemplateRenderer.render(relative, options);
        await File(abs).writeAsString(body);
      }
    }

    // ── Update pubspec.yaml ──
    _updatePubspec(projectRoot, options, dryRun: dryRun);

    // ── Fix test/widget_test.dart from flutter create ──
    _fixFlutterCreateTest(projectRoot, options, dryRun: dryRun);

    // ── Create config files if missing ──
    _createIfMissing(
      projectRoot,
      'analysis_options.yaml',
      _analysisOptionsContent(),
      dryRun: dryRun,
    );
    _createIfMissing(
      projectRoot,
      'build.yaml',
      _buildYamlContent(),
      dryRun: dryRun,
    );

    // ── Done ──
    if (dryRun) {
      stdout.writeln();
      stdout.writeln('Dry run: no files were written.');
    } else {
      stdout.writeln();
      stdout.writeln('Done! Next steps:');
      stdout.writeln('  1. flutter create .  (if platform dirs missing)');
      stdout.writeln('  2. flutter pub get');
      stdout.writeln(
        '  3. dart run build_runner build --delete-conflicting-outputs',
      );
      stdout.writeln('  4. flutter run');
    }

    return 0;
  }

  // ── Pubspec.yaml ──────────────────────────────────────────────────────────

  void _updatePubspec(
    String projectRoot,
    InitOptions options, {
    required bool dryRun,
  }) {
    final pubspecFile = File(p.join(projectRoot, 'pubspec.yaml'));

    if (dryRun) {
      stdout.writeln(
        pubspecFile.existsSync()
            ? '  would update pubspec.yaml'
            : '  warning: pubspec.yaml not found, run "flutter create" first',
      );
      return;
    }

    if (!pubspecFile.existsSync()) {
      stdout.writeln(
        '  warning: pubspec.yaml not found, run "flutter create" first',
      );
      return;
    }

    var content = pubspecFile.readAsStringSync();

    // ── Dependencies to add ──
    final deps = <String, String>{
      'nexo': '^0.0.5-beta.0',
      'injectable': '^3.0.0',
      'get_it': '^9.2.1',
      'freezed_annotation': '^3.1.0',
      'json_annotation': '^4.11.0',
      'dio': '^5.10.0',
      'talker': '^5.1.16',
      'shared_preferences': '^2.5.5',
      'flutter_secure_storage': '^11.0.0',
    };

    if (options.hasAutoRoute) deps['auto_route'] = '^11.1.0';
    if (options.hasGoRouter) deps['go_router'] = '^17.3.0';
    if (options.sentry) deps['sentry_flutter'] = '^9.10.0';

    // ── Dev dependencies to add ──
    final devDeps = <String, String>{
      'build_runner': '^2.13.1',
      'injectable_generator': '^3.0.2',
      'json_serializable': '^6.13.1',
      'freezed': '^4.0.0',
      'flutter_lints': '^6.0.0',
      'mockito': '^5.6.4',
      'fake_async': '^1.3.3',
    };

    if (options.hasAutoRoute) devDeps['auto_route_generator'] = '^10.5.0';

    content = _addDependencies(content, 'dependencies:', deps);
    content = _addDependencies(content, 'dev_dependencies:', devDeps);

    pubspecFile.writeAsStringSync(content);
    stdout.writeln('  updated pubspec.yaml');
  }

  /// Adds missing packages to a YAML section (e.g. `dependencies:`).
  ///
  /// Simple heuristic: finds the section header, then checks if each package
  /// already exists as a key. If not, appends it before the next section or
  /// end of file.
  String _addDependencies(
    String content,
    String sectionHeader,
    Map<String, String> packages,
  ) {
    final lines = content.split('\n');
    final result = <String>[];

    var inSection = false;
    var insertIndex = -1;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      result.add(line);

      if (line.trimRight() == sectionHeader) {
        inSection = true;
        insertIndex = i + 1;
        continue;
      }

      // Detect next section (starts with a letter at column 0 and ends with ':')
      if (inSection &&
          line.isNotEmpty &&
          !line.startsWith(' ') &&
          !line.startsWith('\t') &&
          line.trimRight().endsWith(':')) {
        insertIndex = i;
        inSection = false;
      }
    }

    if (insertIndex == -1) {
      // Section not found — append at end.
      result.add('');
      result.add(sectionHeader);
      for (final entry in packages.entries) {
        result.add('  ${entry.key}: ${entry.value}');
      }
      return result.join('\n');
    }

    // Check which packages already exist in the section.
    final existingPackages = <String>{};
    for (var i = 0; i < result.length; i++) {
      final line = result[i];
      if (line.startsWith('  ') || line.startsWith('\t')) {
        final trimmed = line.trimLeft();
        for (final key in packages.keys) {
          if (trimmed.startsWith('$key:')) {
            existingPackages.add(key);
          }
        }
      }
    }

    // Insert missing packages.
    final toInsert = <String>[];
    for (final entry in packages.entries) {
      if (!existingPackages.contains(entry.key)) {
        toInsert.add('  ${entry.key}: ${entry.value}');
      }
    }

    if (toInsert.isNotEmpty) {
      result.insertAll(insertIndex, toInsert);
    }

    return result.join('\n');
  }

  // ── Config files ──────────────────────────────────────────────────────────

  void _createIfMissing(
    String projectRoot,
    String filename,
    String content, {
    required bool dryRun,
  }) {
    final file = File(p.join(projectRoot, filename));
    if (file.existsSync()) return;

    if (dryRun) {
      stdout.writeln('  would create $filename');
      return;
    }

    file.writeAsStringSync(content);
    stdout.writeln('  created $filename');
  }

  String _analysisOptionsContent() => '''
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
''';

  String _buildYamlContent() => '''
targets:
  \$default:
    builders:
      build_runner|freezed:
        options:
          generate_for:
            - lib/**
      build_runner|json_serializable:
        options:
          generate_for:
            - lib/**
      build_runner|injectable_generator:
        options:
          generate_for:
            - lib/**
''';

  /// Replaces the default `flutter create` test with a nexo-compatible one.
  void _fixFlutterCreateTest(
    String projectRoot,
    InitOptions options, {
    required bool dryRun,
  }) {
    final testFile = File(p.join(projectRoot, 'test', 'widget_test.dart'));
    if (!testFile.existsSync()) return;

    if (dryRun) {
      stdout.writeln('  would update test/widget_test.dart');
      return;
    }

    final content = testFile.readAsStringSync();
    // Only replace if it still contains the default flutter create test.
    if (!content.contains('MyApp') || content.contains('Nexo')) return;

    // Read package name from pubspec.yaml.
    final pubspecFile = File(p.join(projectRoot, 'pubspec.yaml'));
    var packageName = _snakeCase(options.appName);
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

    testFile.writeAsStringSync(_testContent(options, packageName));
    stdout.writeln('  updated test/widget_test.dart');
  }

  String _testContent(InitOptions options, String packageName) =>
      '''
import 'package:flutter_test/flutter_test.dart';

import 'package:$packageName/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ${options.appName}App());
    expect(find.byType(${options.appName}App), findsOneWidget);
  });
}
''';

  String _snakeCase(String input) {
    final result = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == char.toUpperCase() && char != char.toLowerCase()) {
        if (i > 0) result.write('_');
        result.write(char.toLowerCase());
      } else {
        result.write(char);
      }
    }
    return result.toString();
  }
}
