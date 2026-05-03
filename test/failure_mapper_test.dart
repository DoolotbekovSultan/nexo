import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';

void main() {
  group('FailureMapper', () {
    test('returns same Failure instance', () {
      const f = Failure.network(type: NetworkFailure.noInternet);
      expect(FailureMapper.from(f), same(f));
    });

    test('maps DioException timeout to network timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      final f = FailureMapper.from(err);
      expect(f, const Failure.network(type: NetworkFailure.timeout));
    });

    test('maps unknown exception to UnknownAppFailure', () {
      final f = FailureMapper.from(Exception('x'));
      expect(f, isA<UnknownAppFailure>());
      expect(f.userMessage, isNotEmpty);
    });
  });
}
