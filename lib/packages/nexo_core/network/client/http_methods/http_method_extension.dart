import 'package:nexo/packages/nexo_core/network/client/http_methods/http_method.dart';

extension HttpMethodExtension on HttpMethod {
  String get value => name.toUpperCase();
}
