import 'package:nexo_cli/src/feature_plan.dart';
import 'package:nexo_cli/src/name_utils.dart';
import 'package:test/test.dart';

void main() {
  group('FeaturePlan.validatePresentation', () {
    test('null when cubit only', () {
      expect(
        FeaturePlan.validatePresentation(
          style: PresentationStyle.cubit,
          presentationOnly: false,
        ),
        isNull,
      );
    });

    test('null when bloc only', () {
      expect(
        FeaturePlan.validatePresentation(
          style: PresentationStyle.bloc,
          presentationOnly: false,
        ),
        isNull,
      );
    });

    test('null when list-cubit only', () {
      expect(
        FeaturePlan.validatePresentation(
          style: PresentationStyle.listCubit,
          presentationOnly: false,
        ),
        isNull,
      );
    });

    test('null when none with presentation-only', () {
      expect(
        FeaturePlan.validatePresentation(
          style: PresentationStyle.none,
          presentationOnly: true,
        ),
        isNull,
      );
    });

    test('error when presentation-only with bloc', () {
      expect(
        FeaturePlan.validatePresentation(
          style: PresentationStyle.bloc,
          presentationOnly: true,
        ),
        contains('presentation-only'),
      );
    });

    test('error when presentation-only with cubit', () {
      expect(
        FeaturePlan.validatePresentation(
          style: PresentationStyle.cubit,
          presentationOnly: true,
        ),
        contains('presentation-only'),
      );
    });
  });

  group('FeaturePlan.plannedLibPaths', () {
    final names = NameUtils.fromFeatureInput('auth');

    test('clean architecture: cubit, freezed, injectable, mapper, mock', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        containsAll([
          'data/datasources/i_remote_auth_data_source.dart',
          'data/datasources/auth_remote_datasource.dart',
          'data/datasources/mock_auth_remote_data_source.dart',
          'data/models/auth_model.dart',
          'data/mappers/auth_mapper.dart',
          'data/repositories/auth_repository.dart',
          'domain/entities/auth_entity.dart',
          'domain/repositories/i_auth_repository.dart',
          'domain/usecases/get_auth_usecase.dart',
          'presentation/cubit/auth_cubit.dart',
          'presentation/cubit/auth_state.dart',
          'presentation/auth_screen.dart',
        ]),
      );
    });

    test('bloc style', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.bloc,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        containsAll([
          'presentation/bloc/auth_bloc.dart',
          'presentation/bloc/auth_event.dart',
          'presentation/bloc/auth_state.dart',
        ]),
      );
      expect(paths.where((p) => p.contains('cubit')), isEmpty);
    });

    test('list-cubit style', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.listCubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        containsAll([
          'presentation/cubit/auth_cubit.dart',
          'presentation/cubit/auth_state.dart',
        ]),
      );
    });

    test('local + mock + create/update CRUD', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: true,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get', 'create', 'update', 'delete'},
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        containsAll([
          'data/datasources/i_local_auth_data_source.dart',
          'data/datasources/auth_local_datasource.dart',
          'data/datasources/mock_auth_local_data_source.dart',
          'data/models/requests/create_auth_request.dart',
          'data/models/requests/update_auth_request.dart',
          'domain/usecases/auth_usecases.dart',
          'domain/parameters/create_auth_params.dart',
          'domain/parameters/update_auth_params.dart',
        ]),
      );
    });

    test('presentation-only with preferences', () {
      const o = FeatureOptions(
        presentationOnly: true,
        presentationStyle: PresentationStyle.none,
        freezed: false,
        injectable: false,
        mapper: false,
        mock: false,
        local: false,
        preferences: true,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        containsAll([
          'data/auth_preferences.dart',
          'presentation/auth_screen.dart',
        ]),
      );
      expect(paths.where((p) => p.contains('domain')), isEmpty);
      expect(paths.where((p) => p.contains('data/datasources')), isEmpty);
    });

    test('presentation-only with ui', () {
      const o = FeatureOptions(
        presentationOnly: true,
        presentationStyle: PresentationStyle.none,
        freezed: false,
        injectable: false,
        mapper: false,
        mock: false,
        local: false,
        preferences: false,
        ui: true,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        containsAll([
          'presentation/auth_screen.dart',
          'presentation/pages/auth_page.dart',
          'presentation/widgets/auth_widget.dart',
        ]),
      );
    });

    test('extensions flag', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: true,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(paths, contains('domain/entities/auth_extensions.dart'));
    });

    test('no freezed, no injectable, no mapper, no mock', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: false,
        injectable: false,
        mapper: false,
        mock: false,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        isNot(contains('data/datasources/i_remote_auth_data_source.dart')),
      );
      expect(
        paths,
        isNot(contains('data/datasources/mock_auth_remote_data_source.dart')),
      );
      expect(paths, isNot(contains('data/mappers/auth_mapper.dart')));
      expect(paths, contains('data/datasources/auth_remote_datasource.dart'));
      expect(paths, contains('data/models/auth_model.dart'));
    });

    test('single object (isList: false)', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
        isList: false,
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(paths, contains('domain/usecases/get_auth_usecase.dart'));
    });

    test('only create + update (no get)', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'create', 'update'},
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(paths, isNot(contains('domain/usecases/get_auth_usecase.dart')));
      expect(paths, contains('domain/usecases/auth_usecases.dart'));
      expect(paths, contains('data/models/requests/create_auth_request.dart'));
      expect(paths, contains('data/models/requests/update_auth_request.dart'));
    });
  });

  group('FeaturePlan.plannedTestPaths', () {
    final names = NameUtils.fromFeatureInput('auth');

    test('empty without --tests', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: false,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      expect(FeaturePlan.plannedTestPaths(names, o), isEmpty);
    });

    test('clean architecture tests', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: true,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      expect(
        FeaturePlan.plannedTestPaths(names, o),
        containsAll([
          'data/auth_repository_test.dart',
          'domain/get_auth_usecase_test.dart',
          'presentation/auth_cubit_test.dart',
        ]),
      );
    });

    test('bloc tests', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.bloc,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: true,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      expect(
        FeaturePlan.plannedTestPaths(names, o),
        contains('presentation/auth_bloc_test.dart'),
      );
    });

    test('mapper test', () {
      const o = FeatureOptions(
        presentationOnly: false,
        presentationStyle: PresentationStyle.cubit,
        freezed: true,
        injectable: true,
        mapper: true,
        mock: true,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: true,
        dryRun: false,
        overwrite: false,
        crudOperations: {'get'},
      );
      expect(
        FeaturePlan.plannedTestPaths(names, o),
        contains('data/mappers/auth_mapper_test.dart'),
      );
    });

    test('presentation-only tests', () {
      const o = FeatureOptions(
        presentationOnly: true,
        presentationStyle: PresentationStyle.none,
        freezed: false,
        injectable: false,
        mapper: false,
        mock: false,
        local: false,
        preferences: false,
        ui: false,
        extensions: false,
        tests: true,
        dryRun: false,
        overwrite: false,
      );
      expect(FeaturePlan.plannedTestPaths(names, o), isEmpty);
    });
  });

  group('parseJsonToFields', () {
    test('parses simple JSON', () {
      final fields = parseJsonToFields('{"id": "String", "count": 42}');
      expect(fields, {'id': 'String', 'count': 'int'});
    });

    test('parses nested JSON', () {
      final fields = parseJsonToFields(
        '{"name": "test", "active": true, "score": 3.14}',
      );
      expect(fields, {'name': 'String', 'active': 'bool', 'score': 'double'});
    });
  });
}
