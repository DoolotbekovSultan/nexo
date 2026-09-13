import 'package:dio/dio.dart';

import '../failure.dart';
import '../types/auth_failure.dart';
import '../types/http_failure.dart';
import '../types/network_failure.dart';
import '../types/parse_failure.dart';
import '../types/validation_failure.dart';
import 'failure_sub_mapper.dart';
import 'platform_exceptions.dart';
import 'socket_failure_mapper.dart';

/// Ключ `RequestOptions.extra`, под которым `NexoRequestIdInterceptor`
/// сохраняет идентификатор запроса; [DioFailureMapper] читает его оттуда.
const String nexoRequestIdExtraKey = '_nexo_request_id';

/// Специализированный маппер ошибок HTTP-клиента Dio.
///
/// Преобразует [DioException] всех типов (timeout, badResponse, connectionError
/// и т.д.) в соответствующие [Failure]: сетевые, HTTP, аутентификации,
/// валидации или парсинга. Извлекает `x-request-id` из [RequestOptions.extra]
/// для связи ошибок с логами сервера.
///
/// Используется в цепочке [FailureSubMapper] при работе с Dio-клиентом.
///
/// См. также: [FailureSubMapper], [CommonFailureMapper].
final class DioFailureMapper implements FailureSubMapper {
  const DioFailureMapper();

