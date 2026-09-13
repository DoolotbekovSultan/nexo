import 'feature_plan.dart';
import 'name_utils.dart';

/// Template renderer for feature scaffold files.
///
/// Picks the right template based on file path and renders substitutions.
abstract final class TemplateRenderer {
  TemplateRenderer._();

  /// Renders Dart source for a planned feature file.
  static String render(
    String relativePosixPath,
    NameUtils names,
    FeatureOptions options, {
    String? packageName,
  }) {
    final norm = relativePosixPath.replaceAll(r'\', '/');
    final template = _pickTemplate(norm, options);
    return _substitute(template, names, options, packageName: packageName);
  }

  static String _pickTemplate(String norm, FeatureOptions options) {
    // ── Tests ──
    if (norm.endsWith('_test.dart')) {
      if (norm.contains('mapper')) return _tplMapperTest;
      if (norm.contains('cubit') || norm.contains('bloc')) {
        if (options.hasAdminCrud) return _tplAdminCrudBlocTest;
        if (options.hasPaginated) return _tplPaginatedBlocTest;
        return options.hasBloc ? _tplBlocTest : _tplCubitTest;
      }
      if (norm.contains('usecase') || norm.contains('use_case')) {
        if (options.hasUsecaseGen) return _tplUsecaseGenTest;
        return _tplUseCaseTest;
      }
      if (norm.contains('repository')) return _tplRepositoryTest;
      if (norm.contains('datasource') || norm.contains('data_source')) {
        return _tplDatasourceTest;
      }
      return _tplTest;
    }

    // ── Preferences ──
    if (norm.endsWith('_preferences.dart')) return _tplPreferences;

    // ── Extensions ──
    if (norm.endsWith('_extensions.dart')) return _tplExtensions;

    // ── Screen ──
    if (norm.endsWith('_screen.dart')) {
      if (options.hasAsyncCubit) return _tplScreenAsyncCubit;
      if (options.hasListCubit || (options.hasCubit && options.isList)) {
        return _tplScreenList;
      }
      return _tplScreen;
    }

    // ── Entity ──
    if (norm.endsWith('_entity.dart')) {
      if (options.freezed) return _tplEntityFreezed;
      return _tplEntity;
    }

    // ── Model ──
    if (norm.contains('data/models/') && norm.endsWith('_model.dart')) {
      if (options.freezed) return _tplModelFreezed;
      return _tplModel;
    }

    // ── Request DTOs ──
    if (norm.contains('models/requests/') &&
        norm.startsWith('models/requests/create_')) {
      if (options.freezed) return _tplCreateRequestFreezed;
      return _tplCreateRequest;
    }
    if (norm.contains('models/requests/') &&
        norm.startsWith('models/requests/update_')) {
      if (options.freezed) return _tplUpdateRequestFreezed;
      return _tplUpdateRequest;
    }

    // ── Datasource interfaces ──
    if (norm.contains('datasources/i_remote_')) {
      return _tplRemoteDatasourceInterface;
    }
    if (norm.contains('datasources/i_local_')) {
      return _tplLocalDatasourceInterface;
    }

    // ── Datasources ──
    if (norm.contains('datasources/mock_') &&
        norm.endsWith('_remote_data_source.dart')) {
      if (!options.injectable) {
        return options.isList
            ? _tplMockRemoteDatasourceNoInjectable
            : _tplMockRemoteDatasourceSingleNoInjectable;
      }
      return options.isList
          ? _tplMockRemoteDatasource
          : _tplMockRemoteDatasourceSingle;
    }
    if (norm.contains('datasources/mock_') &&
        norm.endsWith('_local_data_source.dart')) {
      return _tplMockLocalDatasource;
    }
    if (norm.endsWith('_remote_datasource.dart')) {
      if (!options.injectable) return _tplRemoteDatasourceNoInjectable;
      if (options.hasMultipleDatasources) {
        return options.isList
            ? _tplRemoteDatasourceWithMock
            : _tplRemoteDatasourceSingleWithMock;
      }
      return options.isList ? _tplRemoteDatasource : _tplRemoteDatasourceSingle;
    }
    if (norm.endsWith('_local_datasource.dart')) {
      // Check for specific storage backend
      if (options.hasHive) {
        if (options.mock) {
          return options.isList
              ? _tplLocalDatasourceHiveWithMock
              : _tplLocalDatasourceHive;
        }
        return options.isList
            ? _tplLocalDatasourceHive
            : _tplLocalDatasourceSingleHive;
      }
      if (options.hasSharedPrefs) {
        if (options.mock) {
          return options.isList
              ? _tplLocalDatasourceSharedPrefsWithMock
              : _tplLocalDatasourceSharedPrefs;
        }
        return options.isList
            ? _tplLocalDatasourceSharedPrefs
            : _tplLocalDatasourceSingleSharedPrefs;
      }
      if (options.hasSecureStorage) {
        if (options.mock) {
          return options.isList
              ? _tplLocalDatasourceSecureStorageWithMock
              : _tplLocalDatasourceSecureStorage;
        }
        return options.isList
            ? _tplLocalDatasourceSecureStorage
            : _tplLocalDatasourceSingleSecureStorage;
      }
      // Default: stub with mock support
      if (options.mock) {
        return options.isList
            ? _tplLocalDatasourceWithMock
            : _tplLocalDatasourceSingleWithMock;
      }
      return options.isList ? _tplLocalDatasource : _tplLocalDatasourceSingle;
    }

    // ── Mappers ──
    if (norm.contains('mappers/') && norm.endsWith('_mapper.dart')) {
      return _tplMapper;
    }

    // ── Repository interface (domain) ──
    if (norm.contains('domain/repositories/') &&
        norm.startsWith('domain/repositories/i_')) {
      if (options.streamOnly) return _tplRepositoryInterfaceStreamOnly;
      if (options.stream) return _tplRepositoryInterfaceStream;
      return _tplRepositoryInterface;
    }

    // ── Repository impl (data) ──
    if (norm.contains('data/repositories/') &&
        norm.endsWith('_repository.dart')) {
      if (options.streamOnly) {
        if (!options.injectable) {
          return _tplRepositoryImplStreamOnlyNoInjectable;
        }
        return _tplRepositoryImplStreamOnly;
      }
      if (options.stream) {
        if (!options.injectable) return _tplRepositoryImplStreamNoInjectable;
        return _tplRepositoryImplStream;
      }
      if (!options.injectable) return _tplRepositoryImplNoInjectable;
      return _tplRepositoryImpl;
    }

    // ── UseCase (get all) ──
    if (norm.contains('domain/usecases/') &&
        norm.startsWith('domain/usecases/get_') &&
        !norm.contains('by_id')) {
      if (options.hasUsecaseGen) return _tplUsecaseGen;
      return _tplUseCase;
    }

    // ── UseCase (get by id) ──
    if (norm.contains('domain/usecases/') &&
        norm.contains('get_') &&
        norm.contains('_by_id_')) {
      return _tplGetByIdUseCase;
    }

    // ── UseCase (stream/watch) ──
    if (norm.contains('domain/usecases/') &&
        norm.startsWith('domain/usecases/watch_')) {
      if (options.streamOnly) return _tplStreamUseCaseOnly;
      return _tplStreamUseCase;
    }

    // ── CRUD UseCases ──
    if (norm.contains('domain/usecases/') && norm.endsWith('_usecases.dart')) {
      // Determine which CRUD operations are selected.
      final hasCreate = options.hasCreate;
      final hasUpdate = options.hasUpdate;
      final hasDelete = options.hasDelete;

      // If only one operation, use the specific template.
      if (hasCreate && !hasUpdate && !hasDelete) return _tplCrudUseCasesCreate;
      if (!hasCreate && hasUpdate && !hasDelete) return _tplCrudUseCasesUpdate;
      if (!hasCreate && !hasUpdate && hasDelete) return _tplCrudUseCasesDelete;

      // If multiple operations, use combined template.
      return _tplCrudUseCasesCombined;
    }

    // ── Parameters ──
    if (norm.contains('domain/parameters/') &&
        norm.startsWith('domain/parameters/create_')) {
      if (options.validators) return _tplCreateParamsWithValidators;
      return _tplCreateParams;
    }
    if (norm.contains('domain/parameters/') &&
        norm.startsWith('domain/parameters/update_')) {
      if (options.validators) return _tplUpdateParamsWithValidators;
      return _tplUpdateParams;
    }

    // ── Bloc ──
    if (norm.contains('presentation/bloc/') && norm.endsWith('_event.dart')) {
      return _tplBlocEvent;
    }
    if (norm.contains('presentation/bloc/') && norm.endsWith('_bloc.dart')) {
      if (options.hasAdminCrud) return _tplAdminCrudBloc;
      if (options.hasPaginated) return _tplPaginatedBloc;
      return _tplBloc;
    }

    // ── Cubit ──
    if (norm.contains('presentation/cubit/') && norm.endsWith('_cubit.dart')) {
      if (options.hasAsyncCubit) return _tplAsyncCubit;
      if (options.hasListCubit) return _tplListCubit;
      if (options.optimistic && options.hasWriteOperations) {
        return _tplCubitOptimistic;
      }
      if (!options.freezed) return _tplCubitNoFreezed;
      return _tplCubit;
    }

    // ── State ──
    if (norm.endsWith('_state.dart') &&
        (norm.contains('presentation/bloc/') ||
            norm.contains('presentation/cubit/'))) {
      if (options.hasAdminCrud) return _tplAdminCrudState;
      if (options.freezed) return _tplStateFreezed;
      return _tplState;
    }

    // ── UI ──
    if (norm.endsWith('_page.dart')) return _tplPage;
    if (norm.endsWith('_widget.dart')) return _tplWidget;

    return _tplFallback;
  }

  static String _substitute(
    String template,
    NameUtils names,
    FeatureOptions options, {
    String? packageName,
  }) {
    // Generate field declarations from JSON.
    final fieldsDecl = _generateFieldsDecl(options.jsonFields);
    final fieldsCtorParams = _generateFieldsCtorParams(options.jsonFields);
    final fieldsCtor = _generateFieldsCtor(options.jsonFields);
    final fieldsJson = _generateFieldsJson(options.jsonFields);
    final fieldsFromJson = _generateFieldsFromJson(options.jsonFields);
    final entityFields = _generateEntityFields(options.jsonFields);
    final entityCtorParams = _generateEntityCtorParams(options.jsonFields);
    final mapperFields = _generateMapperFields(options.jsonFields);
    final requestFields = _generateRequestFields(options.jsonFields);
    final requestCtorParams = _generateRequestCtorParams(options.jsonFields);

    // Return types.
    final retType = options.returnType(names);
    final modelRetType = options.modelReturnType(names);

    // Named parameter annotation for DI disambiguation.
    final namedParam = options.mock ? "@Named('prod') " : '';

    // Mapper import and call (only when --mapper is enabled).
    final mapperImport = options.mapper
        ? "import '../mappers/{{featureSnake}}_mapper.dart';"
        : '';
    final mapperCall = options.mapper ? '.toDomain()' : '';
    final noMapperBody = options.mapper
        ? '    return models.toDomain();'
        : '    // TODO(nexo): implement mapping from {{Feature}}Model to {{Feature}}Entity.\n    return const [];';

    // First: substitute generated content blocks.
    var result = template
        .replaceAll('{{namedParam}}', namedParam)
        .replaceAll('{{mapperImport}}', mapperImport)
        .replaceAll('{{mapperCall}}', mapperCall)
        .replaceAll('{{noMapperBody}}', noMapperBody)
        .replaceAll('{{fieldsDecl}}', fieldsDecl)
        .replaceAll('{{fieldsCtorParams}}', fieldsCtorParams)
        .replaceAll('{{fieldsCtor}}', fieldsCtor)
        .replaceAll('{{fieldsJson}}', fieldsJson)
        .replaceAll('{{fieldsFromJson}}', fieldsFromJson)
        .replaceAll('{{entityFields}}', entityFields)
        .replaceAll('{{entityCtorParams}}', entityCtorParams)
        .replaceAll('{{mapperFields}}', mapperFields)
        .replaceAll('{{requestFields}}', requestFields)
        .replaceAll('{{requestCtorParams}}', requestCtorParams)
        .replaceAll('{{modelRetType}}', modelRetType)
        .replaceAll('{{retType}}', retType);

    // Second: substitute name placeholders (after content blocks are inserted).
    result = result
        .replaceAll('{{featureSnake}}', names.snakeCase)
        .replaceAll('{{Feature}}', names.pascalCase)
        .replaceAll('{{feature}}', _snakeToLowerCamel(names.snakeCase))
        .replaceAll('{{packageName}}', packageName ?? names.snakeCase);

    return result;
  }

  // ── JSON field generators ────────────────────────────────────────────────

  static String _generateFieldsDecl(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) return '  final String id;';
    return fields.entries.map((e) => '  final ${e.value} ${e.key};').join('\n');
  }

