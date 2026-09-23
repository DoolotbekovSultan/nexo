/// Аннотация для автоматической генерации реализации UseCase.
///
/// Помечает abstract class как UseCase, для которого build_runner генерирует
/// concrete implementation с конструктором и методом [execute].
///
/// ## Параметры
///
/// - [repo] — тип repository (опционально). Если указан, генерируется
///   constructor с обязательным параметром repository.
/// - [extraDeps] — дополнительные зависимости (например, ProductAnalytics).
///   Генерируются как named parameters в constructor.
///
/// ## Пример использования
///
/// ```dart
/// @NexoUseCaseAnnotation()
/// abstract class GetUserUseCase {
///   Future<User> execute(GetUserParams params);
/// }
/// ```
class NexoUseCaseAnnotation {
  /// Создаёт аннотацию [NexoUseCaseAnnotation].
  ///
  /// [repo] — тип repository (опционально).
  /// [extraDeps] — список дополнительных зависимостей.
  const NexoUseCaseAnnotation({this.repo, this.extraDeps = const []});

  /// Тип repository (опционально).
  final Type? repo;

  /// Дополнительные зависимости.
  final List<Type> extraDeps;
}
