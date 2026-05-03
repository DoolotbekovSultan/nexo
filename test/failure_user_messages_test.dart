import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/localization/failure_user_messages_en.dart';
import 'package:nexo/packages/nexo_errors/localization/failure_user_messages_ru.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';

void main() {
  test('RU and EN catalogs differ for network noInternet', () {
    const f = Failure.network(type: NetworkFailure.noInternet);
    const ru = RuFailureUserMessages();
    const en = EnFailureUserMessages();
    expect(ru.forFailure(f), contains('интернет'));
    expect(en.forFailure(f), contains('internet'));
    expect(f.userMessage, ru.forFailure(f));
  });
}
