import 'dart:io';

/// Реализация probes для `dart:io` на native платформах (VM, mobile, desktop).
///
/// Все функции проверяют реальные типы исключений `dart:io`.

/// Проверяет, является ли [error] экземпляром `SocketException`.
bool isSocketException(Object? error) => error is SocketException;

/// Возвращает сообщение `SocketException` или `null`.
String? socketMessage(Object? error) =>
    error is SocketException ? error.message : null;

/// Проверяет, является ли [error] экземпляром `HandshakeException`.
bool isHandshakeException(Object? error) => error is HandshakeException;

/// Проверяет, является ли [error] экземпляром `TlsException`.
bool isTlsException(Object? error) => error is TlsException;

/// Проверяет, является ли [error] экземпляром `HttpException`.
bool isHttpException(Object? error) => error is HttpException;

/// Возвращает сообщение `HttpException` или `null`.
String? httpMessage(Object? error) =>
    error is HttpException ? error.message : null;

/// Проверяет, является ли [error] экземпляром `FileSystemException`.
bool isFileSystemException(Object? error) => error is FileSystemException;

/// Проверяет, является ли [error] экземпляром `PathNotFoundException`.
bool isPathNotFoundException(Object? error) => error is PathNotFoundException;

/// Возвращает `(path, message)` ошибки файловой системы или `null`.
({String? path, String message})? fileSystemDetails(Object? error) {
  if (error is! FileSystemException) return null;
  return (path: error.path, message: error.message);
}
