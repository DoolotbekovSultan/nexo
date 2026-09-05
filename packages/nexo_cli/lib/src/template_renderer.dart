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
    FeatureOptions options,
  ) {
    final norm = relativePosixPath.replaceAll(r'\', '/');
    final template = _pickTemplate(norm, options);
    return _substitute(template, names, options);
  }

  static String _pickTemplate(String norm, FeatureOptions options) {
    // ── Tests ──
    if (norm.endsWith('_test.dart')) {
      if (norm.contains('mapper')) return _tplMapperTest;
      return _tplTest;
    }

    // ── Preferences ──
    if (norm.endsWith('_preferences.dart')) return _tplPreferences;

    // ── Extensions ──
    if (norm.endsWith('_extensions.dart')) return _tplExtensions;

    // ── Screen (presentation-only) ──
    if (norm.endsWith('_screen.dart')) return _tplScreen;

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
      return options.isList ? _tplRemoteDatasource : _tplRemoteDatasourceSingle;
    }
    if (norm.endsWith('_local_datasource.dart')) {
      return options.isList ? _tplLocalDatasource : _tplLocalDatasourceSingle;
    }

    // ── Mappers ──
    if (norm.contains('mappers/') && norm.endsWith('_mapper.dart')) {
      return _tplMapper;
    }

    // ── Repository interface (domain) ──
    if (norm.contains('domain/repositories/') &&
        norm.startsWith('domain/repositories/i_')) {
      return _tplRepositoryInterface;
    }

    // ── Repository impl (data) ──
    if (norm.contains('data/repositories/') &&
        norm.endsWith('_repository.dart')) {
      if (!options.injectable) return _tplRepositoryImplNoInjectable;
      return _tplRepositoryImpl;
    }

    // ── UseCase (get) ──
    if (norm.contains('domain/usecases/') &&
        norm.startsWith('domain/usecases/get_')) {
      return _tplUseCase;
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
      return _tplCreateParams;
    }
    if (norm.contains('domain/parameters/') &&
        norm.startsWith('domain/parameters/update_')) {
      return _tplUpdateParams;
    }

    // ── Bloc ──
    if (norm.contains('presentation/bloc/') && norm.endsWith('_event.dart')) {
      return _tplBlocEvent;
    }
    if (norm.contains('presentation/bloc/') && norm.endsWith('_bloc.dart')) {
      return _tplBloc;
    }

    // ── Cubit ──
    if (norm.contains('presentation/cubit/') && norm.endsWith('_cubit.dart')) {
      if (options.hasListCubit) return _tplListCubit;
      if (!options.freezed) return _tplCubitNoFreezed;
      return _tplCubit;
    }

    // ── State ──
    if (norm.endsWith('_state.dart') &&
        (norm.contains('presentation/bloc/') ||
            norm.contains('presentation/cubit/'))) {
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
    FeatureOptions options,
  ) {
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

    // First: substitute generated content blocks.
    var result = template
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
        .replaceAll('{{feature}}', _snakeToLowerCamel(names.snakeCase));

    return result;
  }

  // ── JSON field generators ────────────────────────────────────────────────

  static String _generateFieldsDecl(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) return '  final String id;';
    return fields.entries.map((e) => '  final ${e.value} ${e.key};').join('\n');
  }

  static String _generateFieldsCtorParams(Map<String, String>? fields) {
    if (fields == null || fields.isEmpty) return '    String id,';
    return fields.entries.map((e) => '    ${e.value} ${e.key},').join('\n');
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
    if (fields == null || fields.isEmpty) return '    String id,';
    return fields.entries.map((e) => '    ${e.value} ${e.key},').join('\n');
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
    if (fields == null || fields.isEmpty) return '    String id,';
    return fields.entries.map((e) => '    ${e.value} ${e.key},').join('\n');
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
    if (data is! List) return const [];
    return List.from(data)
        .whereType<Map<String, dynamic>>()
        .map({{Feature}}Model.fromJson)
        .toList();
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

// TODO(nexo): add @LazySingleton(as: ILocal{{Feature}}DataSource) if using DI.
// If you have multiple implementations (mock + prod), add env: parameter.
// Consider extending BaseSharedPreferencesDataSource, BaseHiveDataSource, etc.
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

// TODO(nexo): add @LazySingleton(as: ILocal{{Feature}}DataSource) if using DI.
// If you have multiple implementations (mock + prod), add env: parameter.
// Consider extending BaseSharedPreferencesDataSource, BaseHiveDataSource, etc.
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
// Mock remote datasource
// ──────────────────────────────────────────────────────────────────────────────

const _tplMockRemoteDatasource = r'''
import 'package:injectable/injectable.dart';

import 'i_remote_{{featureSnake}}_data_source.dart';
import '../models/{{featureSnake}}_model.dart';

// TODO(nexo): add env: [AppEnvironment.mock] if using environment-based DI.
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

// TODO(nexo): add env: [AppEnvironment.mock] if using environment-based DI.
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

// TODO(nexo): add env: [AppEnvironment.mock] if using environment-based DI.
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
import '../entities/{{featureSnake}}_entity.dart';

abstract interface class I{{Feature}}Repository {
  Future<{{retType}}> getAll();
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

@LazySingleton(as: I{{Feature}}Repository)
class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({required this._remoteDatasource});

  final IRemote{{Feature}}DataSource _remoteDatasource;

  @override
  Future<{{retType}}> getAll() async {
    final models = await _remoteDatasource.getAll();
    return models.toDomain();
  }
}
''';

const _tplRepositoryImplNoInjectable = r'''
import '../../domain/entities/{{featureSnake}}_entity.dart';
import '../../domain/repositories/i_{{featureSnake}}_repository.dart';
import '../datasources/{{featureSnake}}_remote_datasource.dart';

class {{Feature}}Repository implements I{{Feature}}Repository {
  {{Feature}}Repository({required this._remoteDatasource});

  final {{Feature}}RemoteDataSource _remoteDatasource;

  @override
  Future<{{retType}}> getAll() async {
    final models = await _remoteDatasource.getAll();
    return models.toDomain();
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
    throw UnimplementedError();
  }
}
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }
}

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
    throw UnimplementedError();
  }
}

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
    throw UnimplementedError();
  }
}
''';

// ──────────────────────────────────────────────────────────────────────────────
// Parameters
// ──────────────────────────────────────────────────────────────────────────────

const _tplCreateParams = r'''
class Create{{Feature}}Params {
  const Create{{Feature}}Params({required this.id});
  final String id;
}
''';

const _tplUpdateParams = r'''
class Update{{Feature}}Params {
  const Update{{Feature}}Params({required this.id});
  final String id;
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

import 'package:{{featureSnake}}/data/models/{{featureSnake}}_model.dart';
import 'package:{{featureSnake}}/data/mappers/{{featureSnake}}_mapper.dart';

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
