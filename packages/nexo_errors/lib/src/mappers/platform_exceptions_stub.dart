/// Web-stub: ни один из типов ошибок `dart:io` не может возникнуть в браузере,
/// поэтому все probes возвращают `false`/`null`.
library;

/// Всегда возвращает `false` — `SocketException` не существует на web.
bool isSocketException(Object? error) => false;

/// Всегда возвращает `null` — `SocketException` не существует на web.
String? socketMessage(Object? error) => null;

/// Всегда возвращает `false` — `HandshakeException` не существует на web.
bool isHandshakeException(Object? error) => false;

/// Всегда возвращает `false` — `TlsException` не существует на web.
bool isTlsException(Object? error) => false;

/// Всегда возвращает `false` — `HttpException` не существует на web.
bool isHttpException(Object? error) => false;

/// Всегда возвращает `null` — `HttpException` не существует на web.
String? httpMessage(Object? error) => null;

/// Всегда возвращает `false` — `FileSystemException` не существует на web.
bool isFileSystemException(Object? error) => false;

/// Всегда возвращает `false` — `PathNotFoundException` не существует на web.
bool isPathNotFoundException(Object? error) => false;

/// Всегда возвращает `null` — `FileSystemException` не существует на web.
({String? path, String message})? fileSystemDetails(Object? error) => null;
