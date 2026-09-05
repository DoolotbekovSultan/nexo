import 'dart:async';

import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_extension.dart';
import 'package:nexo/packages/nexo_errors/result.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Базовый класс для UseCase, работающих с потоками данных.
///
/// UseCase инкапсулирует бизнес-логику и возвращает [Stream<Result<T>>].
/// Каждое значение из потока оборачивается в [Right], ошибки — в [Left].
///
/// ## Параметры
///
/// - [T] — тип данных в потоке.
/// - [Params] — тип параметров (класс, record или [NoParams]).
///
/// ## Пример использования
///
/// ```dart
/// class WatchMessagesUseCase extends NexoStreamUseCase<Message, String> {
///   WatchMessagesUseCase(super.logger);
///
///   @override
///   Stream<Message> build(String chatId) {
///     return messageRepository.watchMessages(chatId);
///   }
/// }
///
/// // Вызов:
/// await for (final result in WatchMessagesUseCase(logger)('chat_123')) {
///   result.fold(
///     onFailure: (f) => showError(f.userMessage),
///     onSuccess: (msg) => addMessage(msg),
///   );
/// }
/// ```
///
/// См. также: [NexoUseCase], [NoParams], [Result].
abstract class NexoStreamUseCase<T, Params> {
  final NexoLogger _logger;

  const NexoStreamUseCase(this._logger);

  /// Создаёт поток данных типа [T].
  ///
  /// [params] — параметры для построения потока.
  ///
  /// **Бросает:** исключения, которые будут перехвачены и преобразованы
  /// в [Left] с [Failure] методом [call].
  Stream<T> build(Params params);

  /// Вызывает [build] и оборачивает каждое значение в [Result].
  ///
  /// [params] — параметры для построения потока.
  ///
  /// **Возвращает:** [Stream<Result<T>>], где каждое значение — это [Right]
  /// с данными или [Left] с [Failure].
  Stream<Result<T>> call(Params params) async* {
    _logger.debug('StreamUseCase started: $runtimeType');

    try {
      await for (final value in build(params)) {
        yield Right(value);
      }

      _logger.debug('StreamUseCase completed: $runtimeType');
    } catch (e, s) {
      final failure = e is Failure ? e : e.toFailure(s);

      _logger.error(
        message:
            'StreamUseCase failed: $runtimeType, code: ${failure.code}, message: ${failure.userMessage}',
        error: e,
        stackTrace: s,
      );

      yield Left(failure);
    } finally {
      _logger.debug('StreamUseCase finished: $runtimeType');
    }
  }
}
