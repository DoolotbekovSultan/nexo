import 'failure.dart';
import 'mappers/common_failure_mapper.dart';
import 'mappers/dio_failure_mapper.dart';
import 'mappers/domain_exception_failure_mapper.dart';
import 'mappers/drift_failure_mapper.dart';
import 'mappers/failure_sub_mapper.dart';
import 'mappers/file_system_failure_mapper.dart';
import 'mappers/firebase_auth_failure_mapper.dart';
import 'mappers/firebase_messaging_failure_mapper.dart';
import 'mappers/hive_failure_mapper.dart';
import 'mappers/isar_failure_mapper.dart';
import 'mappers/platform_failure_mapper.dart';

/// Расширяемый маппер ошибок в [Failure] с поддержкой DI.
///
/// В отличие от [FailureMapper], поддерживает регистрацию кастомных мапперов
/// через DI (get_it, injectable) и позволяет переупорядочить мапперы.
///
/// ## Порядок маппинга
///
/// 1. Если [error] уже является [Failure] — возвращается как есть.
/// 2. Кастомные мапперы приложения (регистрируются через DI, высший приоритет).
/// 3. Встроенные мапперы nexo (порядок фиксирован).
/// 4. Catch-all → [Failure.unknown].
///
/// ## Пример использования
///
/// ```dart
/// // Регистрация через DI
/// @Singleton(as: FailureMapper2)
/// class AppFailureMapper extends FailureMapper2 {
///   AppFailureMapper() : super(
///     extraMappers: [
///       const AdminApiFailureMapper(),
///       const ServerpodFailureMapper(),
///     ],
///   );
/// }
///
/// // Использование
/// final failure = getIt<FailureMapper2>().from(error, stackTrace);
/// ```
///
/// См. также: [FailureMapper], [FailureSubMapper].
final class FailureMapper2 {
  /// Создаёт экземпляр [FailureMapper2].
  ///
  /// [extraMappers] — дополнительные мапперы приложения (высший приоритет).
  FailureMapper2({List<FailureSubMapper>? extraMappers})
    : _extraMappers = extraMappers ?? [];

  final List<FailureSubMapper> _extraMappers;

  /// Встроенные мапперы nexo (порядок фиксирован).
  static const List<FailureSubMapper> _builtInMappers = [
    DomainExceptionFailureMapper(),
    FirebaseAuthFailureMapper(),
    FirebaseMessagingFailureMapper(),
    DioFailureMapper(),
    PlatformFailureMapper(),
    HiveFailureMapper(),
    IsarFailureMapper(),
    DriftFailureMapper(),
    FileSystemFailureMapper(),
    CommonFailureMapper(),
  ];

  /// Регистрирует кастомный маппер (высший приоритет).
  ///
  /// [mapper] — маппер, реализующий [FailureSubMapper].
  void register(FailureSubMapper mapper) {
    _extraMappers.add(mapper);
  }

  /// Регистрирует список мапперов.
  ///
  /// [mappers] — список мапперов для регистрации.
  void registerAll(List<FailureSubMapper> mappers) {
    _extraMappers.addAll(mappers);
  }

  /// Преобразует произвольный [error] в [Failure].
  ///
  /// [error] — исключение или объект ошибки.
  /// [stackTrace] — стек вызовов (опционален, передаётся для логирования).
  ///
  /// **Возвращает:** [Failure] — результат маппинга.
  /// Если [error] уже является [Failure], возвращается как есть.
  Failure from(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    // 1. Кастомные мапперы приложения (высший приоритет)
    for (final mapper in _extraMappers) {
      final failure = mapper.tryMap(error, stackTrace);
      if (failure != null) return failure;
    }

    // 2. Встроенные мапперы nexo
    for (final mapper in _builtInMappers) {
      final failure = mapper.tryMap(error, stackTrace);
      if (failure != null) return failure;
    }

    // 3. Catch-all
    return Failure.unknown(
      error: error,
      stackTrace: stackTrace,
      message: error.toString(),
    );
  }

  /// Статический метод для обратной совместимости.
  ///
  /// Использует дефолтный экземпляр без кастомных мапперов.
  static Failure fromStatic(Object error, [StackTrace? stackTrace]) {
    return _defaultMapper.from(error, stackTrace);
  }

  static final _defaultMapper = FailureMapper2();
}
