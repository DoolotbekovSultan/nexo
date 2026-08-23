import 'platform_exceptions_io.dart' as impl
    if (dart.library.js_interop) 'platform_exceptions_stub.dart';

/// Platform-agnostic probes for `dart:io` exception types.
///
/// `dart:io` types (`SocketException`, `FileSystemException`, …) do not exist
/// on the web, so mappers must not reference them directly. These probes keep
/// the same semantics on VM/mobile/desktop and degrade to `false`/`null` on
/// the web, where such exceptions can never occur.
abstract final class PlatformExceptions {
  static bool isSocketException(Object? error) => impl.isSocketException(error);

  /// Message of a `SocketException`-shaped error, `null` otherwise.
  static String? socketMessage(Object? error) => impl.socketMessage(error);

  static bool isHandshakeException(Object? error) =>
      impl.isHandshakeException(error);

  static bool isTlsException(Object? error) => impl.isTlsException(error);

  static bool isHttpException(Object? error) => impl.isHttpException(error);

  /// Message of an `HttpException`-shaped error, `null` otherwise.
  static String? httpMessage(Object? error) => impl.httpMessage(error);

  static bool isFileSystemException(Object? error) =>
      impl.isFileSystemException(error);

  static bool isPathNotFoundException(Object? error) =>
      impl.isPathNotFoundException(error);

  /// `(path, message)` details of a file-system-shaped error.
  static ({String? path, String message})? fileSystemDetails(Object? error) =>
      impl.fileSystemDetails(error);
}
