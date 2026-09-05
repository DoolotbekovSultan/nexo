import 'package:isar/isar.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Базовый класс для работы с Isar хранилищем.
///
/// Предоставляет обёртки для транзакций чтения и записи,
/// а также подписки на изменения данных.
///
/// ## Пример использования
///
/// ```dart
/// class UserIsarDataSource extends BaseIsarDataSource {
///   UserIsarDataSource(super.isar, {required super.logger});
///
///   Future<List<User>> getAllUsers() {
///     return read((isar) => isar.users.where().findAll());
///   }
///
///   Future<void> saveUser(User user) {
///     return write((isar) => isar.users.put(user));
///   }
/// }
/// ```
///
/// См. также: [BaseHiveDataSource], [BaseSharedPreferencesDataSource].
abstract class BaseIsarDataSource {
  /// Экземпляр Isar для выполнения операций.
  final Isar isar;

  final NexoLogger _logger;

  /// Создаёт экземпляр [BaseIsarDataSource].
  ///
  /// [isar] — экземпляр Isar.
  /// [logger] — логгер для записи ошибок.
  const BaseIsarDataSource(this.isar, {required NexoLogger logger})
    : _logger = logger;

  String _tag(String message) => '[Isar] $message';

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

  /// Выполняет операцию чтения в Isar.
  ///
  /// [action] — функция, принимающая [Isar] и возвращающая результат.
  ///
  /// **Возвращает:** результат операции типа [T].
  Future<T> read<T>(Future<T> Function(Isar isar) action) {
    return _run('Read failed', () => action(isar));
  }

  /// Выполняет операцию записи в Isar в транзакции.
  ///
  /// [action] — функция, принимающая [Isar] и возвращающая результат.
  ///
  /// **Возвращает:** результат операции типа [T].
  Future<T> write<T>(Future<T> Function(Isar isar) action) {
    return _run(
      'Write transaction failed',
      () => isar.writeTxn<T>(() => action(isar)),
    );
  }

  /// Подписывается на изменения данных в Isar.
  ///
  /// [watcher] — функция, создающая поток изменений.
  ///
  /// **Возвращает:** [Stream] с обновлениями данных.
  Stream<T> watch<T>(Stream<T> Function(Isar isar) watcher) {
    return _runSync('Watch setup failed', () => watcher(isar));
  }
}
