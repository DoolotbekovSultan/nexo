import 'package:bloc/bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';
import 'package:nexo/packages/nexo_errors/nexo_crash_reporter.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

class NexoBlocObserver extends BlocObserver {
  final NexoLogger _logger;
  final NexoCrashReporter? _crashReporter;

  final bool logLifecycle;
  final bool logEvents;
  final bool logChanges;
  final bool logErrors;

  final int maxLogLength;

  /// Можно фильтровать конкретные Bloc/Cubit
  final bool Function(BlocBase bloc)? shouldLogBloc;

  NexoBlocObserver(
    this._logger, {
    NexoCrashReporter? crashReporter,
    this.logLifecycle = true,
    this.logEvents = true,
    this.logChanges = true,
    this.logErrors = true,
    this.maxLogLength = 1000,
    this.shouldLogBloc,
  }) : _crashReporter = crashReporter;

  String _blocName(BlocBase bloc) => bloc.runtimeType.toString();

  String _tag(BlocBase bloc, String message) {
    return '[${_blocName(bloc)}] $message';
  }

  bool _canLog(BlocBase bloc) {
    return shouldLogBloc?.call(bloc) ?? true;
  }

  void _safeLog(void Function() action) {
    try {
      action();
    } catch (_) {
      // логгер не должен ломать приложение
    }
  }

  String _limit(Object? value) {
    final text = value.toString();
    if (text.length <= maxLogLength) return text;
    return '${text.substring(0, maxLogLength)}... [truncated]';
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);

    if (!logLifecycle || !_canLog(bloc)) return;

    _safeLog(() {
      _logger.debug(_tag(bloc, 'Created'));
    });
  }

  @override
  void onClose(BlocBase bloc) {
    if (!logLifecycle || !_canLog(bloc)) {
      super.onClose(bloc);
      return;
    }

    _safeLog(() {
      _logger.debug(_tag(bloc, 'Closed'));
    });

    super.onClose(bloc);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    if (!logEvents || !_canLog(bloc)) {
      super.onEvent(bloc, event);
      return;
    }

    _safeLog(() {
      _logger.info(_tag(bloc, 'Event: ${_limit(event)}'));
    });

    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    if (!logChanges || !_canLog(bloc)) {
      super.onChange(bloc, change);
      return;
    }

    if (change.currentState == change.nextState) {
      super.onChange(bloc, change);
      return;
    }

    _safeLog(() {
      _logger.debug(
        _tag(
          bloc,
          'State: ${_limit(change.currentState)} → ${_limit(change.nextState)}',
        ),
      );
    });

    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (!logErrors || !_canLog(bloc)) {
      super.onError(bloc, error, stackTrace);
      return;
    }

    final failure = _toFailure(error, stackTrace);

    _safeLog(() {
      _logger.error(
        message: _tag(
          bloc,
          'Error [${failure.code}]: ${_limit(failure.userMessage)}',
        ),
        error: error,
        stackTrace: stackTrace,
      );
    });

    try {
      final reporter = _crashReporter;
      if (reporter != null) {
        if (error is Failure) {
          reporter.recordFailure(error, stackTrace: stackTrace);
        } else {
          reporter.recordError(error, stackTrace);
        }
      }
    } catch (_) {
      // репортёр не должен ломать BLoC
    }

    super.onError(bloc, error, stackTrace);
  }

  Failure _toFailure(Object error, StackTrace stackTrace) {
    if (error is Failure) return error;
    return error.toFailure(stackTrace);
  }
}
