import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper.dart';
import 'package:nexo/packages/nexo_errors/mappers/dio_failure_mapper.dart';
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

  group('requestId прокидывается из extra в Failure', () {
    RequestOptions optionsWithId() =>
        RequestOptions(path: '/items')..extra[nexoRequestIdExtraKey] = 'req-42';

    test('network-ошибка получает requestId', () {
      final err = DioException(
        requestOptions: optionsWithId(),
        type: DioExceptionType.connectionTimeout,
      );

      final f = FailureMapper.from(err);

      expect(
        f,
        const Failure.network(
          type: NetworkFailure.timeout,
          requestId: 'req-42',
        ),
      );
    });

    test('http-ошибка получает requestId', () {
      final options = optionsWithId();
      final err = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 500,
          data: {'message': 'boom'},
        ),
      );

      final f = FailureMapper.from(err);

      expect(
        f,
        isA<HttpAppFailure>().having((x) => x.requestId, 'requestId', 'req-42'),
      );
      expect((f as HttpAppFailure).statusCode, 500);
    });

    test('без requestId в extra поле остаётся null', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );

      final f = FailureMapper.from(err);

      expect(
        f,
        isA<NetworkAppFailure>().having(
          (x) => x.requestId,
          'requestId',
          isNull,
        ),
      );
    });

    test('auth/validation-ошибки requestId не получают (вне скоупа)', () {
      final options = optionsWithId();
      final err = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 401,
          data: {'message': 'nope'},
        ),
      );

      expect(FailureMapper.from(err), isA<AuthAppFailure>());
    });
  });
}
