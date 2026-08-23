import '../failure.dart';
import '../types/file_failure.dart';
import '../types/storage_failure.dart';
import 'failure_sub_mapper.dart';
import 'platform_exceptions.dart';

final class FileSystemFailureMapper implements FailureSubMapper {
  const FileSystemFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    final details = PlatformExceptions.fileSystemDetails(error);
    if (details == null) return null;

    if (PlatformExceptions.isPathNotFoundException(error)) {
      return _mapPathNotFound(details.path, details.message);
    }
    return _mapFileSystem(details.path, details.message);
  }

  Failure _mapPathNotFound(String? path, String message) {
    final loweredPath = path?.toLowerCase();

    if (_looksLikeStoragePath(loweredPath)) {
      return Failure.storage(
        type: StorageFailure.notFound,
        key: path,
        message: message,
      );
    }

    return Failure.file(
      type: FileFailure.notFound,
      path: path,
      message: message,
    );
  }

  Failure _mapFileSystem(String? path, String message) {
    final loweredPath = path?.toLowerCase();
    final loweredMessage = message.toLowerCase();

    if (_looksLikeStoragePath(loweredPath)) {
      return _mapStorageFailure(path, message, loweredMessage);
    }

    return Failure.file(
      type: _mapFileType(loweredMessage),
      path: path,
      message: message,
    );
  }

  Failure _mapStorageFailure(
    String? path,
    String message,
    String loweredMessage,
  ) {
    if (_containsAny(loweredMessage, const ['permission denied'])) {
      return Failure.storage(
        type: StorageFailure.permissionDenied,
        key: path,
        message: message,
      );
    }

    if (_containsAny(loweredMessage, const ['no space left', 'disk full'])) {
      return Failure.storage(
        type: StorageFailure.outOfSpace,
        key: path,
        message: message,
      );
    }

    if (_containsAny(loweredMessage, const ['corrupt', 'corrupted'])) {
      return Failure.storage(
        type: StorageFailure.corrupted,
        key: path,
        message: message,
      );
    }

    if (_containsAny(loweredMessage, const [
      'not found',
      'no such file',
      'cannot find',
    ])) {
      return Failure.storage(
        type: StorageFailure.notFound,
        key: path,
        message: message,
      );
    }

    if (_containsAny(loweredMessage, const ['read'])) {
      return Failure.storage(
        type: StorageFailure.readError,
        key: path,
        message: message,
      );
    }

    if (_containsAny(loweredMessage, const ['write', 'save'])) {
      return Failure.storage(
        type: StorageFailure.writeError,
        key: path,
        message: message,
      );
    }

    if (_containsAny(loweredMessage, const ['delete', 'remove'])) {
      return Failure.storage(
        type: StorageFailure.deleteError,
        key: path,
        message: message,
      );
    }

    return Failure.storage(
      type: StorageFailure.unavailable,
      key: path,
      message: message,
    );
  }

  FileFailure _mapFileType(String message) {
    if (_containsAny(message, const [
      'no such file',
      'cannot find',
      'not found',
    ])) {
      return FileFailure.notFound;
    }

    if (_containsAny(message, const [
      'permission denied',
      'operation not permitted',
      'access is denied',
    ])) {
      return FileFailure.accessDenied;
    }

    if (_containsAny(message, const ['no space left', 'disk full'])) {
      return FileFailure.outOfSpace;
    }

    if (_containsAny(message, const ['copy'])) {
      return FileFailure.copyError;
    }

    if (_containsAny(message, const ['move', 'rename'])) {
      return FileFailure.moveError;
    }

    if (_containsAny(message, const ['delete', 'remove'])) {
      return FileFailure.deleteError;
    }

    if (_containsAny(message, const ['write', 'save'])) {
      return FileFailure.writeError;
    }

    if (_containsAny(message, const ['directory'])) {
      return FileFailure.directoryNotFound;
    }

    return FileFailure.readError;
  }

  bool _looksLikeStoragePath(String? path) {
    if (path == null || path.isEmpty) return false;

    return _containsAny(path, const [
      'shared_preferences',
      'flutter_secure_storage',
      'application support',
      'documents',
      'library',
      'cache',
      'preferences',
      'tmp',
      'temp',
      'app_flutter',
    ]);
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
