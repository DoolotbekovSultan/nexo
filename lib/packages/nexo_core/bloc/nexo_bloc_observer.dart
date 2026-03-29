import 'package:bloc/bloc.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

class NexoBlocObserver extends BlocObserver {
  final NexoLogger _logger;

  NexoBlocObserver(this._logger);

  String _blocName(BlocBase bloc) => bloc.runtimeType.toString();

  String _tag(BlocBase bloc, String message) {
    return '[${_blocName(bloc)}] $message';
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.debug(_tag(bloc, 'Created'));
  }

  @override
  void onClose(BlocBase bloc) {
    _logger.debug(_tag(bloc, 'Closed'));
    super.onClose(bloc);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    _logger.info(_tag(bloc, 'Event: $event'));
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    if (change.currentState == change.nextState) {
      super.onChange(bloc, change);
      return;
    }

    _logger.debug(
      _tag(bloc, 'State: ${change.currentState} → ${change.nextState}'),
    );

    super.onChange(bloc, change);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    final failure = _toFailure(error, stackTrace);

    _logger.error(
      message: _tag(bloc, 'Error: ${failure.userMessage}'),
      error: error,
      stackTrace: stackTrace,
    );

    super.onError(bloc, error, stackTrace);
  }

  Failure _toFailure(Object error, StackTrace stackTrace) {
    if (error is Failure) return error;
    return error.toFailure(stackTrace);
  }
}
