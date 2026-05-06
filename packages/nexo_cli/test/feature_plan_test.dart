import 'package:nexo_cli/src/feature_plan.dart';
import 'package:nexo_cli/src/name_utils.dart';
import 'package:test/test.dart';

void main() {
  group('FeaturePlan.validatePresentation', () {
    test('null when bloc only', () {
      expect(
        FeaturePlan.validatePresentation(bloc: true, cubit: false),
        isNull,
      );
    });

    test('null when cubit only', () {
      expect(
        FeaturePlan.validatePresentation(bloc: false, cubit: true),
        isNull,
      );
    });

    test('error when both', () {
      expect(
        FeaturePlan.validatePresentation(bloc: true, cubit: true),
        'Choose either --bloc or --cubit, not both',
      );
    });

    test('error when neither', () {
      expect(
        FeaturePlan.validatePresentation(bloc: false, cubit: false),
        'Either --bloc or --cubit must be enabled',
      );
    });
  });

  group('FeaturePlan.plannedLibPaths', () {
    final names = NameUtils.fromFeatureInput('auth');

    test('default-like: bloc, remote, no local/ui', () {
      const o = FeatureOptions(
        bloc: true,
        cubit: false,
        local: false,
        ui: false,
        tests: false,
        dryRun: false,
        overwrite: false,
      );
      expect(FeaturePlan.plannedLibPaths(names, o), [
        'data/datasources/auth_remote_datasource.dart',
        'data/repositories/auth_repository_impl.dart',
        'domain/entities/auth_entity.dart',
        'domain/repositories/auth_repository.dart',
        'domain/usecases/get_auth_usecase.dart',
        'presentation/bloc/auth_bloc.dart',
        'presentation/bloc/auth_event.dart',
        'presentation/bloc/auth_state.dart',
      ]);
    });

    test('cubit layout', () {
      const o = FeatureOptions(
        bloc: false,
        cubit: true,
        local: false,
        ui: false,
        tests: false,
        dryRun: false,
        overwrite: false,
      );
      final paths = FeaturePlan.plannedLibPaths(names, o);
      expect(
        paths,
        containsAll([
          'presentation/cubit/auth_cubit.dart',
          'presentation/cubit/auth_state.dart',
        ]),
      );
      expect(paths.where((p) => p.contains('bloc')), isEmpty);
    });

    test('local and ui', () {
      const o = FeatureOptions(
        bloc: true,
        cubit: false,
        local: true,
        ui: true,
        tests: false,
        dryRun: false,
        overwrite: false,
      );
      expect(
        FeaturePlan.plannedLibPaths(names, o),
        containsAll([
          'data/datasources/auth_local_datasource.dart',
          'presentation/pages/auth_page.dart',
          'presentation/widgets/auth_widget.dart',
        ]),
      );
    });
  });

  group('FeaturePlan.plannedTestPaths', () {
    final names = NameUtils.fromFeatureInput('auth');

    test('empty without --tests', () {
      const o = FeatureOptions(
        bloc: true,
        cubit: false,
        local: true,
        ui: true,
        tests: false,
        dryRun: false,
        overwrite: false,
      );
      expect(FeaturePlan.plannedTestPaths(names, o), isEmpty);
    });

    test('bloc tests when tests + bloc', () {
      const o = FeatureOptions(
        bloc: true,
        cubit: false,
        local: false,
        ui: false,
        tests: true,
        dryRun: false,
        overwrite: false,
      );
      expect(FeaturePlan.plannedTestPaths(names, o), [
        'data/auth_repository_impl_test.dart',
        'domain/get_auth_usecase_test.dart',
        'presentation/auth_bloc_test.dart',
      ]);
    });

    test('cubit test when tests + cubit', () {
      const o = FeatureOptions(
        bloc: false,
        cubit: true,
        local: false,
        ui: false,
        tests: true,
        dryRun: false,
        overwrite: false,
      );
      expect(
        FeaturePlan.plannedTestPaths(names, o),
        contains('presentation/auth_cubit_test.dart'),
      );
    });

    test('local datasource test when tests + local', () {
      const o = FeatureOptions(
        bloc: true,
        cubit: false,
        local: true,
        ui: false,
        tests: true,
        dryRun: false,
        overwrite: false,
      );
      expect(
        FeaturePlan.plannedTestPaths(names, o),
        contains('data/auth_local_datasource_test.dart'),
      );
    });

    test('ui tests when tests + ui', () {
      const o = FeatureOptions(
        bloc: true,
        cubit: false,
        local: false,
        ui: true,
        tests: true,
        dryRun: false,
        overwrite: false,
      );
      expect(
        FeaturePlan.plannedTestPaths(names, o),
        containsAll([
          'presentation/pages/auth_page_test.dart',
          'presentation/widgets/auth_widget_test.dart',
        ]),
      );
    });
  });
}
