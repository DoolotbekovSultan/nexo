import 'package:nexo/packages/nexo_logger/nexo_logger.dart';
import 'package:talker/talker.dart';

/// Реализация [NexoLogger] на базе пакета `talker`.
///
/// Делегирует все вызовы экземпляру [Talker], переданному в конструктор.
/// Метод `error` использует `Talker.handle` для корректного отображения
/// стека вызовов и объекта ошибки.
///
/// ## Пример использования
///
/// ```dart
/// final talker = Talker();
/// final logger = TalkerLoggerAdapter(talker);
/// logger.info('Приложение запущено');
/// ```
class TalkerLoggerAdapter implements NexoLogger {
  /// Экземпляр [Talker], используемый для записи логов.
  final Talker talker;

  /// Создаёт адаптер, привязанный к указанному [talker].
  TalkerLoggerAdapter(this.talker);

  /// Логирует сообщение уровня debug.
  @override
  void debug(String message) => talker.debug(message);

  /// Логирует сообщение уровня info.
  @override
  void info(String message) => talker.info(message);

  /// Логирует предупреждение.
  @override
  void warning(String message) => talker.warning(message);

  /// Логирует ошибку с объектом ошибки и стеком вызовов.
  ///
  /// Использует `Talker.handle` для корректного отображения
  /// стека вызовов и объекта ошибки.
  @override
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  }) {
    talker.handle(error, stackTrace, message);
  }
}
