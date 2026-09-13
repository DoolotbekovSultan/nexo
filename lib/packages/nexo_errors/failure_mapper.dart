import 'failure.dart';
import 'failure_mapper_2.dart';

/// Централизованный маппер ошибок в [Failure].
///
/// **Внимание:** Используйте [FailureMapper2] для новых проектов.
/// Этот класс помечен как deprecated и делегирует вызовы в [FailureMapper2].
///
/// См. также: [FailureMapper2].
@Deprecated('Используйте FailureMapper2')
final class FailureMapper {
  const FailureMapper._();

  /// Преобразует произвольный [error] в [Failure].
  ///
  /// [error] — исключение или объект ошибки.
  /// [stackTrace] — стек вызовов (опционален, передаётся для логирования).
  ///
  /// **Возвращает:** [Failure] — результат маппинга.
  /// Если [error] уже является [Failure], возвращается как есть.
  static Failure from(Object error, [StackTrace? stackTrace]) {
    return FailureMapper2.fromStatic(error, stackTrace);
  }
}
