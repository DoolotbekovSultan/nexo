import 'package:nexo/packages/nexo_errors/failure.dart';

/// Pluggable human-readable messages for `Failure` (i18n / A/B / product copy).
abstract class FailureUserMessageCatalog {
  String forFailure(Failure failure);
}

extension FailureUserMessageX on Failure {
  /// Message for UI using the given catalog (e.g. [RuFailureUserMessages], [EnFailureUserMessages]).
  String localizedMessage(FailureUserMessageCatalog catalog) =>
      catalog.forFailure(this);
}
