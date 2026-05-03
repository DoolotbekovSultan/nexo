import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

abstract class BaseSecureStorageDataSource {
  final FlutterSecureStorage storage;
  final NexoLogger _logger;

  const BaseSecureStorageDataSource(this.storage, {required NexoLogger logger})
    : _logger = logger;

  String _tag(String message) => '[SecureStorage] $message';

  Future<R> _run<R>(String action, Future<R> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      _logger.error(
        message: _tag(action),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> write(String key, String value) {
    return _run(
      'write failed key=$key',
      () => storage.write(key: key, value: value),
    );
  }

  Future<String?> read(String key) {
    return _run('read failed key=$key', () => storage.read(key: key));
  }

  Future<void> delete(String key) {
    return _run('delete failed key=$key', () => storage.delete(key: key));
  }

  Future<void> deleteAll() {
    return _run('deleteAll failed', () => storage.deleteAll());
  }

  Future<bool> containsKey(String key) {
    return _run(
      'containsKey failed key=$key',
      () => storage.containsKey(key: key),
    );
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) {
    return _run(
      'writeJson failed key=$key',
      () => storage.write(key: key, value: jsonEncode(value)),
    );
  }

  Future<Map<String, dynamic>?> readJson(String key) {
    return _run('readJson failed key=$key', () async {
      final raw = await storage.read(key: key);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    });
  }

  Future<String> readOrEmpty(String key) async {
    return (await read(key)) ?? '';
  }
}
