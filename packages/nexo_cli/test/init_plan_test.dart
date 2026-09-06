import 'package:nexo_cli/src/init_plan.dart';
import 'package:test/test.dart';

void main() {
  group('InitOptions', () {
    test('hasRouting is false when routing is none', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      expect(options.hasRouting, isFalse);
    });

    test('hasAutoRoute is true when routing is autoRoute', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.autoRoute,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      expect(options.hasAutoRoute, isTrue);
      expect(options.hasGoRouter, isFalse);
      expect(options.hasRouting, isTrue);
    });

    test('hasGoRouter is true when routing is goRouter', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.goRouter,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      expect(options.hasGoRouter, isTrue);
      expect(options.hasAutoRoute, isFalse);
      expect(options.hasRouting, isTrue);
    });
  });

  group('InitPlan.plannedPaths', () {
    test('base paths without routing', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      final paths = InitPlan.plannedPaths(options);
      expect(paths, contains('lib/main.dart'));
      expect(paths, contains('lib/app.dart'));
      expect(paths, contains('lib/core/config.dart'));
      expect(paths, contains('lib/core/di/di.dart'));
      expect(paths, contains('lib/core/di/modules/network_module.dart'));
      expect(paths, contains('lib/core/di/modules/storage_module.dart'));
      expect(paths, contains('lib/core/di/modules/logger_module.dart'));
      expect(
        paths,
        contains('lib/core/network/auth_interceptor_bindings.dart'),
      );
    });

    test('includes auto_route files when routing is autoRoute', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.autoRoute,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      final paths = InitPlan.plannedPaths(options);
      expect(paths, contains('lib/app/router/app_router.dart'));
      expect(paths, contains('lib/app/navigation/auth_guard.dart'));
      expect(paths, contains('lib/app/navigation/guest_guard.dart'));
    });

    test('includes go_router file when routing is goRouter', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.goRouter,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      final paths = InitPlan.plannedPaths(options);
      expect(paths, contains('lib/app/router/app_router.dart'));
      expect(paths, isNot(contains('lib/app/navigation/auth_guard.dart')));
      expect(paths, isNot(contains('lib/app/navigation/guest_guard.dart')));
    });

    test('excludes navigation guards when routing is none', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      final paths = InitPlan.plannedPaths(options);
      expect(paths, isNot(contains('lib/app/router/app_router.dart')));
      expect(paths, isNot(contains('lib/app/navigation/auth_guard.dart')));
      expect(paths, isNot(contains('lib/app/navigation/guest_guard.dart')));
    });

    test('base paths count is 8 without routing', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      expect(InitPlan.plannedPaths(options), hasLength(8));
    });

    test('auto_route adds 3 files (total 11)', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.autoRoute,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      expect(InitPlan.plannedPaths(options), hasLength(11));
    });

    test('go_router adds 1 file (total 9)', () {
      const options = InitOptions(
        appName: 'TestApp',
        routing: RoutingType.goRouter,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      expect(InitPlan.plannedPaths(options), hasLength(9));
    });
  });

  group('InitPlan.configPaths', () {
    test('returns analysis_options.yaml and build.yaml', () {
      final paths = InitPlan.configPaths();
      expect(paths, contains('analysis_options.yaml'));
      expect(paths, contains('build.yaml'));
      expect(paths, hasLength(2));
    });
  });
}
