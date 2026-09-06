import 'dart:convert';

import 'name_utils.dart';

/// Presentation state management strategy.
enum PresentationStyle { none, bloc, cubit, asyncCubit, listCubit }

/// Local storage backend for datasource generation.
enum LocalStorageBackend { hive, sharedPrefs, secureStorage }

/// Parsed feature flags (no I/O).
final class FeatureOptions {
  const FeatureOptions({
    required this.presentationOnly,
    required this.presentationStyle,
    required this.freezed,
    required this.injectable,
    required this.mapper,
    required this.mock,
    required this.local,
    required this.preferences,
    required this.ui,
    required this.extensions,
    required this.tests,
    required this.dryRun,
    required this.overwrite,
    this.jsonFields,
    this.crudOperations = const {},
    this.isList = true,
    this.viewModelName,
    this.root = 'lib/features',
    this.pagination = false,
    this.stream = false,
    this.streamOnly = false,
    this.optimistic = false,
    this.validators = false,
    this.localStorage,
    this.getById = false,
  });

  /// Only presentation layer -- no data/ or domain/.
  final bool presentationOnly;

  /// State management: none, bloc, cubit, listCubit.
  final PresentationStyle presentationStyle;

  /// Use `@freezed` for entities, models, events, states.
  final bool freezed;

  /// Use `@injectable` / `@LazySingleton` annotations.
  final bool injectable;

  /// Generate data/mappers/ with extension toDomain().
  final bool mapper;

  /// Generate mock datasource alongside the real one.
  final bool mock;

  /// Generate local datasource (i_local + local_datasource).
  final bool local;

  /// Generate `<feature>_preferences.dart`.
  final bool preferences;

  /// Generate pages/ and widgets/.
  final bool ui;

  /// Generate `<feature>_extensions.dart` on entity.
  final bool extensions;

  /// Generate test files.
  final bool tests;

  /// Print plan without writing files.
  final bool dryRun;

  /// Overwrite existing files.
  final bool overwrite;

  /// Parsed JSON fields: name -> Dart type string.
  /// E.g. `{'id': 'String', 'title': 'String', 'isActive': 'bool'}`.
  final Map<String, String>? jsonFields;

  /// CRUD operations: 'get', 'create', 'update', 'delete'.
  final Set<String> crudOperations;

  /// Whether the feature works with lists (true) or single objects (false).
  final bool isList;

  /// Optional custom name for the view model (default: feature name).
  final String? viewModelName;

  /// Base output directory (default: 'lib/features').
  final String root;

  /// Generate paginated list with PaginationController.
  final bool pagination;

  /// Generate NexoStreamUseCase for real-time features.
  final bool stream;

  /// Generate only stream use case (no getAll).
  final bool streamOnly;

  /// Generate OptimisticUpdateHelper in write use cases.
  final bool optimistic;

  /// Generate NexoValidators in create/update params.
  final bool validators;

  /// Local storage backend (hive/sharedPrefs/secureStorage).
  final LocalStorageBackend? localStorage;

  /// Generate get_by_id use case.
  final bool getById;

