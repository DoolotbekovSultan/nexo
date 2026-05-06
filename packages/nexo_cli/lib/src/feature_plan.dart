import 'name_utils.dart';

/// Parsed feature flags (no I/O).
final class FeatureOptions {
  const FeatureOptions({
    required this.bloc,
    required this.cubit,
    required this.local,
    required this.ui,
    required this.tests,
    required this.dryRun,
    required this.overwrite,
  });

  final bool bloc;
  final bool cubit;
  final bool local;
  final bool ui;
  final bool tests;
  final bool dryRun;
  final bool overwrite;
}

/// Pure planning / validation for the `feature` command.
abstract final class FeaturePlan {
  FeaturePlan._();

  /// `null` if valid; otherwise a single-line error (before usage footer).
  static String? validatePresentation({
    required bool bloc,
    required bool cubit,
  }) {
    if (bloc && cubit) {
      return 'Choose either --bloc or --cubit, not both';
    }
    if (!bloc && !cubit) {
      return 'Either --bloc or --cubit must be enabled';
    }
    return null;
  }

  /// Relative paths under `lib/features/<snake>/`.
  static List<String> plannedLibPaths(NameUtils names, FeatureOptions options) {
    final s = names.snakeCase;
    final lines = <String>[];

    void add(String path) => lines.add(path);

    add('data/datasources/${s}_remote_datasource.dart');
    if (options.local) {
      add('data/datasources/${s}_local_datasource.dart');
    }
    add('data/repositories/${s}_repository_impl.dart');
    add('domain/entities/${s}_entity.dart');
    add('domain/repositories/${s}_repository.dart');
    add('domain/usecases/get_${s}_usecase.dart');

    if (options.bloc) {
      add('presentation/bloc/${s}_bloc.dart');
      add('presentation/bloc/${s}_event.dart');
      add('presentation/bloc/${s}_state.dart');
    }
    if (options.cubit) {
      add('presentation/cubit/${s}_cubit.dart');
      add('presentation/cubit/${s}_state.dart');
    }
    if (options.ui) {
      add('presentation/pages/${s}_page.dart');
      add('presentation/widgets/${s}_widget.dart');
    }

    return lines;
  }

  /// Relative paths under `test/features/<snake>/` (empty unless [options.tests]).
  static List<String> plannedTestPaths(
    NameUtils names,
    FeatureOptions options,
  ) {
    if (!options.tests) {
      return const [];
    }
    final s = names.snakeCase;
    final lines = <String>[
      'data/${s}_repository_impl_test.dart',
      'domain/get_${s}_usecase_test.dart',
    ];
    if (options.local) {
      lines.add('data/${s}_local_datasource_test.dart');
    }
    if (options.bloc) {
      lines.add('presentation/${s}_bloc_test.dart');
    }
    if (options.cubit) {
      lines.add('presentation/${s}_cubit_test.dart');
    }
    if (options.ui) {
      lines.add('presentation/pages/${s}_page_test.dart');
      lines.add('presentation/widgets/${s}_widget_test.dart');
    }
    return lines;
  }

  /// Human-readable summary line for planned types (illustrative).
  static String illustrativeClasses(NameUtils names, FeatureOptions options) {
    final p = names.pascalCase;
    final parts = <String>[
      '${p}RemoteDataSource',
      if (options.local) '${p}LocalDataSource',
      '${p}Repository',
      '${p}RepositoryImpl',
      'Get${p}UseCase',
    ];
    if (options.bloc) {
      parts.addAll(['${p}Bloc', '${p}Event', '${p}State']);
    }
    if (options.cubit) {
      parts.addAll(['${p}Cubit', '${p}State']);
    }
    if (options.ui) {
      parts.addAll(['${p}Page', '${p}Widget']);
    }
    return '${parts.join(', ')} (names illustrative)';
  }
}
