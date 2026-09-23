import 'package:nexo_errors/src/failure.dart';

/// Интерфейс каталога локализованных сообщений для [Failure].
///
/// Позволяет настроить пользовательские сообщения об ошибках
/// для разных языков или A/B тестов.
///
/// ## Пример
///
/// ```dart
/// final catalog = RuFailureUserMessages();
/// final message = failure.localizedMessage(catalog);
/// ```
///
/// См. также: [RuFailureUserMessages], [EnFailureUserMessages].
abstract class FailureUserMessageCatalog {
  /// Возвращает локализованное сообщение для [failure].
  String forFailure(Failure failure);
}

/// Расширение для удобного получения локализованного сообщения.
extension FailureUserMessageX on Failure {
  /// Возвращает сообщение для UI из указанного каталога.
  ///
  /// [catalog] — каталог сообщений (например, [RuFailureUserMessages]).
  String localizedMessage(FailureUserMessageCatalog catalog) =>
      catalog.forFailure(this);
}