  FeatureOptions copyWith({
    bool? presentationOnly,
    PresentationStyle? presentationStyle,
    bool? freezed,
    bool? injectable,
    bool? mapper,
    bool? mock,
    bool? local,
    bool? preferences,
    bool? ui,
    bool? extensions,
    bool? tests,
    bool? dryRun,
    bool? overwrite,
    Map<String, String>? jsonFields,
    Set<String>? crudOperations,
    bool? isList,
    String? viewModelName,
    String? root,
    bool? pagination,
    bool? stream,
    bool? streamOnly,
    bool? optimistic,
    bool? validators,
    LocalStorageBackend? localStorage,
    bool? getById,
  }) {
    return FeatureOptions(
      presentationOnly: presentationOnly ?? this.presentationOnly,
      presentationStyle: presentationStyle ?? this.presentationStyle,
      freezed: freezed ?? this.freezed,
      injectable: injectable ?? this.injectable,
      mapper: mapper ?? this.mapper,
      mock: mock ?? this.mock,
      local: local ?? this.local,
      preferences: preferences ?? this.preferences,
      ui: ui ?? this.ui,
      extensions: extensions ?? this.extensions,
      tests: tests ?? this.tests,
      dryRun: dryRun ?? this.dryRun,
      overwrite: overwrite ?? this.overwrite,
      jsonFields: jsonFields ?? this.jsonFields,
      crudOperations: crudOperations ?? this.crudOperations,
      isList: isList ?? this.isList,
      viewModelName: viewModelName ?? this.viewModelName,
      root: root ?? this.root,
      pagination: pagination ?? this.pagination,
      stream: stream ?? this.stream,
      streamOnly: streamOnly ?? this.streamOnly,
      optimistic: optimistic ?? this.optimistic,
      validators: validators ?? this.validators,
      localStorage: localStorage ?? this.localStorage,
      getById: getById ?? this.getById,
    );
  }

  // Convenience getters.
  bool get hasBloc => presentationStyle == PresentationStyle.bloc;
  bool get hasCubit => presentationStyle == PresentationStyle.cubit;
  bool get hasAsyncCubit => presentationStyle == PresentationStyle.asyncCubit;
  bool get hasListCubit => presentationStyle == PresentationStyle.listCubit;
  bool get hasStateManagement => presentationStyle != PresentationStyle.none;
  bool get hasHive => localStorage == LocalStorageBackend.hive;
  bool get hasSharedPrefs => localStorage == LocalStorageBackend.sharedPrefs;
  bool get hasSecureStorage =>
      localStorage == LocalStorageBackend.secureStorage;
  bool get hasGet => crudOperations.contains('get');
  bool get hasCreate => crudOperations.contains('create');
  bool get hasUpdate => crudOperations.contains('update');
  bool get hasDelete => crudOperations.contains('delete');

  /// Whether to generate write usecases (create/update/delete).
  bool get hasWriteOperations => hasCreate || hasUpdate || hasDelete;

  /// Whether to generate request DTOs (only if create or update is selected).
  bool get hasRequests => hasCreate || hasUpdate;

  /// Whether there are multiple datasource implementations (mock or local).
  bool get hasMultipleDatasources => mock || local;

  /// The return type string for use cases/repository methods.
  String returnType(NameUtils names) {
    final entity = '${names.pascalCase}Entity';
    return isList ? 'List<$entity>' : entity;
  }

  /// The return type string for datasource methods (returns Model, not Entity).
  String modelReturnType(NameUtils names) {
    final model = '${names.pascalCase}Model';
    return isList ? 'List<$model>' : model;
  }
}

/// Parses a JSON string or map into field name -> Dart type.
Map<String, String> parseJsonToFields(String jsonString) {
  final decoded = json.decode(jsonString);
  if (decoded is! Map<String, dynamic>) {
    throw ArgumentError('JSON must be a map/object');
  }
  return decoded.map((key, value) => MapEntry(key, _dartType(value)));
}

Map<String, String> parseJsonMapToFields(Map<String, dynamic> json) {
  return json.map((key, value) => MapEntry(key, _dartType(value)));
}

String _dartType(dynamic value) {
  // Support type-name format: {"id": "int", "name": "String"}
  if (value is String) {
    final lower = value.toLowerCase();
    if (lower == 'int') return 'int';
    if (lower == 'double') return 'double';
    if (lower == 'bool') return 'bool';
    if (lower == 'string') return 'String';
    if (lower == 'list' || lower == 'list<dynamic>') return 'List<dynamic>';
    if (lower == 'map' || lower == 'map<String, dynamic>') {
      return 'Map<String, dynamic>';
    }
    if (lower.endsWith('?')) {
      // Nullable: "String?" -> "String?"
      final base = _dartType(value.substring(0, value.length - 1));
      return '$base?';
    }
    return 'String';
  }
  if (value is int) return 'int';
  if (value is double) return 'double';
  if (value is bool) return 'bool';
  if (value is List) return 'List<dynamic>';
  if (value is Map) return 'Map<String, dynamic>';
  if (value == null) return 'String?';
  return 'String';
}

