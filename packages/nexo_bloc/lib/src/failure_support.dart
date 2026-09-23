import 'package:nexo_errors/nexo_errors.dart';

/// Миксин, добавляющий поддержку преобразования ошибок в [Failure].
///
/// Используется совместно с [NexoBloc] и [NexoCubit] для единообразной обработки
/// ошибок. Автоматически определяет, является ли ошибка уже [Failure], и если нет —
/// преобразует её через [FailureMapperExtension].
///
/// ## Пример
///
/// ```dart
/// class MyBloc extends NexoBloc<Event, State> {
///   void handleError(Object error, StackTrace stackTrace) {
///     final failure = toFailure(error, stackTrace);
///     // обработка failure...
///   }
/// }
/// ```
///
/// См. также: [Failure], [FailureMapperExtension].
mixin FailureSupport {
  /// Преобразует ошибку [error] в [Failure].
  ///
  /// [error] — объект ошибки (может быть [Failure] или любым другим типом).
  /// [stackTrace] — стек вызовов для диагностики.
  ///
  /// **Возвращает:** экземпляр [Failure]. Если [error] уже является [Failure],
  /// возвращает его без изменений. Иначе преобразует через [toFailure] из
  /// [FailureMapperExtension].
  Failure toFailure(Object error, StackTrace stackTrace) {
    return error is Failure ? error : error.toFailure(stackTrace);
  }
}
