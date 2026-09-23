import 'dart:async';

/// Фабрика для создания потока данных.
///
/// Используется совместно с [ReconnectingStreamService] для создания
/// нового подключения при обрыве.
///
/// ## Пример
///
/// ```dart
/// class MessagesStreamFactory implements StreamFactory<Message> {
///   @override
///   Stream<Message> create() => socketService.watchMessages();
/// }
/// ```
abstract class StreamFactory<T> {
  /// Создаёт новый экземпляр потока данных.
  Stream<T> create();
}

/// Сервис с автоматическим переподключением к потоку данных.
///
/// При обрыве соединения или ошибке автоматически переподключается
/// к потоку с задержкой [retryDelay]. Использует [StreamFactory]
/// для создания нового подключения.
///
/// ## Пример использования
///
/// ```dart
/// final service = ReconnectingStreamService(
///   factory: MessagesStreamFactory(),
///   retryDelay: Duration(seconds: 3),
/// );
///
/// await for (final message in service.connect()) {
///   // обработка сообщений...
/// }
/// ```
class ReconnectingStreamService<T> {
  /// Создаёт сервис переподключения.
  ///
  /// [factory] — фабрика для создания нового потока.
  /// [retryDelay] — задержка перед переподключением. По умолчанию: 2 секунды.
  ReconnectingStreamService({
    required this.factory,
    this.retryDelay = const Duration(seconds: 2),
  });

  /// Фабрика для создания нового потока.
  final StreamFactory<T> factory;

  /// Задержка перед переподключением после ошибки.
  final Duration retryDelay;

  /// Подключается к потоку с автоматическим переподключением.
  ///
  /// **Возвращает:** бесконечный [Stream], который переподключается
  /// при ошибках с задержкой [retryDelay].
  Stream<T> connect() async* {
    while (true) {
      try {
        yield* factory.create();
      } catch (_) {
        await Future<void>.delayed(retryDelay);
      }
    }
  }
}
