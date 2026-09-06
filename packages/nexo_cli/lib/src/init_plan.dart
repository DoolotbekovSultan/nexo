/// Options model and path planner for `nexo init`.
library;

/// Supported routing solutions.
enum RoutingType { none, autoRoute, goRouter }

/// Immutable configuration for the init command.
final class InitOptions {
  const InitOptions({
    required this.appName,
    required this.routing,
    required this.mockByDefault,
    required this.sentry,
    required this.overwrite,
    required this.dryRun,
  });

  /// App name used in `MaterialApp(title: ...)`.
  final String appName;

  /// Routing solution to scaffold.
  final RoutingType routing;

  /// Whether mock datasources are the default environment.
  final bool mockByDefault;

  /// Whether to add Sentry crash reporting.
  final bool sentry;

  /// Overwrite existing files.
  final bool overwrite;

  /// Print plan without writing files.
  final bool dryRun;

  bool get hasRouting => routing != RoutingType.none;
  bool get hasAutoRoute => routing == RoutingType.autoRoute;
  bool get hasGoRouter => routing == RoutingType.goRouter;
}

/// Pure path planner — no I/O.
///
/// Generates relative file paths that [InitCommand] will create.
abstract final class InitPlan {
  /// Returns relative paths for all files that [nexo init] will generate.
  static List<String> plannedPaths(InitOptions options) {
    return [
      'lib/main.dart',
      'lib/app.dart',
      'lib/core/config.dart',
      'lib/core/di/di.dart',
      'lib/core/di/modules/network_module.dart',
      'lib/core/di/modules/storage_module.dart',
      'lib/core/di/modules/logger_module.dart',
      'lib/core/network/auth_interceptor_bindings.dart',
      if (options.hasAutoRoute) ...[
        'lib/app/router/app_router.dart',
        'lib/app/navigation/auth_guard.dart',
        'lib/app/navigation/guest_guard.dart',
      ],
      if (options.hasGoRouter) 'lib/app/router/app_router.dart',
    ];
  }

  /// Returns relative paths for config files (created only if missing).
  static List<String> configPaths() => ['analysis_options.yaml', 'build.yaml'];
}
