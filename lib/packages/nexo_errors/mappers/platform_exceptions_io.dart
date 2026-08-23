import 'dart:io';

bool isSocketException(Object? error) => error is SocketException;

String? socketMessage(Object? error) =>
    error is SocketException ? error.message : null;

bool isHandshakeException(Object? error) => error is HandshakeException;

bool isTlsException(Object? error) => error is TlsException;

bool isHttpException(Object? error) => error is HttpException;

String? httpMessage(Object? error) =>
    error is HttpException ? error.message : null;

bool isFileSystemException(Object? error) => error is FileSystemException;

bool isPathNotFoundException(Object? error) => error is PathNotFoundException;

({String? path, String message})? fileSystemDetails(Object? error) {
  if (error is! FileSystemException) return null;
  return (path: error.path, message: error.message);
}
