import 'package:hive/hive.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Базовый класс для работы с Hive хранилищем.
///
/// Предоставляет полный CRUD-интерфейс: создание, чтение, обновление,
/// удаление, поиск и наблюдение за изменениями. Автоматически инициализирует
/// бокс при первом обращении.
///
/// ## Параметры
///
/// - [T] — тип хранимых данных.
/// - [ID] — тип ключа (обычно `String` или `int`).
///
/// ## Пример использования
///
/// ```dart
/// class UserHiveDataSource extends BaseHiveDataSource<User, String> {
///   UserHiveDataSource({required super.logger})
///       : super('users');
///
///   // Дополнительные методы...
/// }
///
/// final dataSource = UserHiveDataSource(logger: logger);
/// await dataSource.put('user_1', User(name: 'John'));
/// final user = await dataSource.get('user_1');
/// ```
///
/// См. также: [BaseIsarDataSource], [BaseSharedPreferencesDataSource].
abstract class BaseHiveDataSource<T, ID> {
  /// Имя бокса в Hive.
  final String boxName;

  /// Логгер для диагностики.
  final NexoLogger logger;

  Box<T>? _box;
  Future<void>? _initializing;

  /// Создаёт экземпляр [BaseHiveDataSource].
  ///
  /// [boxName] — уникальное имя бокса.
  /// [logger] — логгер для записи событий.
  BaseHiveDataSource(this.boxName, {required this.logger});

  /// `true`, если бокс открыт и готов к работе.
  bool get isInitialized {
    final box = _box;
    return box != null && box.isOpen;
  }

  String _tag(String message) => '[Hive:$boxName] $message';

