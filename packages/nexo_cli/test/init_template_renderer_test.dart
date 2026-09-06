import 'package:nexo_cli/src/init_plan.dart';
import 'package:nexo_cli/src/init_template_renderer.dart';
import 'package:test/test.dart';

void main() {
  const defaultOptions = InitOptions(
    appName: 'MyApp',
    routing: RoutingType.none,
    mockByDefault: true,
    sentry: false,
    overwrite: false,
    dryRun: true,
  );

  group('InitTemplateRenderer.render', () {
    test('main.dart contains NexoFlutterErrors.runAppInZone', () {
      final result = InitTemplateRenderer.render(
        'lib/main.dart',
        defaultOptions,
      );
      expect(result, contains('NexoFlutterErrors.runAppInZone'));
      expect(result, contains('configureDependencies'));
      expect(result, contains('NexoFlutterErrors.install'));
      expect(result, contains('NexoBlocObserver'));
      expect(result, contains('runApp'));
    });

    test('main.dart uses appName', () {
      const options = InitOptions(
        appName: 'CoolApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      final result = InitTemplateRenderer.render('lib/main.dart', options);
      expect(result, contains('CoolAppApp()'));
    });

    test('main.dart includes sentry import when sentry is enabled', () {
      const options = InitOptions(
        appName: 'MyApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: true,
        overwrite: false,
        dryRun: true,
      );
      final result = InitTemplateRenderer.render('lib/main.dart', options);
      expect(result, contains('sentry_flutter'));
    });

    test('main.dart excludes sentry import when sentry is disabled', () {
      final result = InitTemplateRenderer.render(
        'lib/main.dart',
        defaultOptions,
      );
      expect(result, isNot(contains('sentry_flutter')));
    });

    test('app.dart contains MaterialApp', () {
      final result = InitTemplateRenderer.render(
        'lib/app.dart',
        defaultOptions,
      );
      expect(result, contains('MaterialApp'));
      expect(result, contains('MyApp'));
    });

    test('config.dart contains AppEnvironment', () {
      final result = InitTemplateRenderer.render(
        'lib/core/config.dart',
        defaultOptions,
      );
      expect(result, contains('AppEnvironment'));
      expect(result, contains('kUseMock'));
      expect(result, contains('kApiBaseUrl'));
    });

    test('config.dart includes sentryDsn when sentry is enabled', () {
      const options = InitOptions(
        appName: 'MyApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: true,
        overwrite: false,
        dryRun: true,
      );
      final result = InitTemplateRenderer.render(
        'lib/core/config.dart',
        options,
      );
      expect(result, contains('kSentryDsn'));
    });

    test('di.dart contains getIt and InjectableInit', () {
      final result = InitTemplateRenderer.render(
        'lib/core/di/di.dart',
        defaultOptions,
      );
      expect(result, contains('GetIt'));
      expect(result, contains('@InjectableInit'));
      expect(result, contains('configureDependencies'));
    });

    test('network_module.dart contains Dio and interceptors', () {
      final result = InitTemplateRenderer.render(
        'lib/core/di/modules/network_module.dart',
        defaultOptions,
      );
      expect(result, contains('Dio'));
      expect(result, contains('DioClient'));
      expect(result, contains('NexoAuthInterceptor'));
      expect(result, contains('NexoLoggingInterceptor'));
      expect(result, contains('NexoRequestIdInterceptor'));
      expect(result, contains('AuthInterceptorBindings'));
      expect(result, contains('@module'));
      expect(result, contains('@lazySingleton'));
    });

    test(
      'storage_module.dart contains SharedPreferences and SecureStorage',
      () {
        final result = InitTemplateRenderer.render(
          'lib/core/di/modules/storage_module.dart',
          defaultOptions,
        );
        expect(result, contains('SharedPreferences'));
        expect(result, contains('FlutterSecureStorage'));
        expect(result, contains('@preResolve'));
        expect(result, contains('@module'));
      },
    );

    test('logger_module.dart contains Talker and NexoLogger', () {
      final result = InitTemplateRenderer.render(
        'lib/core/di/modules/logger_module.dart',
        defaultOptions,
      );
      expect(result, contains('Talker'));
      expect(result, contains('TalkerLoggerAdapter'));
      expect(result, contains('NexoLogger'));
      expect(result, contains('NexoCrashReporter'));
      expect(result, contains('NoOpNexoCrashReporter'));
      expect(result, contains('@module'));
    });

    test('auth_interceptor_bindings.dart contains token methods', () {
      final result = InitTemplateRenderer.render(
        'lib/core/network/auth_interceptor_bindings.dart',
        defaultOptions,
      );
      expect(result, contains('getAccessToken'));
      expect(result, contains('refreshAccessToken'));
      expect(result, contains('onTokenExpired'));
      expect(result, contains('saveTokens'));
      expect(result, contains('clearTokens'));
      expect(result, contains('@lazySingleton'));
    });

    group('routing templates', () {
      test('auto_route router contains @AutoRouterConfig', () {
        const options = InitOptions(
          appName: 'MyApp',
          routing: RoutingType.autoRoute,
          mockByDefault: true,
          sentry: false,
          overwrite: false,
          dryRun: true,
        );
        final result = InitTemplateRenderer.render(
          'lib/app/router/app_router.dart',
          options,
        );
        expect(result, contains('@AutoRouterConfig'));
        expect(result, contains('RootStackRouter'));
        expect(result, contains('AuthGuard'));
        expect(result, contains('GuestGuard'));
        expect(result, contains('@singleton'));
      });

      test('go_router contains GoRouter', () {
        const options = InitOptions(
          appName: 'MyApp',
          routing: RoutingType.goRouter,
          mockByDefault: true,
          sentry: false,
          overwrite: false,
          dryRun: true,
        );
        final result = InitTemplateRenderer.render(
          'lib/app/router/app_router.dart',
          options,
        );
        expect(result, contains('GoRouter'));
        expect(result, contains('initialLocation'));
        expect(result, contains('GoRoute'));
      });

      test('auth_guard.dart contains AutoRouteGuard', () {
        const options = InitOptions(
          appName: 'MyApp',
          routing: RoutingType.autoRoute,
          mockByDefault: true,
          sentry: false,
          overwrite: false,
          dryRun: true,
        );
        final result = InitTemplateRenderer.render(
          'lib/app/navigation/auth_guard.dart',
          options,
        );
        expect(result, contains('AutoRouteGuard'));
        expect(result, contains('@singleton'));
      });

      test('guest_guard.dart contains AutoRouteGuard', () {
        const options = InitOptions(
          appName: 'MyApp',
          routing: RoutingType.autoRoute,
          mockByDefault: true,
          sentry: false,
          overwrite: false,
          dryRun: true,
        );
        final result = InitTemplateRenderer.render(
          'lib/app/navigation/guest_guard.dart',
          options,
        );
        expect(result, contains('AutoRouteGuard'));
        expect(result, contains('@singleton'));
      });
    });

    test('unknown path returns fallback template', () {
      final result = InitTemplateRenderer.render(
        'lib/unknown_file.dart',
        defaultOptions,
      );
      expect(result, contains('Placeholder generated by nexo_cli init'));
    });
  });

  group('InitTemplateRenderer substitution', () {
    test('appName is substituted in all templates', () {
      const options = InitOptions(
        appName: 'SuperApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      final main = InitTemplateRenderer.render('lib/main.dart', options);
      expect(main, contains('SuperApp'));

      final app = InitTemplateRenderer.render('lib/app.dart', options);
      expect(app, contains('SuperApp'));
    });

    test('mock env is reflected in config', () {
      const mockOptions = InitOptions(
        appName: 'MyApp',
        routing: RoutingType.none,
        mockByDefault: true,
        sentry: false,
        overwrite: false,
        dryRun: true,
      );
      final result = InitTemplateRenderer.render(
        'lib/core/config.dart',
        mockOptions,
      );
      expect(result, contains('mock'));
    });
  });
}