  static String _generateFieldsCtorParams(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) return '    required String id,';
    return fields.entries
        .map((e) => '    required ${e.value} ${e.key},')
        .join('\n');
  }

  static String _generateFieldsCtor(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) {
      return '  const {{Feature}}Model({required this.id});';
    }
    final params = fields.keys.map((k) => 'required this.$k').join(', ');
    return '  const {{Feature}}Model({$params});';
  }

  static String _generateFieldsJson(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) {
      return "    return {'id': id};";
    }
    final entries = fields.keys.map((k) => "'$k': $k").join(', ');
    return '    return {$entries};';
  }

  static String _generateFieldsFromJson(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) {
      return "    return {{Feature}}Model(id: json['id'] as String? ?? '');";
    }
    final assignments = fields.entries
        .map((e) {
          final name = e.key;
          final type = e.value;
          if (type == 'int') {
            return "$name: (json['$name'] as num?)?.toInt() ?? 0";
          }
          if (type == 'double') {
            return "$name: (json['$name'] as num?)?.toDouble() ?? 0.0";
          }
          if (type == 'bool') {
            return "$name: json['$name'] as bool? ?? false";
          }
          if (type == 'List<dynamic>') {
            return "$name: json['$name'] as List<dynamic>? ?? const []";
          }
          if (type == 'Map<String, dynamic>') {
            return "$name: json['$name'] as Map<String, dynamic>? ?? const {}";
          }
          return "$name: json['$name'] as String? ?? ''";
        })
        .join(',\n    ');
    return '    return {{Feature}}Model(\n    $assignments,\n    );';
  }

  static String _generateEntityFields(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) {
      return '  const {{Feature}}Entity({required this.id});\n  final String id;';
    }
    final params = fields.keys.map((k) => 'required this.$k').join(', ');
    final decls = fields.entries
        .map((e) => '  final ${e.value} ${e.key};')
        .join('\n');
    return '  const {{Feature}}Entity({$params});\n$decls';
  }

  static String _generateEntityCtorParams(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) return '    required String id,';
    return fields.entries
        .map((e) => '    required ${e.value} ${e.key},')
        .join('\n');
  }

  static String _generateMapperFields(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) {
      // Default: model has 'id' field
      return '  {{Feature}}Entity toDomain() => {{Feature}}Entity(id: id);';
    }
    final assigns = fields.keys.map((k) => '$k: $k').join(', ');
    return '  {{Feature}}Entity toDomain() => {{Feature}}Entity($assigns);';
  }

  static String _generateRequestFields(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) {
      return '  const {{RequestType}}({required this.id});\n  final String id;';
    }
    final params = fields.keys.map((k) => 'required this.$k').join(', ');
    final decls = fields.entries
        .map((e) => '  final ${e.value} ${e.key};')
        .join('\n');
    return '  const {{RequestType}}({$params});\n$decls';
  }

  static String _generateRequestCtorParams(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) return '    required String id,';
    return fields.entries
        .map((e) => '    required ${e.value} ${e.key},')
        .join('\n');
  }

  static String _snakeToLowerCamel(String snake) {
    final parts = snake.split('_').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return snake;
    return parts.first +
        parts
            .skip(1)
            .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
            .join();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Fallback
// ──────────────────────────────────────────────────────────────────────────────

const _tplFallback = r'''
// Placeholder generated by nexo_cli for {{featureSnake}}.
''';

// ──────────────────────────────────────────────────────────────────────────────
// Preferences
// ──────────────────────────────────────────────────────────────────────────────

const _tplPreferences = r'''
import 'package:shared_preferences/shared_preferences.dart';

class {{Feature}}Preferences {
  static const _key = '{{featureSnake}}_completed';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> setCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Extensions
// ──────────────────────────────────────────────────────────────────────────────

const _tplExtensions = r'''
import '../entities/{{featureSnake}}_entity.dart';

extension {{Feature}}Extensions on {{Feature}}Entity {
  // TODO(nexo): add convenience getters here.
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Screen (presentation-only)
// ──────────────────────────────────────────────────────────────────────────────

const _tplScreen = r'''
import 'package:flutter/material.dart';

class {{Feature}}Screen extends StatefulWidget {
  const {{Feature}}Screen({super.key});

  @override
  State<{{Feature}}Screen> createState() => _{{Feature}}ScreenState();
}

class _{{Feature}}ScreenState extends State<{{Feature}}Screen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Entity (plain)
// ──────────────────────────────────────────────────────────────────────────────

const _tplEntity = r'''
class {{Feature}}Entity {
{{entityFields}}
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Entity (freezed)
// ──────────────────────────────────────────────────────────────────────────────

const _tplEntityFreezed = r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{featureSnake}}_entity.freezed.dart';

@freezed
abstract class {{Feature}}Entity with _${{Feature}}Entity {
  const factory {{Feature}}Entity({
{{fieldsCtorParams}}
  }) = _{{Feature}}Entity;
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Model (plain)
// ──────────────────────────────────────────────────────────────────────────────

const _tplModel = r'''
class {{Feature}}Model {
{{fieldsCtor}}
{{fieldsDecl}}

  factory {{Feature}}Model.fromJson(Map<String, dynamic> json) {
{{fieldsFromJson}}
  }

  Map<String, dynamic> toJson() {
{{fieldsJson}}
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Model (freezed)
// ──────────────────────────────────────────────────────────────────────────────

const _tplModelFreezed = r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{featureSnake}}_model.freezed.dart';
part '{{featureSnake}}_model.g.dart';

@freezed
abstract class {{Feature}}Model with _${{Feature}}Model {
  const factory {{Feature}}Model({
{{fieldsCtorParams}}
  }) = _{{Feature}}Model;

  factory {{Feature}}Model.fromJson(Map<String, dynamic> json) =>
      _${{Feature}}ModelFromJson(json);
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Request DTOs
// ──────────────────────────────────────────────────────────────────────────────

const _tplCreateRequest = r'''
class Create{{Feature}}Request {
{{requestFields}}

  Map<String, dynamic> toJson() {
{{fieldsJson}}
  }
}
''';

const _tplCreateRequestFreezed = r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_{{featureSnake}}_request.freezed.dart';
part 'create_{{featureSnake}}_request.g.dart';

@freezed
abstract class Create{{Feature}}Request with _Create{{Feature}}Request {
  const factory Create{{Feature}}Request({
{{fieldsCtorParams}}
  }) = _Create{{Feature}}Request;

  factory Create{{Feature}}Request.fromJson(Map<String, dynamic> json) =>
      _Create{{Feature}}RequestFromJson(json);
}
''';

const _tplUpdateRequest = r'''
class Update{{Feature}}Request {
{{requestFields}}

  Map<String, dynamic> toJson() {
{{fieldsJson}}
  }
}
''';

const _tplUpdateRequestFreezed = r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_{{featureSnake}}_request.freezed.dart';
part 'update_{{featureSnake}}_request.g.dart';

@freezed
abstract class Update{{Feature}}Request with _Update{{Feature}}Request {
  const factory Update{{Feature}}Request({
{{fieldsCtorParams}}
  }) = _Update{{Feature}}Request;

  factory Update{{Feature}}Request.fromJson(Map<String, dynamic> json) =>
      _Update{{Feature}}RequestFromJson(json);
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Datasource interfaces
// ──────────────────────────────────────────────────────────────────────────────

const _tplRemoteDatasourceInterface = r'''
import '../models/{{featureSnake}}_model.dart';

abstract interface class IRemote{{Feature}}DataSource {
  Future<{{modelRetType}}> getAll();
}
''';

const _tplLocalDatasourceInterface = r'''
import '../models/{{featureSnake}}_model.dart';

abstract interface class ILocal{{Feature}}DataSource {
  Future<{{modelRetType}}> getAll();
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Remote datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplRemoteDatasource = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import 'i_remote_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: IRemote{{Feature}}DataSource)
class {{Feature}}RemoteDataSource extends BaseRemoteDataSource
    implements IRemote{{Feature}}DataSource {
  {{Feature}}RemoteDataSource(super.client, {required super.logger});

  @override
  Future<{{modelRetType}}> getAll() async {
    final response = await get('{{featureSnake}}/');
    final data = response.data;
    if (data is! List) return const [];
    return List.from(data)
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }
}
''';

const _tplRemoteDatasourceWithMock = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import 'i_remote_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): replace @Named with env: [AppEnvironment.prod] if using environment-based DI.
@Named('prod')
@LazySingleton(as: IRemote{{Feature}}DataSource)
class {{Feature}}RemoteDataSource extends BaseRemoteDataSource
    implements IRemote{{Feature}}DataSource {
  {{Feature}}RemoteDataSource(super.client, {required super.logger});

  @override
  Future<{{modelRetType}}> getAll() async {
    final response = await get('{{featureSnake}}/');
    final data = response.data;
    if (data is! List) return const [];
    return List.from(data)
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }
}
''';

const _tplRemoteDatasourceSingleWithMock = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import 'i_remote_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): replace @Named with env: [AppEnvironment.prod] if using environment-based DI.
@Named('prod')
@LazySingleton(as: IRemote{{Feature}}DataSource)
class {{Feature}}RemoteDataSource extends BaseRemoteDataSource
    implements IRemote{{Feature}}DataSource {
  {{Feature}}RemoteDataSource(super.client, {required super.logger});

  @override
  Future<{{modelRetType}}> getAll() async {
    final response = await get('{{featureSnake}}/');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Expected a JSON object, got ${data.runtimeType}');
    }
    return {{Feature}}Model.fromJson(data);
  }
}
''';

const _tplRemoteDatasourceNoInjectable = r'''
import 'package:nexo/nexo_core.dart';

import '../models/{{featureSnake}}_model.dart';

class {{Feature}}RemoteDataSource extends BaseRemoteDataSource {
  {{Feature}}RemoteDataSource(super.client, {required super.logger});

  Future<{{modelRetType}}> getAll() async {
    final response = await get('{{featureSnake}}/');
    final data = response.data;
    if (data is! List) return const [];
    return List.from(data)
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }
}
''';

const _tplRemoteDatasourceSingle = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import 'i_remote_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): add @LazySingleton(as: IRemote{{Feature}}DataSource) if using DI.
// If you have multiple implementations (mock + prod), add env: parameter.
@LazySingleton(as: IRemote{{Feature}}DataSource)
class {{Feature}}RemoteDataSource extends BaseRemoteDataSource
    implements IRemote{{Feature}}DataSource {
  {{Feature}}RemoteDataSource(super.client, {required super.logger});

  @override
  Future<{{modelRetType}}> getAll() async {
    final response = await get('{{featureSnake}}/');
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw StateError('Expected a JSON object, got ${data.runtimeType}');
    }
    return {{Feature}}Model.fromJson(data);
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Local datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplLocalDatasource = r'''
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  @override
  Future<{{modelRetType}}> getAll() async {
    // TODO(nexo): implement local storage read.
    return const [];
  }
}
''';

const _tplLocalDatasourceWithMock = r'''
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): replace @Named with env: parameter if using environment-based DI.
@Named('local')
@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  @override
  Future<{{modelRetType}}> getAll() async {
    // TODO(nexo): implement local storage read.
    return const [];
  }
}
''';

const _tplLocalDatasourceSingle = r'''
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  @override
  Future<{{modelRetType}}> getAll() async {
    // TODO(nexo): implement local storage read.
    throw UnimplementedError();
  }
}
''';

const _tplLocalDatasourceSingleWithMock = r'''
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): replace @Named with env: parameter if using environment-based DI.
@Named('local')
@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  @override
  Future<{{modelRetType}}> getAll() async {
    // TODO(nexo): implement local storage read.
    throw UnimplementedError();
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Hive local datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplLocalDatasourceHive = r'''
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._box});

  final Box<Map> _box;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final data = _box.get(_key);
    if (data == null) return const [];
    final list = data['items'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }

  Future<void> saveAll(List<{{Feature}}Model> items) async {
    await _box.put(_key, {
      'items': items.map((e) => e.toJson()).toList(),
    });
  }
}
''';

const _tplLocalDatasourceHiveWithMock = r'''
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@Named('local')
@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._box});

  final Box<Map> _box;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final data = _box.get(_key);
    if (data == null) return const [];
    final list = data['items'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }

  Future<void> saveAll(List<{{Feature}}Model> items) async {
    await _box.put(_key, {
      'items': items.map((e) => e.toJson()).toList(),
    });
  }
}
''';

const _tplLocalDatasourceSingleHive = r'''
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._box});

  final Box<Map> _box;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final data = _box.get(_key);
    if (data == null) return const [];
    return {{Feature}}Model.fromJson(data);
  }

  Future<void> save({{Feature}}Model item) async {
    await _box.put(_key, item.toJson());
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// SharedPreferences local datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplLocalDatasourceSharedPrefs = r'''
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._prefs});

  final SharedPreferences _prefs;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }

  Future<void> saveAll(List<{{Feature}}Model> items) async {
    final json = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(json));
  }
}
''';

const _tplLocalDatasourceSharedPrefsWithMock = r'''
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@Named('local')
@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._prefs});

  final SharedPreferences _prefs;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }

  Future<void> saveAll(List<{{Feature}}Model> items) async {
    final json = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(json));
  }
}
''';

const _tplLocalDatasourceSingleSharedPrefs = r'''
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._prefs});

  final SharedPreferences _prefs;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final raw = _prefs.getString(_key);
    if (raw == null) throw StateError('No cached {{Feature}}');
    return {{Feature}}Model.fromJson(jsonDecode(raw));
  }

  Future<void> save({{Feature}}Model item) async {
    await _prefs.setString(_key, jsonEncode(item.toJson()));
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// SecureStorage local datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplLocalDatasourceSecureStorage = r'''
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._storage});

  final FlutterSecureStorage _storage;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }

  Future<void> saveAll(List<{{Feature}}Model> items) async {
    final json = items.map((e) => e.toJson()).toList();
    await _storage.write(key: _key, value: jsonEncode(json));
  }
}
''';

const _tplLocalDatasourceSecureStorageWithMock = r'''
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@Named('local')
@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._storage});

  final FlutterSecureStorage _storage;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
  }

  Future<void> saveAll(List<{{Feature}}Model> items) async {
    final json = items.map((e) => e.toJson()).toList();
    await _storage.write(key: _key, value: jsonEncode(json));
  }
}
''';

const _tplLocalDatasourceSingleSecureStorage = r'''
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

