import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_2.dart';

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
  /// **Возвращает:** [Failure], полученный через [FailureMapper2.fromStatic].
  Failure toFailure([StackTrace? stackTrace]) {
    return FailureMapper2.fromStatic(this, stackTrace);
  }
}
