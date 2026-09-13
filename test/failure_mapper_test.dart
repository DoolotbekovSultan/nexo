import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_errors/failure.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper.dart';
import 'package:nexo/packages/nexo_errors/failure_mapper_2.dart';
import 'package:nexo/packages/nexo_errors/mappers/dio_failure_mapper.dart';
import 'package:nexo/packages/nexo_errors/mappers/failure_sub_mapper.dart';
import 'package:nexo/packages/nexo_errors/types/http_failure.dart';
import 'package:nexo/packages/nexo_errors/types/network_failure.dart';

void main() {
  group('FailureMapper', () {
    test('returns same Failure instance', () {
      const f = Failure.network(type: NetworkFailure.noInternet);
      // ignore: deprecated_member_use_from_same_package
      expect(FailureMapper.from(f), same(f));
    });

    test('maps DioException timeout to network timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      // ignore: deprecated_member_use_from_same_package
      final f = FailureMapper.from(err);
      expect(f, const Failure.network(type: NetworkFailure.timeout));
    });

    test('maps unknown exception to UnknownAppFailure', () {
      // ignore: deprecated_member_use_from_same_package
      final f = FailureMapper.from(Exception('x'));
      expect(f, isA<UnknownAppFailure>());
      expect(f.userMessage, isNotEmpty);
    });
  });

  group('FailureMapper2', () {
    test('returns same Failure instance', () {
      const f = Failure.network(type: NetworkFailure.noInternet);
      final mapper = FailureMapper2();
      expect(mapper.from(f), same(f));
    });

    test('maps DioException timeout to network timeout', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      final mapper = FailureMapper2();
      final f = mapper.from(err);
      expect(f, const Failure.network(type: NetworkFailure.timeout));
    });

    test('maps unknown exception to UnknownAppFailure', () {
      final mapper = FailureMapper2();
      final f = mapper.from(Exception('x'));
      expect(f, isA<UnknownAppFailure>());
      expect(f.userMessage, isNotEmpty);
    });

    test('custom mapper has higher priority than built-in', () {
      final customMapper = _CustomTestMapper();
      final mapper = FailureMapper2(extraMappers: [customMapper]);

      final f = mapper.from(Exception('custom'));
      expect(f, isA<NetworkAppFailure>());
      expect(f, const Failure.network(type: NetworkFailure.noInternet));
    });

    test('custom mapper can override built-in mappers', () {
      final customMapper = _OverrideTestMapper();
      final mapper = FailureMapper2(extraMappers: [customMapper]);

      // DioException would normally be handled by DioFailureMapper,
      // but our custom mapper handles it first
      final err = DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionTimeout,
      );
      final f = mapper.from(err);
      expect(f, isA<HttpAppFailure>());
      expect(
        f,
        const Failure.http(
          type: HttpFailure.internalServerError,
          message: 'Custom override',
        ),
      );
    });

    test('register adds mapper at runtime', () {
      final mapper = FailureMapper2();
      mapper.register(_CustomTestMapper());

      final f = mapper.from(Exception('custom'));
      expect(f, isA<NetworkAppFailure>());
    });

    test('registerAll adds multiple mappers', () {
      final mapper = FailureMapper2();
      mapper.registerAll([_CustomTestMapper(), _AnotherTestMapper()]);

      final f = mapper.from(Exception('custom'));
      expect(f, isA<NetworkAppFailure>());
    });

    test('fromStatic works without instance', () {
      final f = FailureMapper2.fromStatic(Exception('test'));
      expect(f, isA<UnknownAppFailure>());
    });

    test('fromStatic returns Failure as-is', () {
      const f = Failure.network(type: NetworkFailure.timeout);
      expect(FailureMapper2.fromStatic(f), same(f));
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

      final f = FailureMapper2.fromStatic(err);

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

      final f = FailureMapper2.fromStatic(err);

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

      final f = FailureMapper2.fromStatic(err);

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

      expect(FailureMapper2.fromStatic(err), isA<AuthAppFailure>());
    });
  });
}

/// Тестовый маппер для проверки приоритета
class _CustomTestMapper implements FailureSubMapper {
  const _CustomTestMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is Exception && error.toString().contains('custom')) {
      return const Failure.network(type: NetworkFailure.noInternet);
    }
    return null;
  }
}

/// Тестовый маппер для проверки переопределения
class _OverrideTestMapper implements FailureSubMapper {
  const _OverrideTestMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      return const Failure.http(
        type: HttpFailure.internalServerError,
        message: 'Custom override',
      );
    }
    return null;
  }
}

/// Еще один тестовый маппер
class _AnotherTestMapper implements FailureSubMapper {
  const _AnotherTestMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    return null;
  }
}