@LazySingleton(as: ILocal{{Feature}}DataSource)
class {{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  {{Feature}}LocalDataSource({required this._storage});

  final FlutterSecureStorage _storage;

  static const _key = '{{featureSnake}}';

  @override
  Future<{{modelRetType}}> getAll() async {
    final raw = await _storage.read(key: _key);
    if (raw == null) throw StateError('No cached {{Feature}}');
    return {{Feature}}Model.fromJson(jsonDecode(raw));
  }

  Future<void> save({{Feature}}Model item) async {
    await _storage.write(key: _key, value: jsonEncode(item.toJson()));
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Mock remote datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplMockRemoteDatasource = r'''
import 'package:injectable/injectable.dart';

import 'i_remote_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): replace @Named with env: [AppEnvironment.mock] if using environment-based DI.
@Named('mock')
@LazySingleton(as: IRemote{{Feature}}DataSource)
class Mock{{Feature}}RemoteDataSource implements IRemote{{Feature}}DataSource {
  @override
  Future<{{modelRetType}}> getAll() async {
    return const [];
  }
}
''';

const _tplMockRemoteDatasourceSingle = r'''
import 'package:injectable/injectable.dart';

import 'i_remote_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): replace @Named with env: [AppEnvironment.mock] if using environment-based DI.
@Named('mock')
@LazySingleton(as: IRemote{{Feature}}DataSource)
class Mock{{Feature}}RemoteDataSource implements IRemote{{Feature}}DataSource {
  @override
  Future<{{modelRetType}}> getAll() async {
    // TODO(nexo): return a mock {{Feature}}Model instance.
    throw UnimplementedError();
  }
}
''';

const _tplMockRemoteDatasourceNoInjectable = r'''
import '../models/{{featureSnake}}_model.dart';

class Mock{{Feature}}RemoteDataSource {
  Future<{{modelRetType}}> getAll() async {
    return const [];
  }
}
''';

const _tplMockRemoteDatasourceSingleNoInjectable = r'''
import '../models/{{featureSnake}}_model.dart';

class Mock{{Feature}}RemoteDataSource {
  Future<{{modelRetType}}> getAll() async {
    // TODO(nexo): return a mock {{Feature}}Model instance.
    throw UnimplementedError();
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Mock local datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplMockLocalDatasource = r'''
import 'package:injectable/injectable.dart';

import 'i_local_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): replace @Named with env: parameter if using environment-based DI.
@Named('mock')
@LazySingleton(as: ILocal{{Feature}}DataSource)
class Mock{{Feature}}LocalDataSource implements ILocal{{Feature}}DataSource {
  @override
  Future<{{modelRetType}}> getAll() async {
    return const [];
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Mapper
// ──────────────────────────────────────────────────────────────────────────────

const _tplMapper = r'''
import '../models/{{featureSnake}}_model.dart';
import '../../domain/entities/{{featureSnake}}_entity.dart';

extension {{Feature}}Mapper on {{Feature}}Model {
{{mapperFields}}
}

extension {{Feature}}ListMapper on List<{{Feature}}Model> {
  List<{{Feature}}Entity> toDomain() => map((e) => e.toDomain()).toList();
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Repository interface (domain)
// ──────────────────────────────────────────────────────────────────────────────

const _tplRepositoryInterface = r'''
import '../../domain/entities/{{featureSnake}}_entity.dart';

abstract interface class I{{Feature}}Repository {
  Future<{{retType}}> getAll();
}
''';

const _tplRepositoryInterfaceStream = r'''
import '../../domain/entities/{{featureSnake}}_entity.dart';

abstract interface class I{{Feature}}Repository {
  Future<{{retType}}> getAll();
  Stream<{{retType}}> watchAll();
}
''';

const _tplRepositoryInterfaceStreamOnly = r'''
import '../../domain/entities/{{featureSnake}}_entity.dart';

abstract interface class I{{Feature}}Repository {
  Stream<{{retType}}> watchAll();
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Repository impl (data)
// ──────────────────────────────────────────────────────────────────────────────

const _tplRepositoryImpl = r'''
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/repositories/i_{{featureSnake}}_repository.dart';
import '../datasources/i_remote_{{featureSnake}}_data_source.dart';
{{mapperImport}}

@LazySingleton(as: I{{Feature}}Repository)
class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({{{namedParam}}required this._remoteDatasource});

  final IRemote{{Feature}}DataSource _remoteDatasource;

  @override
  Future<{{retType}}> getAll() async {
    final models = await _remoteDatasource.getAll();
{{noMapperBody}}
  }
}
''';

const _tplRepositoryImplNoInjectable = r'''
import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/repositories/i_{{featureSnake}}_repository.dart';
import '../datasources/{{featureSnake}}_remote_datasource.dart';
{{mapperImport}}

class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({required this._remoteDatasource});

  final {{Feature}}RemoteDataSource _remoteDatasource;

  @override
  Future<{{retType}}> getAll() async {
    final models = await _remoteDatasource.getAll();
{{noMapperBody}}
  }
}
''';

const _tplRepositoryImplStream = r'''
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/repositories/i_{{featureSnake}}_repository.dart';
import '../datasources/i_remote_{{featureSnake}}_data_source.dart';
{{mapperImport}}

@LazySingleton(as: I{{Feature}}Repository)
class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({{{namedParam}}required this._remoteDatasource});

  final IRemote{{Feature}}DataSource _remoteDatasource;

  @override
  Future<{{retType}}> getAll() async {
    final models = await _remoteDatasource.getAll();
{{noMapperBody}}
  }

  @override
  Stream<{{retType}}> watchAll() {
    // TODO(nexo): implement stream from datasource.
    return const Stream.empty();
  }
}
''';

const _tplRepositoryImplStreamNoInjectable = r'''
import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/repositories/i_{{featureSnake}}_repository.dart';
import '../datasources/{{featureSnake}}_remote_datasource.dart';
{{mapperImport}}

class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({required this._remoteDatasource});

  final {{Feature}}RemoteDataSource _remoteDatasource;

  @override
  Future<{{retType}}> getAll() async {
    final models = await _remoteDatasource.getAll();
{{noMapperBody}}
  }

  @override
  Stream<{{retType}}> watchAll() {
    // TODO(nexo): implement stream from datasource.
    return const Stream.empty();
  }
}
''';

const _tplRepositoryImplStreamOnly = r'''
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/repositories/i_{{featureSnake}}_repository.dart';
import '../datasources/i_remote_{{featureSnake}}_data_source.dart';
{{mapperImport}}

@LazySingleton(as: I{{Feature}}Repository)
class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({{{namedParam}}required this._remoteDatasource});

  final IRemote{{Feature}}DataSource _remoteDatasource;

  @override
  Stream<{{retType}}> watchAll() {
    // TODO(nexo): implement stream from datasource.
    return const Stream.empty();
  }
}
''';

const _tplRepositoryImplStreamOnlyNoInjectable = r'''
import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/repositories/i_{{featureSnake}}_repository.dart';
import '../datasources/{{featureSnake}}_remote_datasource.dart';
{{mapperImport}}

class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({required this._remoteDatasource});

  final {{Feature}}RemoteDataSource _remoteDatasource;

  @override
  Stream<{{retType}}> watchAll() {
    // TODO(nexo): implement stream from datasource.
    return const Stream.empty();
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// UseCase (get)
// ──────────────────────────────────────────────────────────────────────────────

const _tplUseCase = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{featureSnake}}_entity.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

@injectable
class Get{{Feature}}UseCase extends NexoUseCase<{{retType}}, NoParams> {
  Get{{Feature}}UseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<{{retType}}> execute(NoParams params) async {
    return await _repository.getAll();
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// CRUD UseCases
// ──────────────────────────────────────────────────────────────────────────────

const _tplCrudUseCasesCreate = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{featureSnake}}_entity.dart';
import '../parameters/create_{{featureSnake}}_params.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

@injectable
class Create{{Feature}}UseCase
    extends NexoUseCase<{{Feature}}Entity, Create{{Feature}}Params> {
  Create{{Feature}}UseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<{{Feature}}Entity> execute(Create{{Feature}}Params params) async {
    // TODO(nexo): implement create.
    return (await _repository.getAll()).first;
  }
}

/// Helper for optimistic create:
/// 1. Apply optimistic state immediately
/// 2. Call this use case
/// 3. On success, replace with real data; on failure, rollback.
///
/// Usage:
/// ```dart
/// final result = await performOptimistic<MyState, MyEntity>(
///   optimisticState: MyState.loading(),
///   rollbackState: previousState,
///   action: () => createUseCase(params),
///   onSuccess: (entity) => MyState.success(data: entity),
/// );
/// ```
''';

const _tplCrudUseCasesUpdate = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{featureSnake}}_entity.dart';
import '../parameters/update_{{featureSnake}}_params.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

@injectable
class Update{{Feature}}UseCase
    extends NexoUseCase<{{Feature}}Entity, Update{{Feature}}Params> {
  Update{{Feature}}UseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<{{Feature}}Entity> execute(Update{{Feature}}Params params) async {
    // TODO(nexo): implement update.
    return (await _repository.getAll()).first;
  }
}
''';

const _tplCrudUseCasesDelete = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../repositories/i_{{featureSnake}}_repository.dart';

@injectable
class Delete{{Feature}}UseCase extends NexoUseCase<void, String> {
  Delete{{Feature}}UseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<void> execute(String id) async {
    // TODO(nexo): implement delete.
    await _repository.getAll();
  }
}
''';

const _tplCrudUseCasesCombined = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{featureSnake}}_entity.dart';
import '../parameters/create_{{featureSnake}}_params.dart';
import '../parameters/update_{{featureSnake}}_params.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

/// Use case for creating a new {{Feature}}.
@injectable
class Create{{Feature}}UseCase
    extends NexoUseCase<{{Feature}}Entity, Create{{Feature}}Params> {
  Create{{Feature}}UseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<{{Feature}}Entity> execute(Create{{Feature}}Params params) async {
    // TODO(nexo): implement create.
    return (await _repository.getAll()).first;
  }
}

/// Use case for updating an existing {{Feature}}.
@injectable
class Update{{Feature}}UseCase
    extends NexoUseCase<{{Feature}}Entity, Update{{Feature}}Params> {
  Update{{Feature}}UseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<{{Feature}}Entity> execute(Update{{Feature}}Params params) async {
    // TODO(nexo): implement update.
    return (await _repository.getAll()).first;
  }
}

/// Use case for deleting a {{Feature}} by ID.
@injectable
class Delete{{Feature}}UseCase extends NexoUseCase<void, String> {
  Delete{{Feature}}UseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<void> execute(String id) async {
    // TODO(nexo): implement delete.
    await _repository.getAll();
  }
}
''';

const _tplCubitOptimistic = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/parameters/create_{{featureSnake}}_params.dart';
import '../../domain/parameters/update_{{featureSnake}}_params.dart';
import '../../domain/usecases/get_{{featureSnake}}_usecase.dart';
import '{{featureSnake}}_state.dart';

@injectable
class {{Feature}}Cubit extends NexoCubit<{{Feature}}State> {
  {{Feature}}Cubit({
    required this._get{{Feature}}UseCase,
    required this._create{{Feature}}UseCase,
    required this._update{{Feature}}UseCase,
    required this._delete{{Feature}}UseCase,
  }) : super(const {{Feature}}State.loading());

  final Get{{Feature}}UseCase _get{{Feature}}UseCase;
  final Create{{Feature}}UseCase _create{{Feature}}UseCase;
  final Update{{Feature}}UseCase _update{{Feature}}UseCase;
  final Delete{{Feature}}UseCase _delete{{Feature}}UseCase;

  Future<void> load() async {
    await executeEither<{{retType}}>(
      action: () => _get{{Feature}}UseCase(const NoParams()),
      onLoading: () => const {{Feature}}State.loading(),
      onSuccess: (data) => {{Feature}}State.success(data: data),
      onError: (failure) => {{Feature}}State.error(failure: failure),
    );
  }

  Future<void> create(Create{{Feature}}Params params) async {
    final result = await performOptimistic<{{Feature}}State, {{Feature}}Entity>(
      optimisticState: const {{Feature}}State.loading(),
      rollbackState: state,
      action: () => _create{{Feature}}UseCase(params),
      onSuccess: (entity) => state.copyWith(
        data: [entity, ...?state.data],
      ),
    );
    emit(result.state);
    if (result.failure != null) {
      emit({{Feature}}State.error(failure: result.failure));
    }
  }

  Future<void> update(Update{{Feature}}Params params) async {
    final result = await performOptimistic<{{Feature}}State, {{Feature}}Entity>(
      optimisticState: const {{Feature}}State.loading(),
      rollbackState: state,
      action: () => _update{{Feature}}UseCase(params),
      onSuccess: (entity) {
        final data = state.data?.map((e) => e.id == entity.id ? entity : e).toList();
        return state.copyWith(data: data);
      },
    );
    emit(result.state);
    if (result.failure != null) {
      emit({{Feature}}State.error(failure: result.failure));
    }
  }

  Future<void> delete(String id) async {
    final result = await performOptimistic<{{Feature}}State, void>(
      optimisticState: const {{Feature}}State.loading(),
      rollbackState: state,
      action: () => _delete{{Feature}}UseCase(id),
      onSuccess: (_) {
        final data = state.data?.where((e) => e.id != id).toList();
        return state.copyWith(data: data);
      },
    );
    emit(result.state);
    if (result.failure != null) {
      emit({{Feature}}State.error(failure: result.failure));
    }
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Parameters
// ──────────────────────────────────────────────────────────────────────────────

const _tplCreateParams = r'''
import 'package:nexo/nexo_core.dart';

class Create{{Feature}}Params {
  const Create{{Feature}}Params({required this.id});

  final String id;

  /// Validates this params instance using NexoValidators.
  /// Returns null if valid, otherwise an error message.
  static String? validateId(String? value) {
    return NexoValidators.requiredField(fieldName: 'id')(value);
  }
}
''';

const _tplCreateParamsWithValidators = r'''
import 'package:nexo/nexo_core.dart';

class Create{{Feature}}Params {
  const Create{{Feature}}Params({required this.id});

  final String id;

  /// Validates this params instance using NexoValidators.
  /// Returns null if valid, otherwise an error message.
  static String? validateId(String? value) {
    return NexoValidators.requiredField(fieldName: 'id')(value);
  }

  /// Validates all fields. Returns null if valid, otherwise first error message.
  static String? validateAll({required String? id}) {
    return NexoValidators.compose<String>([
      NexoValidators.requiredField(fieldName: 'id'),
    ])(id);
  }
}
''';

const _tplUpdateParams = r'''
import 'package:nexo/nexo_core.dart';

class Update{{Feature}}Params {
  const Update{{Feature}}Params({required this.id});

  final String id;

  /// Validates this params instance using NexoValidators.
  /// Returns null if valid, otherwise an error message.
  static String? validateId(String? value) {
    return NexoValidators.requiredField(fieldName: 'id')(value);
  }
}
''';

const _tplUpdateParamsWithValidators = r'''
import 'package:nexo/nexo_core.dart';

class Update{{Feature}}Params {
  const Update{{Feature}}Params({required this.id});

  final String id;

  /// Validates this params instance using NexoValidators.
  /// Returns null if valid, otherwise an error message.
  static String? validateId(String? value) {
    return NexoValidators.requiredField(fieldName: 'id');
  }

  /// Validates all fields. Returns null if valid, otherwise first error message.
  static String? validateAll({required String? id}) {
    return NexoValidators.compose<String>([
      NexoValidators.requiredField(fieldName: 'id'),
    ])(id);
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// State (plain)
// ──────────────────────────────────────────────────────────────────────────────

const _tplState = r'''
import 'package:nexo/nexo_core.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';

typedef {{Feature}}State = NexoAsyncState<{{retType}}>;
''';

// ──────────────────────────────────────────────────────────────────────────────
// State (freezed)
// ──────────────────────────────────────────────────────────────────────────────

const _tplStateFreezed = r'''
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nexo/nexo_errors.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';

part '{{featureSnake}}_state.freezed.dart';

@freezed
abstract class {{Feature}}State with _${{Feature}}State {
  const factory {{Feature}}State.loading() = _{{Feature}}StateLoading;
  const factory {{Feature}}State.success({required {{retType}} data}) =
      _{{Feature}}StateSuccess;
  const factory {{Feature}}State.error({Failure? failure}) = _{{Feature}}StateError;
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Bloc event (freezed)
// ──────────────────────────────────────────────────────────────────────────────

const _tplBlocEvent = r'''
import 'package:freezed_annotation/freezed_annotation.dart';

part '{{featureSnake}}_event.freezed.dart';

@freezed
abstract class {{Feature}}Event with _${{Feature}}Event {
  const factory {{Feature}}Event.load() = _{{Feature}}Load;
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Bloc
// ──────────────────────────────────────────────────────────────────────────────

const _tplBloc = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/usecases/get_{{featureSnake}}_usecase.dart';
import '{{featureSnake}}_event.dart';
import '{{featureSnake}}_state.dart';

@injectable
class {{Feature}}Bloc extends NexoBloc<{{Feature}}Event, {{Feature}}State> {
  {{Feature}}Bloc({
    required this._get{{Feature}}UseCase,
  }) : super(const {{Feature}}State.loading()) {
    on<{{Feature}}Event>(_onEvent);
  }

  final Get{{Feature}}UseCase _get{{Feature}}UseCase;

  Future<void> _onEvent(
    {{Feature}}Event event,
    Emitter<{{Feature}}State> emit,
  ) async {
    await event.when(load: () => _onLoad(emit));
  }

  Future<void> _onLoad(Emitter<{{Feature}}State> emit) async {
    await executeEither<{{retType}}>(
      emit: emit,
      action: () => _get{{Feature}}UseCase(const NoParams()),
      onLoading: () => const {{Feature}}State.loading(),
      onSuccess: (data) => {{Feature}}State.success(data: data),
      onError: (failure) => {{Feature}}State.error(failure: failure),
    );
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Cubit
// ──────────────────────────────────────────────────────────────────────────────

const _tplCubit = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/usecases/get_{{featureSnake}}_usecase.dart';
import '{{featureSnake}}_state.dart';

@injectable
class {{Feature}}Cubit extends NexoCubit<{{Feature}}State> {
  {{Feature}}Cubit({
    required this._get{{Feature}}UseCase,
  }) : super(const {{Feature}}State.loading());

  final Get{{Feature}}UseCase _get{{Feature}}UseCase;

  Future<void> load() async {
    await executeEither<{{retType}}>(
      action: () => _get{{Feature}}UseCase(const NoParams()),
      onLoading: () => const {{Feature}}State.loading(),
      onSuccess: (data) => {{Feature}}State.success(data: data),
      onError: (failure) => {{Feature}}State.error(failure: failure),
    );
  }
}
''';

const _tplCubitNoFreezed = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/usecases/get_{{featureSnake}}_usecase.dart';
import '{{featureSnake}}_state.dart';

@injectable
class {{Feature}}Cubit extends NexoCubit<{{Feature}}State> {
  {{Feature}}Cubit({
    required this._get{{Feature}}UseCase,
  }) : super(const NexoAsyncLoading());

  final Get{{Feature}}UseCase _get{{Feature}}UseCase;

  Future<void> load() async {
    await executeEither<{{retType}}>(
      action: () => _get{{Feature}}UseCase(const NoParams()),
      onLoading: () => const NexoAsyncLoading(),
      onSuccess: (data) => NexoAsyncSuccess(data),
      onError: (failure) => NexoAsyncFailure(failure),
    );
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// ListCubit
// ──────────────────────────────────────────────────────────────────────────────

const _tplListCubit = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/usecases/get_{{featureSnake}}_usecase.dart';
import '{{featureSnake}}_state.dart';

@injectable
class {{Feature}}Cubit extends NexoCubit<{{Feature}}State> {
  {{Feature}}Cubit({
    required this._get{{Feature}}UseCase,
  }) : super(const {{Feature}}State.loading());

  final Get{{Feature}}UseCase _get{{Feature}}UseCase;

  Future<void> load() async {
    await executeEither<List<{{Feature}}Entity>>(
      action: () => _get{{Feature}}UseCase(const NoParams()),
      onLoading: () => const {{Feature}}State.loading(),
      onSuccess: (data) => {{Feature}}State.success(data: data),
      onError: (failure) => {{Feature}}State.error(failure: failure),
    );
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Page
// ──────────────────────────────────────────────────────────────────────────────

const _tplPage = r'''
import 'package:flutter/material.dart';

class {{Feature}}Page extends StatelessWidget {
  const {{Feature}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Widget
// ──────────────────────────────────────────────────────────────────────────────

const _tplWidget = r'''
import 'package:flutter/material.dart';

class {{Feature}}Widget extends StatelessWidget {
  const {{Feature}}Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// NexoAsyncCubit (simpler pattern: fetch() + load/retry/refresh)
// ──────────────────────────────────────────────────────────────────────────────

const _tplAsyncCubit = r'''
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/usecases/get_{{featureSnake}}_usecase.dart';

/// Cubit using NexoAsyncCubit pattern.
/// State is `NexoAsyncState<T>` (idle/loading/success/failure).
/// Use .load() to fetch, .retry() after error, .refresh() for silent reload.
@injectable
class {{Feature}}Cubit extends NexoAsyncCubit<{{retType}}> {
  {{Feature}}Cubit({required this._get{{Feature}}UseCase});

  final Get{{Feature}}UseCase _get{{Feature}}UseCase;

  @override
  Future<Result<{{retType}}>> fetch() => _get{{Feature}}UseCase(const NoParams());
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// NexoStreamUseCase (real-time / WebSocket / Firestore)
// ──────────────────────────────────────────────────────────────────────────────

const _tplStreamUseCase = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{featureSnake}}_entity.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

/// Stream use case for real-time data (WebSocket, Firestore, etc.).
/// Returns `Stream<Result<T>>` that emits on each update.
@injectable
class Watch{{Feature}}StreamUseCase
    extends NexoStreamUseCase<{{retType}}, NoParams> {
  Watch{{Feature}}StreamUseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Stream<{{retType}}> build(NoParams params) {
    return _repository.watchAll();
  }
}
''';

const _tplStreamUseCaseOnly = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{featureSnake}}_entity.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

/// Stream-only use case for real-time data (WebSocket, Firestore, etc.).
/// Returns `Stream<Result<T>>` that emits on each update.
@injectable
class Watch{{Feature}}StreamUseCase
    extends NexoStreamUseCase<{{retType}}, NoParams> {
  Watch{{Feature}}StreamUseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Stream<{{retType}}> build(NoParams params) {
    return _repository.watchAll();
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Get by ID UseCase
// ──────────────────────────────────────────────────────────────────────────────

const _tplGetByIdUseCase = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../entities/{{featureSnake}}_entity.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

/// Use case for getting a single {{Feature}} by ID.
@injectable
class Get{{Feature}}ByIdUseCase
    extends NexoUseCase<{{Feature}}Entity, String> {
  Get{{Feature}}ByIdUseCase(
    super._logger, {
    required this._repository,
  });

  final I{{Feature}}Repository _repository;

  @override
  Future<{{Feature}}Entity> execute(String id) async {
    // TODO(nexo): implement get by id.
    return (await _repository.getAll()).first;
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Screen with NexoAsyncCubit (uses NexoAsyncStateBuilder)
// ──────────────────────────────────────────────────────────────────────────────

const _tplScreenAsyncCubit = r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nexo/nexo_ui.dart';

import '../domain/entities/{{featureSnake}}_entity.dart';
import 'cubit/{{featureSnake}}_cubit.dart';

class {{Feature}}Screen extends StatelessWidget {
  const {{Feature}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<{{Feature}}Cubit>()..load(),
      child: const _{{Feature}}View(),
    );
  }
}

class _{{Feature}}View extends StatelessWidget {
  const _{{Feature}}View();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<{{Feature}}Cubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('{{Feature}}')),
      body: NexoAsyncStateBuilder<{{retType}}>(
        state: cubit.state,
        success: (context, data) {
          if (data.isEmpty) {
            return const NexoEmptyView(
              title: 'No data',
              subtitle: 'There is nothing to show here.',
            );
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(data[index].toString()),
            ),
          );
        },
        failure: (context, failure) => NexoFailureView(
          failure: failure,
          onRetry: () => cubit.retry(),
        ),
      ),
    );
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Screen with list (uses NexoEmptyView)
// ──────────────────────────────────────────────────────────────────────────────

const _tplScreenList = r'''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:nexo/nexo_ui.dart';

import 'cubit/{{featureSnake}}_cubit.dart';
import 'cubit/{{featureSnake}}_state.dart';

class {{Feature}}Screen extends StatelessWidget {
  const {{Feature}}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<{{Feature}}Cubit>()..load(),
      child: const _{{Feature}}View(),
    );
  }
}

class _{{Feature}}View extends StatelessWidget {
  const _{{Feature}}View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('{{Feature}}')),
      body: BlocBuilder<{{Feature}}Cubit, {{Feature}}State>(
        builder: (context, state) {
          return state.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            success: (data) => data.isEmpty
                ? const NexoEmptyView(
                    title: 'No items',
                    subtitle: 'Nothing found.',
                  )
                : ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(data[index].toString()),
                    ),
                  ),
            error: (failure) => failure != null
                ? NexoFailureView(
                    failure: failure,
                    onRetry: () => context.read<{{Feature}}Cubit>().load(),
                  )
                : const Center(child: Text('Unknown error')),
          );
        },
      ),
    );
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Tests
// ──────────────────────────────────────────────────────────────────────────────

const _tplTest = r'''
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('{{featureSnake}} smoke', () {
    expect(true, isTrue);
  });
}
''';

const _tplMapperTest = r'''
import 'package:flutter_test/flutter_test.dart';

import 'package:{{packageName}}/features/{{featureSnake}}/data/models/{{featureSnake}}_model.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/data/mappers/{{featureSnake}}_mapper.dart';

void main() {
  group('{{Feature}}Mapper', () {
    test('toDomain maps model to entity', () {
      const model = {{Feature}}Model(id: '1');
      final entity = model.toDomain();
      expect(entity.id, '1');
    });
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Cubit test
// ──────────────────────────────────────────────────────────────────────────────

const _tplCubitTest = r'''
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nexo/nexo_errors.dart';

import 'package:{{packageName}}/features/{{featureSnake}}/domain/usecases/get_{{featureSnake}}_usecase.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/presentation/cubit/{{featureSnake}}_cubit.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/presentation/cubit/{{featureSnake}}_state.dart';

@GenerateMocks([Get{{Feature}}UseCase])
import '{{featureSnake}}_cubit_test.mocks.dart';

void main() {
  late {{Feature}}Cubit cubit;
  late MockGet{{Feature}}UseCase mockGetUseCase;

  setUp(() {
    mockGetUseCase = MockGet{{Feature}}UseCase();
    cubit = {{Feature}}Cubit(get{{Feature}}UseCase: mockGetUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('{{Feature}}Cubit', () {
    test('initial state is loading', () {
      expect(cubit.state, isA<{{Feature}}State>());
    });

    blocTest<{{Feature}}Cubit, {{Feature}}State>(
      'emits [loading, success] when load succeeds',
      build: () {
        when(mockGetUseCase(any)).thenAnswer(
          (_) async => Result.success(const []),
        );
        return cubit;
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<{{Feature}}State>(),
      ],
    );

    blocTest<{{Feature}}Cubit, {{Feature}}State>(
      'emits [loading, error] when load fails',
      build: () {
        when(mockGetUseCase(any)).thenAnswer(
          (_) async => Result.failure(const Failure.unknown(message: 'error')),
        );
        return cubit;
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<{{Feature}}State>(),
      ],
    );
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Bloc test
// ──────────────────────────────────────────────────────────────────────────────

const _tplBlocTest = r'''
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nexo/nexo_errors.dart';

import 'package:{{packageName}}/features/{{featureSnake}}/domain/usecases/get_{{featureSnake}}_usecase.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/presentation/bloc/{{featureSnake}}_bloc.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/presentation/bloc/{{featureSnake}}_event.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/presentation/bloc/{{featureSnake}}_state.dart';

@GenerateMocks([Get{{Feature}}UseCase])
import '{{featureSnake}}_bloc_test.mocks.dart';

void main() {
  late {{Feature}}Bloc bloc;
  late MockGet{{Feature}}UseCase mockGetUseCase;

  setUp(() {
    mockGetUseCase = MockGet{{Feature}}UseCase();
    bloc = {{Feature}}Bloc(get{{Feature}}UseCase: mockGetUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('{{Feature}}Bloc', () {
    test('initial state is loading', () {
      expect(bloc.state, isA<{{Feature}}State>());
    });

    blocTest<{{Feature}}Bloc, {{Feature}}State>(
      'emits [loading, success] on load event',
      build: () {
        when(mockGetUseCase(any)).thenAnswer(
          (_) async => Result.success(const []),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const {{Feature}}Event.load()),
      expect: () => [
        isA<{{Feature}}State>(),
      ],
    );

    blocTest<{{Feature}}Bloc, {{Feature}}State>(
      'emits [loading, error] when load fails',
      build: () {
        when(mockGetUseCase(any)).thenAnswer(
          (_) async => Result.failure(const Failure.unknown(message: 'error')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(const {{Feature}}Event.load()),
      expect: () => [
        isA<{{Feature}}State>(),
      ],
    );
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// UseCase test
// ──────────────────────────────────────────────────────────────────────────────

const _tplUseCaseTest = r'''
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nexo/nexo_core.dart';
import 'package:nexo/nexo_errors.dart';
import 'package:nexo/nexo_logger.dart';
import 'package:talker/talker.dart';

import 'package:{{packageName}}/features/{{featureSnake}}/domain/repositories/i_{{featureSnake}}_repository.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/domain/usecases/get_{{featureSnake}}_usecase.dart';

@GenerateMocks([I{{Feature}}Repository])
import 'get_{{featureSnake}}_usecase_test.mocks.dart';

void main() {
  late Get{{Feature}}UseCase useCase;
  late MockI{{Feature}}Repository mockRepository;

  setUp(() {
    mockRepository = MockI{{Feature}}Repository();
    useCase = Get{{Feature}}UseCase(
      TalkerLoggerAdapter(Talker()),
      repository: mockRepository,
    );
  });

  group('Get{{Feature}}UseCase', () {
    test('calls repository.getAll and returns result', () async {
      when(mockRepository.getAll()).thenAnswer((_) async => const []);

      final result = await useCase(const NoParams());

      expect(result, isA<Result<dynamic>>());
      verify(mockRepository.getAll()).called(1);
    });
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Repository test
// ──────────────────────────────────────────────────────────────────────────────

const _tplRepositoryTest = r'''
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:{{packageName}}/features/{{featureSnake}}/data/datasources/i_remote_{{featureSnake}}_data_source.dart';
import 'package:{{packageName}}/features/{{featureSnake}}/data/repositories/{{featureSnake}}_repository.dart';

@GenerateMocks([IRemote{{Feature}}DataSource])
import '{{featureSnake}}_repository_test.mocks.dart';

void main() {
  late {{Feature}}Repository repository;
  late MockIRemote{{Feature}}DataSource mockDataSource;

  setUp(() {
    mockDataSource = MockIRemote{{Feature}}DataSource();
    repository = {{Feature}}Repository(remoteDatasource: mockDataSource);
  });

  group('{{Feature}}Repository', () {
    test('getAll calls datasource and returns data', () async {
      when(mockDataSource.getAll()).thenAnswer((_) async => const []);

      final result = await repository.getAll();

      expect(result, isA<List<dynamic>>());
      verify(mockDataSource.getAll()).called(1);
    });
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Datasource test
// ──────────────────────────────────────────────────────────────────────────────

const _tplDatasourceTest = r'''
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('{{Feature}}DataSource', () {
    test('can be instantiated', () {
      // TODO(nexo): add datasource tests.
      expect(true, isTrue);
    });
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Admin CRUD Bloc
// ──────────────────────────────────────────────────────────────────────────────

const _tplAdminCrudBloc = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/{{featureSnake}}_repository.dart';

@injectable
class Admin{{Feature}}Bloc extends NexoAdminCrudBloc<{{Feature}}Dto> {
  Admin{{Feature}}Bloc({
    required {{Feature}}Repository repository,
    required String token,
  }) : super(repository: repository, token: token, path: '{{featureSnake}}');
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Admin CRUD State
// ──────────────────────────────────────────────────────────────────────────────

const _tplAdminCrudState = r'''
/// Состояние CRUD-операций для {{Feature}}.
///
/// Использует [NexoCrudState] с типом [{{Feature}}Dto].
typedef {{Feature}}CrudState = NexoCrudState<{{Feature}}Dto>;
''';

// ──────────────────────────────────────────────────────────────────────────────
// Admin CRUD Bloc Test
// ──────────────────────────────────────────────────────────────────────────────

const _tplAdminCrudBlocTest = r'''
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nexo/nexo_core.dart';

import '{{featureSnake}}_bloc.dart';

class Mock{{Feature}}Repository extends Mock
    implements {{Feature}}Repository {}

void main() {
  late Admin{{Feature}}Bloc bloc;
  late Mock{{Feature}}Repository mockRepository;

  setUp(() {
    mockRepository = Mock{{Feature}}Repository();
    bloc = Admin{{Feature}}Bloc(
      repository: mockRepository,
      token: 'test-token',
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('Admin{{Feature}}Bloc', () {
    test('initial state is loading', () {
      expect(bloc.state, isA<NexoCrudLoading>());
    });
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Paginated Bloc
// ──────────────────────────────────────────────────────────────────────────────

const _tplPaginatedBloc = r'''
import 'package:nexo/nexo_core.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/usecases/get_{{featureSnake}}_usecase.dart';
import '{{featureSnake}}_event.dart';
import '{{featureSnake}}_state.dart';

@injectable
class {{Feature}}Bloc extends NexoBloc<{{Feature}}Event, {{Feature}}State>
    with NexoPaginatedMixin<{{Feature}}Entity, String> {
  {{Feature}}Bloc({
    required this._get{{Feature}}UseCase,
  }) : super(const {{Feature}}State.loading()) {
    on<{{Feature}}Event>(_onEvent);
  }

  final Get{{Feature}}UseCase _get{{Feature}}UseCase;

  Future<void> _onEvent(
    {{Feature}}Event event,
    Emitter<{{Feature}}State> emit,
  ) async {
    await event.when(load: () => _onLoad(emit));
  }

  Future<void> _onLoad(Emitter<{{Feature}}State> emit) async {
    await loadMore(
      emit: emit,
      loader: (cursor) async {
        final result = await _get{{Feature}}UseCase(
          Get{{Feature}}Params(cursor: cursor),
        );
        return result.fold(
          onFailure: (f) => throw Exception(f.userMessage),
          onSuccess: (data) => PageChunk(
            items: data.items,
            nextCursor: data.nextCursor,
            hasMore: data.hasMore,
          ),
        );
      },
      onReady: (items, hasMore) => {{Feature}}State.ready(
        items: items,
        hasMore: hasMore,
      ),
    );
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Paginated Bloc Test
// ──────────────────────────────────────────────────────────────────────────────

const _tplPaginatedBlocTest = r'''
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nexo/nexo_core.dart';

import '{{featureSnake}}_bloc.dart';

class MockGet{{Feature}}UseCase extends Mock
    implements Get{{Feature}}UseCase {}

void main() {
  late {{Feature}}Bloc bloc;
  late MockGet{{Feature}}UseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGet{{Feature}}UseCase();
    bloc = {{Feature}}Bloc(get{{Feature}}UseCase: mockUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('{{Feature}}Bloc', () {
    test('initial state is loading', () {
      expect(bloc.state, isA<{{Feature}}State>());
    });
  });
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// @NexoUseCase generator
// ──────────────────────────────────────────────────────────────────────────────

const _tplUsecaseGen = r'''
import 'package:nexo/nexo_core.dart';
import '../entities/{{featureSnake}}_entity.dart';
import '../repositories/i_{{featureSnake}}_repository.dart';

class Get{{Feature}}Params {
  const Get{{Feature}}Params({this.cursor});
  final String? cursor;
}

@NexoUseCaseAnnotation()
abstract class Get{{Feature}}UseCase {
  Future<List<{{Feature}}Entity>> execute(Get{{Feature}}Params params);
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// @NexoUseCase test
// ──────────────────────────────────────────────────────────────────────────────

const _tplUsecaseGenTest = r'''
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('@NexoUseCase generator', () {
    test('generates valid use case', () {
      // TODO(nexo): add use case generator tests.
      expect(true, isTrue);
    });
  });
}
''';