/// Pure planning / validation for the `feature` command.
abstract final class FeaturePlan {
  FeaturePlan._();

  /// `null` if valid; otherwise a single-line error.
  static String? validatePresentation({
    required PresentationStyle style,
    required bool presentationOnly,
  }) {
    if (presentationOnly && style != PresentationStyle.none) {
      return '--presentation-only cannot be combined with --bloc, --cubit, or --list-cubit';
    }
    return null;
  }

  /// Relative paths under `lib/features/<snake>/`.
  static List<String> plannedLibPaths(NameUtils names, FeatureOptions options) {
    if (options.presentationOnly) {
      return _plannedPresentationOnly(names, options);
    }
    return _plannedClean(names, options);
  }

  static List<String> _plannedPresentationOnly(
    NameUtils names,
    FeatureOptions options,
  ) {
    final s = names.snakeCase;
    final lines = <String>[];

    if (options.preferences) {
      lines.add('data/${s}_preferences.dart');
    }

    if (options.hasBloc) {
      lines
        ..add('presentation/bloc/${s}_bloc.dart')
        ..add('presentation/bloc/${s}_event.dart')
        ..add('presentation/bloc/${s}_state.dart');
    } else if (options.hasCubit) {
      lines
        ..add('presentation/cubit/${s}_cubit.dart')
        ..add('presentation/cubit/${s}_state.dart');
    }

    lines.add('presentation/${s}_screen.dart');

    if (options.ui) {
      lines
        ..add('presentation/widgets/${s}_widget.dart')
        ..add('presentation/pages/${s}_page.dart');
    }

    return lines;
  }

  static List<String> _plannedClean(NameUtils names, FeatureOptions options) {
    final s = names.snakeCase;
    final lines = <String>[];

    // ── data/ ──
    if (options.injectable) {
      lines.add('data/datasources/i_remote_${s}_data_source.dart');
      if (options.mock || options.local) {
        lines.add('data/datasources/i_local_${s}_data_source.dart');
      }
    }
    lines.add('data/datasources/${s}_remote_datasource.dart');
    if (options.mock) {
      lines.add('data/datasources/mock_${s}_remote_data_source.dart');
    }
    if (options.local) {
      lines.add('data/datasources/${s}_local_datasource.dart');
      if (options.mock) {
        lines.add('data/datasources/mock_${s}_local_data_source.dart');
      }
    }

    lines.add('data/models/${s}_model.dart');

    if (options.mapper) {
      lines.add('data/mappers/${s}_mapper.dart');
    }

    if (options.hasRequests) {
      if (options.hasCreate) {
        lines.add('data/models/requests/create_${s}_request.dart');
      }
      if (options.hasUpdate) {
        lines.add('data/models/requests/update_${s}_request.dart');
      }
    }

    lines.add('data/repositories/${s}_repository.dart');

    if (options.preferences) {
      lines.add('data/${s}_preferences.dart');
    }

    // ── domain/ ──
    lines.add('domain/entities/${s}_entity.dart');
    if (options.extensions) {
      lines.add('domain/entities/${s}_extensions.dart');
    }

    lines.add('domain/repositories/i_${s}_repository.dart');

    // Use cases based on CRUD
    if (options.hasGet) {
      lines.add('domain/usecases/get_${s}_usecase.dart');
    }
    if (options.getById) {
      lines.add('domain/usecases/get_${s}_by_id_usecase.dart');
    }
    if (options.stream) {
      lines.add('domain/usecases/watch_${s}_stream_usecase.dart');
    }
    if (options.hasWriteOperations) {
      lines.add('domain/usecases/${s}_usecases.dart');
    }
    if (options.hasRequests) {
      if (options.hasCreate) {
        lines.add('domain/parameters/create_${s}_params.dart');
      }
      if (options.hasUpdate) {
        lines.add('domain/parameters/update_${s}_params.dart');
      }
    }

    // ── presentation/ ──
    final hasPresentation =
        options.hasGet ||
        options.getById ||
        options.hasAsyncCubit ||
        options.crudOperations.isEmpty;
    if (hasPresentation) {
      if (options.hasBloc) {
        lines
          ..add('presentation/bloc/${s}_bloc.dart')
          ..add('presentation/bloc/${s}_event.dart')
          ..add('presentation/bloc/${s}_state.dart');
      } else if (options.hasAsyncCubit) {
        // NexoAsyncCubit doesn't need a separate state file
        lines.add('presentation/cubit/${s}_cubit.dart');
      } else if (options.hasCubit || options.hasListCubit) {
        lines
          ..add('presentation/cubit/${s}_cubit.dart')
          ..add('presentation/cubit/${s}_state.dart');
      }
    }

    lines.add('presentation/${s}_screen.dart');

    if (options.ui) {
      lines
        ..add('presentation/widgets/${s}_widget.dart')
        ..add('presentation/pages/${s}_page.dart');
    }

    return lines;
  }

