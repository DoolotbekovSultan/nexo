/// Абстракция логгера приложения.
///
/// Определяет контракт для записи логов四种 уровней: debug, info, warning, error.
/// Реализация подключается через DI (например, [TalkerLoggerAdapter]).
///
/// ## Пример использования
///
/// ```dart
/// abstract class SomeUseCase {
///   final NexoLogger _logger;
///   SomeUseCase(this._logger);
///
///   void execute() {
///     _logger.info('UseCase started');
///     try {
///       // ...
///     } catch (e, st) {
///       _logger.error(message: 'UseCase failed', error: e, stackTrace: st);
///     }
///   }
/// }
/// ```
abstract class NexoLogger {
  /// Записывает отладочное сообщение уровня debug.
  ///
  /// Используется для подробной трассировки внутреннего состояния.
  /// В продакшене обычно фильтруется.
  ///
  /// [message] — текстовое описание отладочного события.
  void debug(String message);

  /// Записывает информационное сообщение уровня info.
  ///
  /// Используется для фиксации нормальных операций (старт загрузки, результат запроса и т. д.).
  ///
  /// [message] — текстовое описание информационного события.
  void info(String message);

  /// Записывает предупреждение уровня warning.
  ///
  /// Используется для нештатных, но не критичных ситуаций (например, deprecated API).
  ///
  /// [message] — текстовое описание предупреждения.
  void warning(String message);

  /// Записывает ошибку уровня error.
  ///
  /// Используется для фиксации исключений и критических сбоев.
  ///
  /// [message] — краткое описание контекста ошибки.
  /// [error] — объект ошибки (исключение, Caught-значение).
  /// [stackTrace] — стек вызовов; по умолчанию `null`.
  ///
  /// **Важно:** Реализация должна гарантировать запись [error] и [stackTrace],
  /// чтобы диагностика была полной.
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  });
}

/// Удобные расширения для [NexoLogger].
extension NexoLoggerX on NexoLogger {
  /// Логирует начало/успех/ошибку асинхронной операции.
  ///
  /// ```dart
  /// final users = await logger.logAction(
  ///   'fetchUsers',
  ///   () => api.getUsers(),
  /// );
  /// ```
  Future<T> logAction<T>(String label, Future<T> Function() action) async {
    debug('Start: $label');
    try {
      final result = await action();
      debug('Done: $label');
      return result;
    } catch (e, st) {
      error(message: 'Failed: $label', error: e, stackTrace: st);
      rethrow;
    }
  }
}
