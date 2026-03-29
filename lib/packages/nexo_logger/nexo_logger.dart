abstract class NexoLogger {
  void debug(String message);
  void info(String message);
  void warning(String message);
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  });
}
