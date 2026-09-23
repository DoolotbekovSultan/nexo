import 'platform_exceptions_io.dart'
    if (dart.library.js_interop) 'platform_exceptions_stub.dart'
    as impl;

/// Кроссплатформенные проверки типов ошибок `dart:io`.
///
/// Типы `dart:io` (`SocketException`, `FileSystemException` и т.д.) не существуют
/// на web, поэтому мапперы не могут обращаться к ним напрямую. Эти probes
/// сохраняют семантику на VM/mobile/desktop и возвращают `false`/`null` на web,
/// где такие ошибки невозможны.
///
/// ## Пример
///
/// ```dart
/// if (PlatformExceptions.isSocketException(error)) {
///   final message = PlatformExceptions.socketMessage(error);
///   // обработка сетевой ошибки...
/// }
/// ```
abstract final class PlatformExceptions {
  /// Проверяет, является ли [error] экземпляром `SocketException`.
  static bool isSocketException(Object? error) => impl.isSocketException(error);

  /// Сообщение `SocketException` или `null`, если [error] не является [SocketException].
  static String? socketMessage(Object? error) => impl.socketMessage(error);

  /// Проверяет, является ли [error] экземпляром `HandshakeException`.
  static bool isHandshakeException(Object? error) =>
      impl.isHandshakeException(error);

  /// Проверяет, является ли [error] экземпляром `TlsException`.
  static bool isTlsException(Object? error) => impl.isTlsException(error);

  /// Проверяет, является ли [error] экземпляром `HttpException`.
  static bool isHttpException(Object? error) => impl.isHttpException(error);

  /// Сообщение `HttpException` или `null`, если [error] не является [HttpException].
  static String? httpMessage(Object? error) => impl.httpMessage(error);

  /// Проверяет, является ли [error] экземпляром `FileSystemException`.
  static bool isFileSystemException(Object? error) =>
      impl.isFileSystemException(error);

  /// Проверяет, является ли [error] экземпляром `PathNotFoundException`.
  static bool isPathNotFoundException(Object? error) =>
      impl.isPathNotFoundException(error);

  /// Детали ошибки файловой системы: `(path, message)` или `null`.
  static ({String? path, String message})? fileSystemDetails(Object? error) =>
      impl.fileSystemDetails(error);
}
