import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Базовый класс для работы с защищённым хранилищем (Keychain/Keystore).
///
/// Предоставляет методы для чтения, записи и удаления чувствительных данных
/// (токены, ключи API, пароли). Данные шифруются на уровне ОС.
///
/// ## Пример использования
///
/// ```dart
/// class AuthSecureStorage extends BaseSecureStorageDataSource {
///   AuthSecureStorage({required super.logger})
///       : super(const FlutterSecureStorage());
///
///   Future<void> saveTokens(String access, String refresh) async {
///     await write('access_token', access);
///     await write('refresh_token', refresh);
///   }
/// }
/// ```
///
/// См. также: [BaseHiveDataSource], [BaseSharedPreferencesDataSource].
abstract class BaseSecureStorageDataSource {
  /// Экземпляр FlutterSecureStorage для операций.
  final FlutterSecureStorage storage;

  final NexoLogger _logger;

  /// Создаёт экземпляр [BaseSecureStorageDataSource].
  ///
  /// [storage] — экземпляр FlutterSecureStorage.
  /// [logger] — логгер для записи ошибок.
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

  /// Сохраняет строковое значение по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — строковое значение.
  ///
  /// **Возвращает:** [Future], который завершается после сохранения.
  Future<void> write(String key, String value) {
    return _run(
      'write failed key=$key',
      () => storage.write(key: key, value: value),
    );
  }

  /// Читает строковое значение по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** [Future] со значением или `null`, если ключ не найден.
  Future<String?> read(String key) {
    return _run('read failed key=$key', () => storage.read(key: key));
  }

  /// Удаляет значение по ключу.
  ///
  /// [key] — ключ для удаления.
  ///
  /// **Возвращает:** [Future], который завершается после удаления.
  Future<void> delete(String key) {
    return _run('delete failed key=$key', () => storage.delete(key: key));
  }

  /// Удаляет все значения из хранилища.
  ///
  /// **Возвращает:** [Future], который завершается после очистки.
  Future<void> deleteAll() {
    return _run('deleteAll failed', () => storage.deleteAll());
  }

  /// Проверяет наличие ключа в хранилище.
  ///
  /// [key] — ключ для проверки.
  ///
  /// **Возвращает:** [Future] с `true`, если ключ существует.
  Future<bool> containsKey(String key) {
    return _run(
      'containsKey failed key=$key',
      () => storage.containsKey(key: key),
    );
  }

  /// Сохраняет JSON-объект по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — JSON-совместимый объект.
  ///
  /// **Возвращает:** [Future], который завершается после сохранения.
  Future<void> writeJson(String key, Map<String, dynamic> value) {
    return _run(
      'writeJson failed key=$key',
      () => storage.write(key: key, value: jsonEncode(value)),
    );
  }

  /// Читает JSON-объект по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** [Future] с JSON-объектом или `null`, если ключ не найден.
  Future<Map<String, dynamic>?> readJson(String key) {
    return _run('readJson failed key=$key', () async {
      final raw = await storage.read(key: key);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    });
  }

  /// Читает значение по ключу, возвращая пустую строку если не найдено.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** [Future] со значением или пустой строкой.
  Future<String> readOrEmpty(String key) async {
    return (await read(key)) ?? '';
  }
}
