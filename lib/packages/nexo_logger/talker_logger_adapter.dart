import 'package:nexo/packages/nexo_logger/nexo_logger.dart';
import 'package:talker/talker.dart';

class TalkerLoggerAdapter implements NexoLogger {
  final Talker talker;

  TalkerLoggerAdapter(this.talker);

  @override
  void debug(String message) => talker.debug(message);

  @override
  void info(String message) => talker.info(message);

  @override
  void warning(String message) => talker.warning(message);

  @override
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  }) {
    talker.handle(error, stackTrace, message);
  }
}