  /// Relative paths under `test/features/<snake>/` (empty unless [options.tests]).
  static List<String> plannedTestPaths(
    NameUtils names,
    FeatureOptions options,
  ) {
    if (!options.tests) return const [];
    final s = names.snakeCase;
    final lines = <String>[];

    if (!options.presentationOnly) {
      if (options.hasGet) {
        lines.add('domain/get_${s}_usecase_test.dart');
      }
      if (options.hasWriteOperations) {
        lines.add('domain/${s}_usecases_test.dart');
      }
      lines.add('data/${s}_repository_test.dart');

      if (options.mapper) {
        lines.add('data/mappers/${s}_mapper_test.dart');
      }
    }

    if (options.hasBloc) {
      lines.add('presentation/${s}_bloc_test.dart');
    } else if (options.hasCubit || options.hasListCubit) {
      lines.add('presentation/${s}_cubit_test.dart');
    }

    return lines;
  }

  /// Human-readable summary line for planned types (illustrative).
  static String illustrativeClasses(NameUtils names, FeatureOptions options) {
    if (options.presentationOnly) {
      final p = names.pascalCase;
      final parts = <String>['${p}Screen'];
      if (options.hasBloc) parts.addAll(['${p}Bloc', '${p}Event', '${p}State']);
      if (options.hasCubit) parts.addAll(['${p}Cubit', '${p}State']);
      if (options.preferences) parts.add('${p}Preferences');
      if (options.ui) parts.addAll(['${p}Page', '${p}Widget']);
      return '${parts.join(', ')} (names illustrative)';
    }

    final p = names.pascalCase;
    final parts = <String>[
      if (options.injectable) 'IRemote${p}DataSource',
      '${p}RemoteDataSource',
      if (options.mock) 'Mock${p}DataSource',
      if (options.local) '${p}LocalDataSource',
      '${p}Model',
      if (options.mapper) '${p}Mapper',
      if (options.hasCreate) 'Create${p}Request',
      if (options.hasUpdate) 'Update${p}Request',
      '${p}Repository',
      'I${p}Repository',
      '${p}Entity',
      if (options.extensions) '${p}Extensions',
      if (options.hasGet) 'Get${p}UseCase',
      if (options.hasCreate) 'Create${p}UseCase',
      if (options.hasUpdate) 'Update${p}UseCase',
      if (options.hasDelete) 'Delete${p}UseCase',
    ];
    if (options.hasBloc) parts.addAll(['${p}Bloc', '${p}Event', '${p}State']);
    if (options.hasCubit) parts.addAll(['${p}Cubit', '${p}State']);
    if (options.hasListCubit) parts.add('${p}Cubit');
    if (options.preferences) parts.add('${p}Preferences');
    if (options.ui) parts.addAll(['${p}Page', '${p}Widget']);
    return '${parts.join(', ')} (names illustrative)';
  }
}
