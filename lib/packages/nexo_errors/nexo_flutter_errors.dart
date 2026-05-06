import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/nexo_crash_reporter.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Глобальная регистрация обработчиков ошибок Flutter (без UI).
///
/// После [install] перехватываются:
/// - [FlutterError.onError] (ошибки рендеринга и assert в debug);
/// - [PlatformDispatcher.instance.onError] (непойманные async-ошибки).
///
/// Дополнительно используйте [runAppInZone], чтобы ловить ошибки в зоне.
///
/// **Важно:** [WidgetsFlutterBinding.ensureInitialized] и [runApp] должны
/// вызываться в **одной** зоне. Оберните весь `main` (включая `ensureInitialized`,
/// DI и `runApp`) в тело [runAppInZone], либо не используйте зону вокруг `runApp`.
class NexoFlutterErrors {
  NexoFlutterErrors._();

  static NexoLogger? _logger;
  static NexoCrashReporter? _crashReporter;
  static FlutterExceptionHandler? _previousFlutterOnError;
  static bool Function(Object error, StackTrace stack)? _previousPlatformOnError;
  static bool _installed = false;

  /// Подключает глобальные хендлеры. Вызывайте один раз после
  /// [WidgetsFlutterBinding.ensureInitialized] **в той же зоне**, что и [runApp]
  /// (см. [runAppInZone]).
  static void install({
    required NexoLogger logger,
    NexoCrashReporter? crashReporter,
  }) {
    assert(!_installed, 'NexoFlutterErrors.install: already installed');
    _installed = true;
    _logger = logger;
    _crashReporter = crashReporter;

    _previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      _report(details.exception, details.stack ?? StackTrace.current);
      final prev = _previousFlutterOnError;
      if (prev != null) {
        prev(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    _previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _report(error, stack);
      final prev = _previousPlatformOnError;
      if (prev != null) {
        return prev(error, stack);
      }
      return false;
    };
  }

  /// Снимает хендлеры (удобно в тестах).
  static void uninstall() {
    if (!_installed) return;
    FlutterError.onError = _previousFlutterOnError;
    PlatformDispatcher.instance.onError = _previousPlatformOnError;
    _installed = false;
    _logger = null;
    _crashReporter = null;
    _previousFlutterOnError = null;
    _previousPlatformOnError = null;
  }

  /// Оборачивает [body] в [runZonedGuarded] с отчётом в лог и [NexoCrashReporter].
  ///
  /// Первой строкой в [body] обычно вызывают [WidgetsFlutterBinding.ensureInitialized],
  /// затем DI, [install], и в конце — [runApp].
  ///
  /// Ошибки из самого [body] перехватываются и отчитываются (без повторного выброса),
  /// чтобы [Future] завершался; второй канал — необработанные ошибки в зоне.
  static Future<void> runAppInZone(Future<void> Function() body) async {
    await runZonedGuarded(
      () async {
        try {
          await body();
        } catch (e, s) {
          _report(e, s);
        }
      },
      (Object error, StackTrace stack) {
        _report(error, stack);
      },
    );
  }

  static void _report(Object error, StackTrace stack) {
    try {
      _logger?.error(
        message: 'Uncaught error',
        error: error,
        stackTrace: stack,
      );
    } catch (_) {
      // логгер не должен ломать цепочку
    }
    try {
      final reporter = _crashReporter;
      if (reporter == null) return;
      if (error is Failure) {
        reporter.recordFailure(error, stackTrace: stack);
      } else {
        reporter.recordError(error, stack);
      }
    } catch (_) {
      // репортёр не должен ломать приложение
    }
  }
}
