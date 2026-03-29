import 'dart:io';

import '../failure.dart';
import '../types/file_failure.dart';
import '../types/storage_failure.dart';
import 'failure_sub_mapper.dart';

final class FileSystemFailureMapper implements FailureSubMapper {
  const FileSystemFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    return switch (error) {
      PathNotFoundException e => _mapPathNotFound(e),
      FileSystemException e => _mapFileSystem(e),
      _ => null,
    };
  }

  Failure _mapPathNotFound(PathNotFoundException error) {
    final path = error.path?.toLowerCase();

    if (_looksLikeStoragePath(path)) {
      return Failure.storage(
        type: StorageFailure.notFound,
        key: error.path,
        message: error.message,
      );
    }

    return Failure.file(
      type: FileFailure.notFound,
      path: error.path,
      message: error.message,
    );
  }

  Failure _mapFileSystem(FileSystemException error) {
    final path = error.path?.toLowerCase();
    final message = error.message.toLowerCase();

    if (_looksLikeStoragePath(path)) {
      return _mapStorageFailure(error, message);
    }

    return Failure.file(
      type: _mapFileType(message),
      path: error.path,
      message: error.message,
    );
  }

  Failure _mapStorageFailure(FileSystemException error, String message) {
    if (_containsAny(message, const ['permission denied'])) {
      return Failure.storage(
        type: StorageFailure.permissionDenied,
        key: error.path,
        message: error.message,
      );
    }

    if (_containsAny(message, const ['no space left', 'disk full'])) {
      return Failure.storage(
        type: StorageFailure.outOfSpace,
        key: error.path,
        message: error.message,
      );
    }

    if (_containsAny(message, const ['corrupt', 'corrupted'])) {
      return Failure.storage(
        type: StorageFailure.corrupted,
        key: error.path,
        message: error.message,
      );
    }

    if (_containsAny(message, const [
      'not found',
      'no such file',
      'cannot find',
    ])) {
      return Failure.storage(
        type: StorageFailure.notFound,
        key: error.path,
        message: error.message,
      );
    }

    if (_containsAny(message, const ['read'])) {
      return Failure.storage(
        type: StorageFailure.readError,
        key: error.path,
        message: error.message,
      );
    }

    if (_containsAny(message, const ['write', 'save'])) {
      return Failure.storage(
        type: StorageFailure.writeError,
        key: error.path,
        message: error.message,
      );
    }

    if (_containsAny(message, const ['delete', 'remove'])) {
      return Failure.storage(
        type: StorageFailure.deleteError,
        key: error.path,
        message: error.message,
      );
    }

    return Failure.storage(
      type: StorageFailure.unavailable,
      key: error.path,
      message: error.message,
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
