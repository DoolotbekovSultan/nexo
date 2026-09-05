/// Заглушка для параметров UseCase, которые не требуют входных данных.
///
/// Используется как [Params] в [NexoUseCase] и [NexoStreamUseCase],
/// когда операция не принимает аргументов.
///
/// ## Пример
///
/// ```dart
/// class GetCurrentUserUseCase extends NexoUseCase<User, NoParams> {
///   GetCurrentUserUseCase(super.logger);
///
///   @override
///   Future<User> execute(NoParams params) async {
///     return await userRepository.getCurrentUser();
///   }
/// }
///
/// // Вызов:
/// final result = await GetCurrentUserUseCase(logger)(const NoParams());
/// ```
///
/// См. также: [NexoUseCase], [NexoStreamUseCase].
class NoParams {
  /// Создаёт экземпляр [NoParams].
  const NoParams();
}
