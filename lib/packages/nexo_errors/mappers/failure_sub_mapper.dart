import '../failure.dart';

/// Интерфейс подмаппера ошибок, реализуемый каждым специализированным маппером.
///
/// Каждый [FailureSubMapper] отвечает за определённую группу ошибок (Dio, Hive,
/// Firebase, файловая система и т.д.) и пытается преобразовать исходное
/// исключение в [Failure]. Если маппер не распознаёт ошибку, возвращает `null`.
///
/// См. также: [DioFailureMapper], [HiveFailureMapper], [CommonFailureMapper].
abstract interface class FailureSubMapper {
  const FailureSubMapper();

  /// Пытается преобразовать [error] в [Failure].
  ///
  /// [error] — исходное исключение или ошибка.
  /// [stackTrace] — стек вызовов (опционально, используется для [Failure.unknown]).
  ///
  /// **Возвращает:** [Failure], если ошибка распознана, или `null` если
  /// данный маппер не обрабатывает данный тип ошибки.
  Failure? tryMap(Object error, [StackTrace? stackTrace]);
}