  Future<R> _run<R>(String action, Future<R> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logger.error(message: _tag(action), error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  R _runSync<R>(String action, R Function() operation) {
    try {
      return operation();
    } catch (error, stackTrace) {
      logger.error(message: _tag(action), error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Инициализирует бокс Hive.
  ///
  /// Если бокс уже открыт, пропускает инициализацию.
  /// Если инициализация уже выполняется, возвращает тот же Future.
  ///
  /// **Возвращает:** [Future], который завершается после открытия бокса.
  Future<void> initialize() {
    final currentBox = _box;
    if (currentBox != null && currentBox.isOpen) {
      logger.debug(_tag('Already initialized'));
      return Future.value();
    }

    final currentInitializing = _initializing;
    if (currentInitializing != null) {
      logger.debug(_tag('Initialization already in progress'));
      return currentInitializing;
    }

    logger.info(_tag('Initializing'));

    _initializing =
        _run<void>('Failed to initialize', () async {
          if (Hive.isBoxOpen(boxName)) {
            _box = Hive.box<T>(boxName);
            logger.info(_tag('Attached to opened box'));
          } else {
            _box = await Hive.openBox<T>(boxName);
            logger.info(_tag('Box opened'));
          }
        }).whenComplete(() {
          _initializing = null;
        });

    return _initializing!;
  }

  /// Гарантирует, что бокс инициализирован.
  ///
  /// Если бокс уже инициализирован, ничего не делает.
  Future<void> ensureInitialized() async {
    if (!isInitialized) {
      await initialize();
    }
  }

  /// Закрывает бокс и освобождает ресурсы.
  ///
  /// **Возвращает:** [Future], который завершается после закрытия бокса.
  Future<void> close() async {
    final box = _box;
    if (box == null) {
      logger.debug(_tag('Close skipped: box is null'));
      return;
    }

    if (!box.isOpen) {
      logger.debug(_tag('Close skipped: box already closed'));
      _box = null;
      return;
    }

    await _run<void>('Failed to close box', () async {
      await box.close();
      logger.info(_tag('Box closed'));
    });

    _box = null;
  }

  /// Сохраняет значение по ключу.
  ///
  /// [key] — ключ для сохранения.
  /// [value] — значение для сохранения.
  /// [flush] — если `true`, немедленно записывает на диск.
  ///
  /// **Возвращает:** [Future], который завершается после сохранения.
  Future<void> put(ID key, T value, {bool flush = false}) async {
    await ensureInitialized();

    await _run<void>('Failed to put key=$key', () async {
      final box = _requireBox();
      await box.put(key, value);

      if (flush) {
        await box.flush();
      }

      logger.debug(_tag('Put key=$key flush=$flush'));
    });
  }

  /// Сохраняет несколько значений.
  ///
  /// [values] — карта ключ-значение для сохранения.
  /// [flush] — если `true`, немедленно записывает на диск.
  ///
  /// **Возвращает:** [Future], который завершается после сохранения.
  Future<void> putAll(Map<ID, T> values, {bool flush = false}) async {
    await ensureInitialized();

    await _run<void>('Failed to putAll count=${values.length}', () async {
      final box = _requireBox();
      await box.putAll(values);

      if (flush) {
        await box.flush();
      }

      logger.debug(_tag('PutAll count=${values.length} flush=$flush'));
    });
  }

  /// Получает значение по ключу.
  ///
  /// [key] — ключ для поиска.
  ///
  /// **Возвращает:** [Future] со значением или `null`, если ключ не найден.
  Future<T?> get(ID key) async {
    await ensureInitialized();

    return _run<T?>('Failed to get key=$key', () async {
      final value = _requireBox().get(key);
      logger.debug(_tag('Get key=$key hit=${value != null}'));
      return value;
    });
  }

  /// Получает все значения из бокса.
  ///
  /// **Возвращает:** [Future] со списком всех значений.
  Future<List<T>> getAll() async {
    await ensureInitialized();

    return _run<List<T>>('Failed to get all values', () async {
      final values = _requireBox().values.toList(growable: false);
      logger.debug(_tag('GetAll count=${values.length}'));
      return values;
    });
  }

  /// Получает все ключи из бокса.
  ///
  /// **Возвращает:** [Future] со списком всех ключей.
  Future<List<ID>> getKeys() async {
    await ensureInitialized();

    return _run<List<ID>>('Failed to get keys', () async {
      final keys = _requireBox().keys.cast<ID>().toList(growable: false);
      logger.debug(_tag('GetKeys count=${keys.length}'));
      return keys;
    });
  }

  /// Проверяет наличие ключа в боксе.
  ///
  /// [key] — ключ для проверки.
  ///
  /// **Возвращает:** [Future] с `true`, если ключ существует.
  Future<bool> containsKey(ID key) async {
    await ensureInitialized();

    return _run<bool>('Failed to check containsKey key=$key', () async {
      final contains = _requireBox().containsKey(key);
      logger.debug(_tag('ContainsKey key=$key result=$contains'));
      return contains;
    });
  }

  /// Удаляет значение по ключу.
  ///
  /// [key] — ключ для удаления.
  /// [flush] — если `true`, немедленно записывает на диск.
  ///
  /// **Возвращает:** [Future], который завершается после удаления.
  Future<void> delete(ID key, {bool flush = false}) async {
    await ensureInitialized();

    await _run<void>('Failed to delete key=$key', () async {
      final box = _requireBox();
      await box.delete(key);

      if (flush) {
        await box.flush();
      }

      logger.debug(_tag('Delete key=$key flush=$flush'));
    });
  }

  /// Удаляет несколько значений по ключам.
  ///
  /// [keys] — ключи для удаления.
  /// [flush] — если `true`, немедленно записывает на диск.
  ///
  /// **Возвращает:** [Future], который завершается после удаления.
  Future<void> deleteAll(Iterable<ID> keys, {bool flush = false}) async {
    await ensureInitialized();
    final keysList = keys.toList(growable: false);

    await _run<void>('Failed to deleteAll count=${keysList.length}', () async {
      final box = _requireBox();
      await box.deleteAll(keysList);

      if (flush) {
        await box.flush();
      }

      logger.debug(_tag('DeleteAll count=${keysList.length} flush=$flush'));
    });
  }

  /// Очищает весь бокс.
  ///
  /// [flush] — если `true`, немедленно записывает на диск.
  ///
  /// **Возвращает:** [Future], который завершается после очистки.
  Future<void> clear({bool flush = false}) async {
    await ensureInitialized();

    await _run<void>('Failed to clear box', () async {
      final box = _requireBox();
      await box.clear();

      if (flush) {
        await box.flush();
      }

      logger.warning(_tag('Clear flush=$flush'));
    });
  }

  /// Ищет значения, соответствующие предикату.
  ///
  /// [predicate] — функция проверки условия.
  ///
  /// **Возвращает:** [Future] со списком найденных значений.
  Future<List<T>> findWhere(bool Function(T item) predicate) async {
    await ensureInitialized();

    return _run<List<T>>('Failed to execute findWhere', () async {
      final values = _requireBox().values
          .where(predicate)
          .toList(growable: false);

      logger.debug(_tag('FindWhere count=${values.length}'));
      return values;
    });
  }

  /// Находит первое значение, соответствующее предикату.
  ///
  /// [predicate] — функция проверки условия.
  ///
  /// **Возвращает:** [Future] с найденным значением или `null`.
  Future<T?> firstWhereOrNull(bool Function(T item) predicate) async {
    await ensureInitialized();

    return _run<T?>('Failed to execute firstWhereOrNull', () async {
      for (final item in _requireBox().values) {
        if (predicate(item)) {
          logger.debug(_tag('FirstWhereOrNull hit=true'));
          return item;
        }
      }

      logger.debug(_tag('FirstWhereOrNull hit=false'));
      return null;
    });
  }

  /// Подписывается на изменения конкретного ключа.
  ///
  /// [key] — ключ для наблюдения.
  ///
  /// **Возвращает:** [Stream] с новыми значениями при изменении ключа.
  Stream<T?> watchKey(ID key) {
    return _runSync('Failed to watch key=$key', () {
      final box = _requireBox();
      logger.debug(_tag('WatchKey subscribed key=$key'));
      return box.watch(key: key).map((event) => event.value as T?);
    });
  }

  /// Подписывается на все изменения в боксе.
  ///
  /// **Возвращает:** [Stream] с событиями всех изменений.
  Stream<BoxEvent> watchAll() {
    return _runSync('Failed to watch all', () {
      logger.debug(_tag('WatchAll subscribed'));
      return _requireBox().watch();
    });
  }

  /// Прямой доступ к боксу (после инициализации).
  Box<T> get box => _requireBox();

  Box<T> _requireBox() {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError(
        'Hive box "$boxName" is not initialized. Call initialize() first.',
      );
    }
    return box;
  }
}
