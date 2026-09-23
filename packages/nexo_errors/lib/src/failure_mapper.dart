import 'package:nexo_errors/src/failure.dart';
import 'package:nexo_errors/src/mappers/common_failure_mapper.dart';
import 'package:nexo_errors/src/mappers/dio_failure_mapper.dart';
import 'package:nexo_errors/src/mappers/domain_exception_failure_mapper.dart';
import 'package:nexo_errors/src/mappers/failure_sub_mapper.dart';
import 'package:nexo_errors/src/mappers/file_system_failure_mapper.dart';
import 'package:nexo_errors/src/mappers/platform_failure_mapper.dart';

/// Расширяемый маппер ошибок в [Failure] с поддержкой DI.
///
/// Поддерживает регистрацию кастомных мапперов через DI (get_it, injectable)
/// и позволяет переупорядочить мапперы.
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
/// @Singleton(as: FailureMapper)
/// class AppFailureMapper extends FailureMapper {
///   AppFailureMapper() : super(
///     extraMappers: [
///       const AdminApiFailureMapper(),
///       const ServerpodFailureMapper(),
///     ],
///   );
/// }
///
/// // Использование
/// final failure = getIt<FailureMapper>().from(error, stackTrace);
/// ```
///
/// См. также: [FailureSubMapper].
final class FailureMapper {
  /// Создаёт экземпляр [FailureMapper].
  ///
  /// [extraMappers] — дополнительные мапперы приложения (высший приоритет).
  /// [builtInMappers] — переопределяет список встроенных мапперов.
  /// Если не задан, используются только platform-agnostic мапперы.
  FailureMapper({
    List<FailureSubMapper>? extraMappers,
    List<FailureSubMapper>? builtInMappers,
  }) : _extraMappers = extraMappers ?? [],
       _builtInMappers = builtInMappers ?? _defaultBuiltIn;

  final List<FailureSubMapper> _extraMappers;
  final List<FailureSubMapper> _builtInMappers;

  /// Platform-agnostic встроенные мапперы (без зависимостей от firebase, hive, isar, drift).
  static const List<FailureSubMapper> _defaultBuiltIn = [
    DomainExceptionFailureMapper(),
    DioFailureMapper(),
    PlatformFailureMapper(),
    FileSystemFailureMapper(),
    CommonFailureMapper(),
  ];

  /// Регистрирует кастомный маппер (высший приоритет).
  void register(FailureSubMapper mapper) {
    _extraMappers.add(mapper);
  }

  /// Регистрирует список мапперов.
  void registerAll(List<FailureSubMapper> mappers) {
    _extraMappers.addAll(mappers);
  }

  /// Преобразует произвольный [error] в [Failure].
  ///
  /// Если [error] уже является [Failure], возвращается как есть.
  Failure from(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    for (final mapper in _extraMappers) {
      final failure = mapper.tryMap(error, stackTrace);
      if (failure != null) return failure;
    }

    for (final mapper in _builtInMappers) {
      final failure = mapper.tryMap(error, stackTrace);
      if (failure != null) return failure;
    }

    return Failure.unknown(
      error: error,
      stackTrace: stackTrace,
      message: error.toString(),
    );
  }

  /// Статический метод для использования без DI.
  ///
  /// Использует дефолтный экземпляр без кастомных мапперов.
  static Failure fromStatic(Object error, [StackTrace? stackTrace]) {
    return _defaultMapper.from(error, stackTrace);
  }

  static final _defaultMapper = FailureMapper();
}
