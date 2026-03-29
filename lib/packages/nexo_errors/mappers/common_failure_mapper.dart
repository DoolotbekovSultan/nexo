import 'dart:async';
import 'dart:io';

import '../failure.dart';
import '../types/http_failure.dart';
import '../types/network_failure.dart';
import '../types/parse_failure.dart';
import '../types/platform_failure.dart';
import '../types/validation_failure.dart';
import 'failure_sub_mapper.dart';

final class CommonFailureMapper implements FailureSubMapper {
  const CommonFailureMapper();

  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    return switch (error) {
      SocketException e => _mapSocketException(e),
      TimeoutException _ => const Failure.network(type: NetworkFailure.timeout),
      HandshakeException _ => const Failure.network(
        type: NetworkFailure.badCertificate,
      ),
      TlsException _ => const Failure.network(
        type: NetworkFailure.badCertificate,
      ),
      FormatException e => _mapFormatException(e),
      HttpException e => _mapHttpException(e),
      UnsupportedError e => Failure.platform(
        type: PlatformFailure.notSupported,
        details: e.message,
      ),
      ArgumentError e => Failure.validation(
        type: ValidationFailure.invalidFormat,
        message: e.message?.toString() ?? e.toString(),
      ),
      StateError e => Failure.platform(
        type: PlatformFailure.osError,
        details: e.message,
      ),
      TypeError _ => Failure.parse(
        type: ParseFailure.unexpectedType,
        message: error.toString(),
      ),
      Exception e => Failure.unknown(
        error: e,
        stackTrace: stackTrace,
        message: e.toString(),
      ),
      Error e => Failure.unknown(
        error: e,
        stackTrace: stackTrace,
        message: e.toString(),
      ),
      _ => null,
    };
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

    if (_containsAny(message, const ['too many redirects', 'redirect'])) {
      return const Failure.network(type: NetworkFailure.tooManyRedirects);
    }

    if (_containsAny(message, const ['invalid url', 'no host specified'])) {
      return const Failure.network(type: NetworkFailure.invalidUrl);
    }

    return const Failure.network(type: NetworkFailure.noInternet);
  }

  Failure _mapFormatException(FormatException error) {
    final message = error.message.toLowerCase();

    if (_containsAny(message, const ['json'])) {
      return Failure.parse(
        type: ParseFailure.jsonDecode,
        message: error.message,
      );
    }

    if (_containsAny(message, const ['date', 'datetime'])) {
      return Failure.parse(
        type: ParseFailure.invalidDateFormat,
        message: error.message,
      );
    }

    if (_containsAny(message, const ['type'])) {
      return Failure.parse(
        type: ParseFailure.unexpectedType,
        message: error.message,
      );
    }

    return Failure.parse(
      type: ParseFailure.schemaMismatch,
      message: error.message,
    );
  }

  Failure _mapHttpException(HttpException error) {
    final raw = error.message.toLowerCase();

    if (_containsAny(raw, const ['401', 'unauthorized'])) {
      return Failure.http(
        type: HttpFailure.unauthorized,
        message: error.message,
      );
    }

    if (_containsAny(raw, const ['403', 'forbidden'])) {
      return Failure.http(type: HttpFailure.forbidden, message: error.message);
    }

    if (_containsAny(raw, const ['404', 'not found'])) {
      return Failure.http(type: HttpFailure.notFound, message: error.message);
    }

    if (_containsAny(raw, const ['408', 'timeout'])) {
      return Failure.http(
        type: HttpFailure.requestTimeout,
        message: error.message,
      );
    }

    if (_containsAny(raw, const ['429', 'too many requests'])) {
      return Failure.http(
        type: HttpFailure.tooManyRequests,
        message: error.message,
      );
    }

    if (_containsAny(raw, const ['500', 'internal server error'])) {
      return Failure.http(
        type: HttpFailure.internalServerError,
        message: error.message,
      );
    }

    if (_containsAny(raw, const ['502', 'bad gateway'])) {
      return Failure.http(type: HttpFailure.badGateway, message: error.message);
    }

    if (_containsAny(raw, const ['503', 'service unavailable'])) {
      return Failure.http(
        type: HttpFailure.serviceUnavailable,
        message: error.message,
      );
    }

    if (_containsAny(raw, const ['504', 'gateway timeout'])) {
      return Failure.http(
        type: HttpFailure.gatewayTimeout,
        message: error.message,
      );
    }

    return Failure.http(type: HttpFailure.unknown, message: error.message);
  }

  bool _containsAny(String source, List<String> patterns) {
    for (final pattern in patterns) {
      if (source.contains(pattern)) return true;
    }
    return false;
  }
}
