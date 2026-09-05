import 'package:nexo/packages/nexo_core/network/client/http_methods/http_method.dart';

/// Расширение для [HttpMethod], добавляющее строковое представление.
extension HttpMethodExtension on HttpMethod {
  /// Строковое представление HTTP-метода в верхнем регистре.
  ///
  /// Возвращает: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`.
  String get value => name.toUpperCase();
}
