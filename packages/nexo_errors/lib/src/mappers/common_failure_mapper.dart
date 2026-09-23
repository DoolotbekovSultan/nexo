import 'dart:async';

import 'package:nexo_errors/src/failure.dart';
import 'package:nexo_errors/src/types/http_failure.dart';
import 'package:nexo_errors/src/types/network_failure.dart';
import 'package:nexo_errors/src/types/parse_failure.dart';
import 'package:nexo_errors/src/types/platform_failure.dart';
import 'package:nexo_errors/src/types/validation_failure.dart';
import 'package:nexo_errors/src/mappers/failure_sub_mapper.dart';
import 'package:nexo_errors/src/mappers/platform_exceptions.dart';
import 'package:nexo_errors/src/mappers/socket_failure_mapper.dart';

/// Универсальный маппер ошибок, обрабатывающий типовые Dart-исключения.
///
/// Преобразует [SocketException], [TimeoutException], [FormatException],
/// [UnsupportedError], [ArgumentError], [StateError], [TypeError] и другие
/// стандартные ошибки в соответствующие [Failure]. Также обрабатывает ошибки
/// `dart:io` через условные импорты [PlatformExceptions] для совместимости с web.
///
/// Используется как «последний рубеж» в цепочке мапперов — ловит всё, что не
/// обработано специализированными мапперами (Dio, Firebase, Drift и т.д.).
///
/// См. также: [FailureSubMapper], [DioFailureMapper], [PlatformFailureMapper].
final class CommonFailureMapper implements FailureSubMapper {
  const CommonFailureMapper();

  /// Пытается преобразовать [error] в [Failure] на основе его типа и сообщения.
  ///
  /// Если [error] уже является [Failure], возвращает его без изменений.
  /// Для `dart:io` ошибок использует [PlatformExceptions] для кроссплатформенной
  /// проверки типов.
  ///
  /// **Возвращает:** [Failure] соответствующего типа или `null`, если ошибка
  /// не распознана.
  @override
  Failure? tryMap(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    // `dart:io` types are probed, not pattern-matched: they do not exist on
    // the web and the probes keep evaluation order identical to the previous
    // switch.
    if (PlatformExceptions.isSocketException(error)) {
      return _mapSocketMessage(PlatformExceptions.socketMessage(error));
    }
    if (error is TimeoutException) {
      return const Failure.network(type: NetworkFailure.timeout);
    }
    if (PlatformExceptions.isHandshakeException(error) ||
        PlatformExceptions.isTlsException(error)) {
      return const Failure.network(type: NetworkFailure.badCertificate);
    }
    if (error is FormatException) return _mapFormatException(error);
    if (PlatformExceptions.isHttpException(error)) {
      return _mapHttpMessage(PlatformExceptions.httpMessage(error) ?? '');
    }

    return switch (error) {
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

  /// Преобразует текстовое сообщение сокет-ошибки в соответствующий [Failure].
  Failure _mapSocketMessage(String? socketMessage) {
    final networkFailure = mapSocketMessageToNetworkFailure(socketMessage);

    final message = socketMessage?.toLowerCase() ?? '';

    if (message.containsAny(const ['too many redirects', 'redirect'])) {
      return const Failure.network(type: NetworkFailure.tooManyRedirects);
    }

    if (message.containsAny(const ['invalid url', 'no host specified'])) {
      return const Failure.network(type: NetworkFailure.invalidUrl);
    }

    return Failure.network(type: networkFailure);
  }

  /// Преобразует [FormatException] в [Failure] на основе типа ошибки парсинга.
  ///
  /// Определяет категорию ошибки (JSON, дата, тип) по сообщению исключения.
  Failure _mapFormatException(FormatException error) {
    final message = error.message.toLowerCase();

    if (message.containsAny(const ['json'])) {
      return Failure.parse(
        type: ParseFailure.jsonDecode,
        message: error.message,
      );
    }

    if (message.containsAny(const ['date', 'datetime'])) {
      return Failure.parse(
        type: ParseFailure.invalidDateFormat,
        message: error.message,
      );
    }

    if (message.containsAny(const ['type'])) {
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

  /// Преобразует текстовое сообщение HTTP-ошибки в [Failure] по коду статуса.
  ///
  /// Анализирует ключевые слова в [message] (401, 500, timeout и т.д.)
  /// для определения конкретного типа HTTP-ошибки.
  Failure _mapHttpMessage(String message) {
    final raw = message.toLowerCase();

    if (raw.containsAny(const ['401', 'unauthorized'])) {
      return Failure.http(type: HttpFailure.unauthorized, message: message);
    }

    if (raw.containsAny(const ['403', 'forbidden'])) {
      return Failure.http(type: HttpFailure.forbidden, message: message);
    }

    if (raw.containsAny(const ['404', 'not found'])) {
      return Failure.http(type: HttpFailure.notFound, message: message);
    }

    if (raw.containsAny(const ['408', 'timeout'])) {
      return Failure.http(type: HttpFailure.requestTimeout, message: message);
    }

    if (raw.containsAny(const ['429', 'too many requests'])) {
      return Failure.http(type: HttpFailure.tooManyRequests, message: message);
    }

    if (raw.containsAny(const ['500', 'internal server error'])) {
      return Failure.http(
        type: HttpFailure.internalServerError,
        message: message,
      );
    }

    if (raw.containsAny(const ['502', 'bad gateway'])) {
      return Failure.http(type: HttpFailure.badGateway, message: message);
    }

    if (raw.containsAny(const ['503', 'service unavailable'])) {
      return Failure.http(
        type: HttpFailure.serviceUnavailable,
        message: message,
      );
    }

    if (raw.containsAny(const ['504', 'gateway timeout'])) {
      return Failure.http(type: HttpFailure.gatewayTimeout, message: message);
    }

    return Failure.http(type: HttpFailure.unknown, message: message);
  }
}
