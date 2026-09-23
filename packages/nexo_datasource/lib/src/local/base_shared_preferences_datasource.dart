import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo_logger/nexo_logger.dart';

/// Базовый класс для работы с SharedPreferences.
///
/// Предоставляет типизированные методы для сохранения и чтения простых
/// значений (String, bool, int, double, `List<String>`, JSON).
///
/// ## Пример использования
///
/// ```dart
/// class SettingsDataSource extends BaseSharedPreferencesDataSource {
///   SettingsDataSource({required super.prefs, required super.logger});
///
///   bool get isDarkMode => getBool('dark_mode') ?? false;
///   Future<void> setDarkMode(bool value) => setBool('dark_mode', value);
/// }
/// ```
///
/// См. также: [BaseHiveDataSource], [BaseSecureStorageDataSource].
abstract class BaseSharedPreferencesDataSource {
  /// Экземпляр SharedPreferences для операций.
  final SharedPreferences prefs;

  final NexoLogger _logger;

  /// Создаёт экземпляр [BaseSharedPreferencesDataSource].
  ///
  /// [prefs] — экземпляр SharedPreferences.
  /// [logger] — логгер для записи ошибок.
  const BaseSharedPreferencesDataSource(
    this.prefs, {
    required NexoLogger logger,
  }) : _logger = logger;

  String _tag(String message) => '[SP] $message';

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

  R _runSync<R>(String action, R Function() operation) {
    try {
      return operation();
    } catch (error, stackTrace) {
      _logger.error(
        message: _tag(action),
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Сохраняет строку по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — строковое значение.
  ///
  /// **Возвращает:** [Future] с `true` при успешном сохранении.
  Future<bool> setString(String key, String value) {
    return _run('setString failed key=$key', () => prefs.setString(key, value));
  }

  /// Читает строку по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** значение или `null`, если ключ не найден.
  String? getString(String key) {
    return _runSync('getString failed key=$key', () => prefs.getString(key));
  }

  /// Сохраняет булево значение по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — булево значение.
  ///
  /// **Возвращает:** [Future] с `true` при успешном сохранении.
  Future<bool> setBool(String key, bool value) {
    return _run('setBool failed key=$key', () => prefs.setBool(key, value));
  }

  /// Читает булево значение по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** значение или `null`, если ключ не найден.
  bool? getBool(String key) {
    return _runSync('getBool failed key=$key', () => prefs.getBool(key));
  }

  /// Сохраняет целое число по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — целое число.
  ///
  /// **Возвращает:** [Future] с `true` при успешном сохранении.
  Future<bool> setInt(String key, int value) {
    return _run('setInt failed key=$key', () => prefs.setInt(key, value));
  }

  /// Читает целое число по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** значение или `null`, если ключ не найден.
  int? getInt(String key) {
    return _runSync('getInt failed key=$key', () => prefs.getInt(key));
  }

  /// Сохраняет дробное число по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — дробное число.
  ///
  /// **Возвращает:** [Future] с `true` при успешном сохранении.
  Future<bool> setDouble(String key, double value) {
    return _run('setDouble failed key=$key', () => prefs.setDouble(key, value));
  }

  /// Читает дробное число по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** значение или `null`, если ключ не найден.
  double? getDouble(String key) {
    return _runSync('getDouble failed key=$key', () => prefs.getDouble(key));
  }

  /// Сохраняет список строк по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — список строк.
  ///
  /// **Возвращает:** [Future] с `true` при успешном сохранении.
  Future<bool> setStringList(String key, List<String> value) {
    return _run(
      'setStringList failed key=$key',
      () => prefs.setStringList(key, value),
    );
  }

  /// Читает список строк по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** список строк или `null`, если ключ не найден.
  List<String>? getStringList(String key) {
    return _runSync(
      'getStringList failed key=$key',
      () => prefs.getStringList(key),
    );
  }

  /// Сохраняет JSON-объект по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — JSON-совместимый объект.
  ///
  /// **Возвращает:** [Future] с `true` при успешном сохранении.
  Future<bool> setJson(String key, Map<String, dynamic> value) {
    return _run(
      'setJson failed key=$key',
      () => prefs.setString(key, jsonEncode(value)),
    );
  }

  /// Читает JSON-объект по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** JSON-объект или `null`, если ключ не найден.
  Map<String, dynamic>? getJson(String key) {
    return _runSync('getJson failed key=$key', () {
      final raw = prefs.getString(key);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    });
  }

  /// Читает строку по ключу, возвращая пустую строку если не найдено.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** строку или пустую строку.
  String getStringOrEmpty(String key) {
    return prefs.getString(key) ?? '';
  }

  /// Читает булево значение по ключу, возвращая `false` если не найдено.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** булево значение или `false`.
  bool getBoolOrFalse(String key) {
    return prefs.getBool(key) ?? false;
  }

  /// Перезагружает данные из хранилища.
  ///
  /// **Возвращает:** [Future], который завершается после перезагрузки.
  Future<void> reload() {
    return _run('reload failed', () => prefs.reload());
  }

  /// Удаляет значение по ключу.
  ///
  /// [key] — ключ для удаления.
  ///
  /// **Возвращает:** [Future] с `true` при успешном удалении.
  Future<bool> remove(String key) {
    return _run('remove failed key=$key', () => prefs.remove(key));
  }

  /// Очищает все значения из хранилища.
  ///
  /// **Возвращает:** [Future] с `true` при успешной очистке.
  Future<bool> clear() {
    return _run('clear failed', () => prefs.clear());
  }

  /// Проверяет наличие ключа в хранилище.
  ///
  /// [key] — ключ для проверки.
  ///
  /// **Возвращает:** `true`, если ключ существует.
  bool containsKey(String key) {
    return _runSync(
      'containsKey failed key=$key',
      () => prefs.containsKey(key),
    );
  }
}
