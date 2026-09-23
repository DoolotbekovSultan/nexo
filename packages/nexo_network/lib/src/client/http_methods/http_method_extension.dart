import 'package:nexo_network/src/client/http_methods/http_method.dart';

/// Расширение для [HttpMethod] (обратная совместимость).
///
/// Основное свойство [HttpMethod.value] теперь определено в самом enum.
extension HttpMethodExtension on HttpMethod {
  /// Строковое представление HTTP-метода (делегирует к [HttpMethod.value]).
  String get methodValue => value;
}
