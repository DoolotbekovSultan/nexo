import 'package:nexo_errors/src/failure.dart';
import 'package:nexo_errors/src/failure_mapper.dart';

/// Удобное расширение для преобразования ошибок в [Failure].
///
/// Позволяет вызывать `.toFailure()` на любом объекте ошибки.
///
/// ## Пример
///
/// ```dart
/// try {
///   await dio.get('/api/data');
/// } catch (e, s) {
///   final failure = e.toFailure(s);
///   showSnackBar(failure.userMessage);
/// }
/// ```
extension FailureMapperExtension on Object {
  /// Преобразует текущий объект ошибки в [Failure].
  ///
  /// [stackTrace] — стек вызовов (опционален).
  ///
  /// **Возвращает:** [Failure], полученный через [FailureMapper.fromStatic].
  Failure toFailure([StackTrace? stackTrace]) {
    return FailureMapper.fromStatic(this, stackTrace);
  }
}
