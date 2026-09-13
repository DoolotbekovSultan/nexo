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
/// // Без repository
/// @NexoUseCaseAnnotation()
/// abstract class GetUserUseCase {
///   Future<User> execute(GetUserParams params);
/// }
///
/// // С repository
/// @NexoUseCaseAnnotation(repo: IUserRepository)
/// abstract class GetUserUseCase {
///   Future<User> execute(GetUserParams params);
/// }
///
/// // С дополнительными зависимостями
/// @NexoUseCaseAnnotation(repo: IUserRepository, extraDeps: [ProductAnalytics])
/// abstract class GetUserUseCase {
///   Future<User> execute(GetUserParams params);
/// }
/// ```
///
/// ## Генерируемый код
///
/// ```dart
/// @injectable
/// class GetUserUseCaseImpl extends NexoUseCase<User, GetUserParams> {
///   GetUserUseCaseImpl({
///     required NexoLogger logger,
///     required IUserRepository repository,
///   }) : _repository = repository, super(logger);
///
///   final IUserRepository _repository;
///
///   @override
///   Future<User> execute(GetUserParams params) =>
///       _repository.getUser(params.userId);
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
