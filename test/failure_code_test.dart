import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_codes.dart';
import 'package:nexo/packages/nexo_errors/types/http_failure.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';

void main() {
  test('failureCode matches category and snake enum', () {
    expect(
      failureCode(const Failure.network(type: NetworkFailure.noInternet)),
      'network.no_internet',
    );
    expect(
      failureCode(const Failure.http(type: HttpFailure.unauthorized)),
      'http.unauthorized',
    );
    expect(
      failureCode(
        const Failure.http(type: HttpFailure.unknown, statusCode: 502),
      ),
      'http.status_502',
    );
    expect(failureCode(Failure.unknown(message: 'x')), 'unknown');
  });

  test('Failure.code getter delegates to failureCode', () {
    const f = Failure.network(type: NetworkFailure.timeout);
    expect(f.code, failureCode(f));
  });
}
