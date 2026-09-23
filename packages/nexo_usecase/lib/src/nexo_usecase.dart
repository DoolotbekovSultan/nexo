import 'package:nexo_core/nexo_core.dart';
import 'package:nexo_errors/nexo_errors.dart';
import 'package:nexo_logger/nexo_logger.dart';

/// Базовый класс для UseCase, выполняющих одну асинхронную операцию.
///
/// UseCase инкапсулирует бизнес-логику приложения и возвращает [Result<T>].
/// Автоматически логирует начало, успешное завершение и ошибки.
///
/// ## Параметры
///
/// - [T] — тип возвращаемого значения.
/// - [Params] — тип параметров (класс, record или [NoParams]).
///
/// ## Пример использования
///
/// ```dart
/// class GetUserUseCase extends NexoUseCase<User, GetUserParams> {
///   GetUserUseCase(super.logger);
///
///   @override
///   Future<User> execute(GetUserParams params) async {
///     return await userRepository.getUser(params.userId);
///   }
/// }
///
/// // Вызов:
/// final result = await GetUserUseCase(logger)(GetUserParams(userId: '123'));
/// result.fold(
///   onFailure: (f) => showError(f.userMessage),
///   onSuccess: (user) => showProfile(user),
/// );
/// ```
///
/// См. также: [NexoStreamUseCase], [NoParams], [Result].
abstract class NexoUseCase<T, Params> {
  final NexoLogger _logger;
  const NexoUseCase(this._logger);

  /// Выполняет бизнес-логику и возвращает результат типа [T].
  ///
  /// [params] — параметры операции.
  ///
  /// **Бросает:** исключения, которые будут перехвачены и преобразованы
  /// в [Failure] методом [call].
  Future<T> execute(Params params);

  /// Вызывает [execute] и оборачивает результат в [Result].
  ///
  /// [params] — параметры операции.
  ///
  /// **Возвращает:**
  /// - [Right] — успешный результат.
  /// - [Left] — [Failure] с описанием ошибки.
  Future<Result<T>> call(Params params) async {
    _logger.debug('UseCase started: $runtimeType');

    try {
      final result = await execute(params);
      _logger.debug('UseCase succeeded: $runtimeType');
      return Right(result);
    } catch (e, s) {
      final failure = e is Failure ? e : e.toFailure(s);
      _logger.error(
        message:
            'UseCase failed: $runtimeType, code: ${failure.code}, message: ${failure.userMessage}',
        error: e,
        stackTrace: s,
      );
      return Left(failure);
    } finally {
      _logger.debug('UseCase finished: $runtimeType');
    }
  }
}