  /// Пытается преобразовать [error] в [Failure], если это [DioException].
  ///
  /// Для не-Dio ошибок возвращает `null`. Прокидывает `x-request-id` в
  /// сетевые и HTTP-ошибки.
  ///
  /// **Возвращает:** [Failure] или `null`, если [error] не является [DioException].
  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is! DioException) return null;

    final mapped = _tryMapInner(error, stackTrace);
    return _attachRequestId(mapped, error);
  }

  /// Прокидывает `x-request-id` из [DioException.requestOptions] в
  /// сетевые и HTTP-ошибки, чтобы связывать их с логами и сервером.
  Failure? _attachRequestId(Failure? failure, DioException error) {
    if (failure == null) return null;

    final id = error.requestOptions.extra[nexoRequestIdExtraKey];
    if (id is! String || id.isEmpty) return failure;

    if (failure case final NetworkAppFailure f) {
      return f.copyWith(requestId: id);
    }
    if (failure case final HttpAppFailure f) {
      return f.copyWith(requestId: id);
    }
    return failure;
  }

  /// Внутренняя логика маппинга [DioException] в [Failure].
  ///
  /// Обрабатывает все типы [DioExceptionType]: timeout, badCertificate, cancel,
  /// connectionError, badResponse, unknown. Для connectionError и unknown
  /// дополнительно анализирует вложенное исключение.
  Failure? _tryMapInner(DioException error, [StackTrace? stackTrace]) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const Failure.network(type: NetworkFailure.timeout);

      case DioExceptionType.badCertificate:
        return const Failure.network(type: NetworkFailure.badCertificate);

      case DioExceptionType.cancel:
        return const Failure.network(type: NetworkFailure.cancelled);

      case DioExceptionType.connectionError:
        final inner = error.error;

        if (PlatformExceptions.isSocketException(inner)) {
          return _mapSocketMessage(PlatformExceptions.socketMessage(inner));
        }

        final raw = '${error.message} ${inner ?? ''}'.toLowerCase();

        if (raw.containsAny(const [
          'dns',
          'failed host lookup',
          'name or service not known',
        ])) {
          return const Failure.network(type: NetworkFailure.dnsLookupFailed);
        }

        if (raw.containsAny(const ['connection refused'])) {
          return const Failure.network(type: NetworkFailure.connectionRefused);
        }

        if (raw.containsAny(const [
          'connection reset',
          'connection reset by peer',
        ])) {
          return const Failure.network(type: NetworkFailure.connectionReset);
        }

        if (raw.containsAny(const ['proxy'])) {
          return const Failure.network(type: NetworkFailure.proxyError);
        }

        return const Failure.network(type: NetworkFailure.hostUnreachable);

      case DioExceptionType.badResponse:
        return _mapBadResponse(error);

      case DioExceptionType.unknown:
        final inner = error.error;

        if (PlatformExceptions.isSocketException(inner)) {
          return _mapSocketMessage(PlatformExceptions.socketMessage(inner));
        }

        if (PlatformExceptions.isHandshakeException(inner) ||
            PlatformExceptions.isTlsException(inner)) {
          return const Failure.network(type: NetworkFailure.badCertificate);
        }

        if (inner is FormatException) {
          return Failure.parse(
            type: ParseFailure.jsonDecode,
            message: inner.message,
          );
        }

        final raw = '${error.message} ${inner ?? ''}'.toLowerCase();

        if (raw.containsAny(const ['timed out', 'timeout'])) {
          return const Failure.network(type: NetworkFailure.timeout);
        }

        return Failure.unknown(
          error: error,
          stackTrace: stackTrace,
          message: error.message ?? error.toString(),
        );
    }
  }

  /// Маппит [DioException] с типом [DioExceptionType.badResponse] в [Failure].
  ///
  /// Извлекает код статуса, тело ответа, сообщение об ошибке и ошибки полей.
  /// Для 401/403 возвращает [Failure.auth], для 422 — [Failure.validation],
  /// для остальных — [Failure.http].
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

  /// Преобразует текстовое сообщение сокет-ошибки в [Failure].
  Failure _mapSocketMessage(String? socketMessage) =>
      Failure.network(type: mapSocketMessageToNetworkFailure(socketMessage));

  /// Преобразует HTTP-код статуса в соответствующий [HttpFailure].
  ///
  /// Поддерживает полный спектр кодов от 400 до 511. Для неизвестных кодов
  /// возвращает [HttpFailure.unknown].
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

  /// Коды ошибок авторизации → [AuthFailure].
  static const _authCodeMap = <String, AuthFailure>{
    'token_expired': AuthFailure.tokenExpired,
    'access_token_expired': AuthFailure.tokenExpired,
    'token_invalid': AuthFailure.tokenInvalid,
    'invalid_token': AuthFailure.tokenInvalid,
    'refresh_token_expired': AuthFailure.refreshTokenExpired,
    'refresh_token_invalid': AuthFailure.refreshTokenInvalid,
    'session_revoked': AuthFailure.sessionRevoked,
    'session_not_found': AuthFailure.sessionNotFound,
    'wrong_credentials': AuthFailure.wrongCredentials,
    'invalid_credentials': AuthFailure.wrongCredentials,
    'account_blocked': AuthFailure.accountBlocked,
    'temporarily_locked': AuthFailure.accountTemporarilyLocked,
    'account_locked': AuthFailure.accountTemporarilyLocked,
    'account_not_verified': AuthFailure.accountNotVerified,
    'account_deleted': AuthFailure.accountDeleted,
    'account_not_found': AuthFailure.accountNotFound,
    'user_not_found': AuthFailure.accountNotFound,
    'account_already_exists': AuthFailure.accountAlreadyExists,
    'already_exists': AuthFailure.accountAlreadyExists,
    'password_expired': AuthFailure.passwordExpired,
    '2fa_required': AuthFailure.twoFactorRequired,
    'two_factor_required': AuthFailure.twoFactorRequired,
    '2fa_failed': AuthFailure.twoFactorFailed,
    'two_factor_failed': AuthFailure.twoFactorFailed,
    '2fa_expired': AuthFailure.twoFactorExpired,
    'two_factor_expired': AuthFailure.twoFactorExpired,
    'oauth_failed': AuthFailure.oauthFailed,
    'oauth_denied': AuthFailure.oauthDenied,
    'oauth_token_invalid': AuthFailure.oauthTokenInvalid,
    'oauth_account_not_linked': AuthFailure.oauthAccountNotLinked,
  };

  /// Извлекает [AuthFailure] из тела ответа по полю `code` / `errorCode`.
  AuthFailure? _extractAuthFailure(dynamic data) {
    final code = _extractErrorCode(data)?.toLowerCase();
    if (code == null) return null;

    for (final entry in _authCodeMap.entries) {
      if (code.contains(entry.key)) return entry.value;
    }

    return null;
  }

  /// Извлекает текстовое сообщение об ошибке из тела ответа.
  ///
  /// Проверяет поля `message`, `error`, `detail`, `description`, `title`
  /// в JSON-ответе или использует строковое значение [data] как есть.
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

  /// Извлекает строковый код ошибки из тела ответа.
  ///
  /// Проверяет поля `code`, `errorCode`, `error_code`, `type`, `key`
  /// в JSON-ответе сервера.
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

  /// Извлекает ошибки валидации по полям из тела ответа.
  Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return const {};

    final raw = data['errors'] ?? data['fieldErrors'] ?? data['field_errors'];
    if (raw is! Map) return const {};

    return {
      for (final entry in raw.entries)
        if (entry.value != null)
          entry.key.toString(): switch (entry.value) {
            List l => l.map((e) => e.toString()).toList(),
            Map m => m.values.map((e) => e.toString()).toList(),
            _ => [entry.value.toString()],
          },
    };
  }
}
