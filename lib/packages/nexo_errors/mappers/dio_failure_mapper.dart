import 'dart:io';

import 'package:dio/dio.dart';

import '../failure.dart';
import '../types/auth_failure.dart';
import '../types/http_failure.dart';
import '../types/network_failure.dart';
import '../types/parse_failure.dart';
import '../types/validation_failure.dart';
import 'failure_sub_mapper.dart';

final class DioFailureMapper implements FailureSubMapper {
  const DioFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is! DioException) return null;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Failure.network(type: NetworkFailure.timeout);

      case DioExceptionType.badCertificate:
        return const Failure.network(type: NetworkFailure.badCertificate);

      case DioExceptionType.cancel:
        return const Failure.network(type: NetworkFailure.cancelled);

      case DioExceptionType.connectionError:
        final inner = error.error;

        if (inner is SocketException) {
          return _mapSocketException(inner);
        }

        final raw = '${error.message} ${inner ?? ''}'.toLowerCase();

        if (_containsAny(raw, const [
          'dns',
          'failed host lookup',
          'name or service not known',
        ])) {
          return const Failure.network(type: NetworkFailure.dnsLookupFailed);
        }

        if (_containsAny(raw, const ['connection refused'])) {
          return const Failure.network(type: NetworkFailure.connectionRefused);
        }

        if (_containsAny(raw, const [
          'connection reset',
          'connection reset by peer',
        ])) {
          return const Failure.network(type: NetworkFailure.connectionReset);
        }

        if (_containsAny(raw, const ['proxy'])) {
          return const Failure.network(type: NetworkFailure.proxyError);
        }

        return const Failure.network(type: NetworkFailure.hostUnreachable);

      case DioExceptionType.badResponse:
        return _mapBadResponse(error);

      case DioExceptionType.unknown:
        final inner = error.error;

        if (inner is SocketException) {
          return _mapSocketException(inner);
        }

        if (inner is HandshakeException || inner is TlsException) {
          return const Failure.network(type: NetworkFailure.badCertificate);
        }

        if (inner is FormatException) {
          return Failure.parse(
            type: ParseFailure.jsonDecode,
            message: inner.message,
          );
        }

        final raw = '${error.message} ${inner ?? ''}'.toLowerCase();

        if (_containsAny(raw, const ['timed out', 'timeout'])) {
          return const Failure.network(type: NetworkFailure.timeout);
        }

        return Failure.unknown(
          error: error,
          stackTrace: stackTrace,
          message: error.message ?? error.toString(),
        );
    }
  }

  Failure _mapBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    final message = _extractMessage(data) ?? error.message;
    final fieldErrors = _extractFieldErrors(data);
    final httpType = _mapStatusCode(statusCode);

    if (httpType == HttpFailure.unauthorized) {
      return Failure.auth(
        type: _extractAuthFailure(data) ?? AuthFailure.unauthorized,
        message: message,
      );
    }

    if (httpType == HttpFailure.forbidden) {
      return Failure.auth(
        type: _extractAuthFailure(data) ?? AuthFailure.forbidden,
        message: message,
      );
    }

    if (httpType == HttpFailure.unprocessableEntity) {
      return Failure.validation(
        type: ValidationFailure.serverValidation,
        message: message,
        fieldErrors: fieldErrors,
      );
    }

    return Failure.http(
      type: httpType,
      statusCode: statusCode,
      message: message,
      fieldErrors: fieldErrors,
    );
  }

  Failure _mapSocketException(SocketException error) {
    final message = error.message.toLowerCase();

    if (_containsAny(message, const ['timed out', 'timeout'])) {
      return const Failure.network(type: NetworkFailure.timeout);
    }

    if (_containsAny(message, const [
      'failed host lookup',
      'name or service not known',
      'temporary failure in name resolution',
      'dns',
    ])) {
      return const Failure.network(type: NetworkFailure.dnsLookupFailed);
    }

    if (_containsAny(message, const ['connection refused'])) {
      return const Failure.network(type: NetworkFailure.connectionRefused);
    }

    if (_containsAny(message, const [
      'no route to host',
      'host is down',
      'network is unreachable',
      'host unreachable',
    ])) {
      return const Failure.network(type: NetworkFailure.hostUnreachable);
    }

    if (_containsAny(message, const [
      'connection reset',
      'connection reset by peer',
      'broken pipe',
    ])) {
      return const Failure.network(type: NetworkFailure.connectionReset);
    }

    if (_containsAny(message, const ['proxy'])) {
      return const Failure.network(type: NetworkFailure.proxyError);
    }

    return const Failure.network(type: NetworkFailure.noInternet);
  }

  HttpFailure _mapStatusCode(int? code) {
    return switch (code) {
      400 => HttpFailure.badRequest,
      401 => HttpFailure.unauthorized,
      402 => HttpFailure.paymentRequired,
      403 => HttpFailure.forbidden,
      404 => HttpFailure.notFound,
      405 => HttpFailure.methodNotAllowed,
      406 => HttpFailure.notAcceptable,
      407 => HttpFailure.proxyAuthRequired,
      408 => HttpFailure.requestTimeout,
      409 => HttpFailure.conflict,
      410 => HttpFailure.gone,
      411 => HttpFailure.lengthRequired,
      412 => HttpFailure.preconditionFailed,
      413 => HttpFailure.payloadTooLarge,
      414 => HttpFailure.uriTooLong,
      415 => HttpFailure.unsupportedMediaType,
      416 => HttpFailure.rangeNotSatisfiable,
      417 => HttpFailure.expectationFailed,
      418 => HttpFailure.teapot,
      421 => HttpFailure.misdirectedRequest,
      422 => HttpFailure.unprocessableEntity,
      423 => HttpFailure.locked,
      424 => HttpFailure.failedDependency,
      425 => HttpFailure.tooEarly,
      426 => HttpFailure.upgradeRequired,
      428 => HttpFailure.preconditionRequired,
      429 => HttpFailure.tooManyRequests,
      431 => HttpFailure.requestHeaderFieldsTooLarge,
      451 => HttpFailure.unavailableForLegalReasons,
      500 => HttpFailure.internalServerError,
      501 => HttpFailure.notImplemented,
      502 => HttpFailure.badGateway,
      503 => HttpFailure.serviceUnavailable,
      504 => HttpFailure.gatewayTimeout,
      505 => HttpFailure.httpVersionNotSupported,
      506 => HttpFailure.variantAlsoNegotiates,
      507 => HttpFailure.insufficientStorage,
      508 => HttpFailure.loopDetected,
      510 => HttpFailure.notExtended,
      511 => HttpFailure.networkAuthenticationRequired,
      _ => HttpFailure.unknown,
    };
  }

  AuthFailure? _extractAuthFailure(dynamic data) {
    final code = _extractErrorCode(data)?.toLowerCase();
    if (code == null) return null;

    if (_containsAny(code, const ['token_expired', 'access_token_expired'])) {
      return AuthFailure.tokenExpired;
    }
    if (_containsAny(code, const ['token_invalid', 'invalid_token'])) {
      return AuthFailure.tokenInvalid;
    }
    if (_containsAny(code, const ['refresh_token_expired'])) {
      return AuthFailure.refreshTokenExpired;
    }
    if (_containsAny(code, const ['refresh_token_invalid'])) {
      return AuthFailure.refreshTokenInvalid;
    }
    if (_containsAny(code, const ['session_revoked'])) {
      return AuthFailure.sessionRevoked;
    }
    if (_containsAny(code, const ['session_not_found'])) {
      return AuthFailure.sessionNotFound;
    }
    if (_containsAny(code, const [
      'wrong_credentials',
      'invalid_credentials',
    ])) {
      return AuthFailure.wrongCredentials;
    }
    if (_containsAny(code, const ['account_blocked'])) {
      return AuthFailure.accountBlocked;
    }
    if (_containsAny(code, const ['temporarily_locked', 'account_locked'])) {
      return AuthFailure.accountTemporarilyLocked;
    }
    if (_containsAny(code, const ['account_not_verified'])) {
      return AuthFailure.accountNotVerified;
    }
    if (_containsAny(code, const ['account_deleted'])) {
      return AuthFailure.accountDeleted;
    }
    if (_containsAny(code, const ['account_not_found', 'user_not_found'])) {
      return AuthFailure.accountNotFound;
    }
    if (_containsAny(code, const [
      'account_already_exists',
      'already_exists',
    ])) {
      return AuthFailure.accountAlreadyExists;
    }
    if (_containsAny(code, const ['password_expired'])) {
      return AuthFailure.passwordExpired;
    }
    if (_containsAny(code, const ['2fa_required', 'two_factor_required'])) {
      return AuthFailure.twoFactorRequired;
    }
    if (_containsAny(code, const ['2fa_failed', 'two_factor_failed'])) {
      return AuthFailure.twoFactorFailed;
    }
    if (_containsAny(code, const ['2fa_expired', 'two_factor_expired'])) {
      return AuthFailure.twoFactorExpired;
    }
    if (_containsAny(code, const ['oauth_failed'])) {
      return AuthFailure.oauthFailed;
    }
    if (_containsAny(code, const ['oauth_denied'])) {
      return AuthFailure.oauthDenied;
    }
    if (_containsAny(code, const ['oauth_token_invalid'])) {
      return AuthFailure.oauthTokenInvalid;
    }
    if (_containsAny(code, const ['oauth_account_not_linked'])) {
      return AuthFailure.oauthAccountNotLinked;
    }

    return null;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = [
        data['message'],
        data['error'],
        data['detail'],
        data['description'],
        data['title'],
      ];

      for (final candidate in candidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return null;
  }

  String? _extractErrorCode(dynamic data) {
    if (data is! Map<String, dynamic>) return null;

    final candidates = [
      data['code'],
      data['errorCode'],
      data['error_code'],
      data['type'],
      data['key'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return null;
  }

  Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return const {};

    final raw = data['errors'] ?? data['fieldErrors'] ?? data['field_errors'];
    if (raw is! Map) return const {};

    final result = <String, List<String>>{};

    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      if (value is List) {
        result[key] = value.map((e) => e.toString()).toList();
      } else if (value is Map) {
        result[key] = value.values.map((e) => e.toString()).toList();
      } else if (value != null) {
        result[key] = [value.toString()];
      }
    }

    return result;
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
