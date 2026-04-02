import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

abstract class BaseSharedPreferencesDataSource {
  final SharedPreferences prefs;
  final NexoLogger _logger;

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

  Future<bool> setString(String key, String value) {
    return _run('setString failed key=$key', () => prefs.setString(key, value));
  }

  String? getString(String key) {
    return _runSync('getString failed key=$key', () => prefs.getString(key));
  }

  Future<bool> setBool(String key, bool value) {
    return _run('setBool failed key=$key', () => prefs.setBool(key, value));
  }

  bool? getBool(String key) {
    return _runSync('getBool failed key=$key', () => prefs.getBool(key));
  }

  Future<bool> setInt(String key, int value) {
    return _run('setInt failed key=$key', () => prefs.setInt(key, value));
  }

  int? getInt(String key) {
    return _runSync('getInt failed key=$key', () => prefs.getInt(key));
  }

  Future<bool> setDouble(String key, double value) {
    return _run('setDouble failed key=$key', () => prefs.setDouble(key, value));
  }

  double? getDouble(String key) {
    return _runSync('getDouble failed key=$key', () => prefs.getDouble(key));
  }

  Future<bool> setStringList(String key, List<String> value) {
    return _run(
      'setStringList failed key=$key',
      () => prefs.setStringList(key, value),
    );
  }

  List<String>? getStringList(String key) {
    return _runSync(
      'getStringList failed key=$key',
      () => prefs.getStringList(key),
    );
  }

  Future<bool> setJson(String key, Map<String, dynamic> value) {
    return _run(
      'setJson failed key=$key',
      () => prefs.setString(key, jsonEncode(value)),
    );
  }

  Map<String, dynamic>? getJson(String key) {
    return _runSync('getJson failed key=$key', () {
      final raw = prefs.getString(key);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    });
  }

  String getStringOrEmpty(String key) {
    return prefs.getString(key) ?? '';
  }

  bool getBoolOrFalse(String key) {
    return prefs.getBool(key) ?? false;
  }

  Future<void> reload() {
    return _run('reload failed', () => prefs.reload());
  }

  Future<bool> remove(String key) {
    return _run('remove failed key=$key', () => prefs.remove(key));
  }

  Future<bool> clear() {
    return _run('clear failed', () => prefs.clear());
  }

  bool containsKey(String key) {
    return _runSync(
      'containsKey failed key=$key',
      () => prefs.containsKey(key),
    );
  }
}
