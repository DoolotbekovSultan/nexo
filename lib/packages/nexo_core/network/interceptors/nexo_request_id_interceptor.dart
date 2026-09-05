import 'dart:math';

import 'package:dio/dio.dart';
import 'package:nexo/packages/nexo_errors/mappers/dio_failure_mapper.dart'
    show nexoRequestIdExtraKey;
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Добавляет `x-request-id` к запросу и пишет его в логи ответа / ошибки.
///
/// Идентификатор также сохраняется в `extra`, откуда `DioFailureMapper`
/// прокидывает его в сетевые и HTTP-ошибки (`Failure`) — используйте это,
/// чтобы связывать ошибки UI с логами сервера.
class NexoRequestIdInterceptor extends Interceptor {
  /// Имя заголовка для передачи идентификатора запроса.
  static const String headerName = 'x-request-id';

  /// Ключ `RequestOptions.extra` с идентификатором запроса.
  static const String extraRequestIdKey = nexoRequestIdExtraKey;

  /// Логгер для записи идентификаторов запросов (опционально).
  final NexoLogger? logger;

  /// Функция генерации идентификатора (опционально).
  ///
  /// Если не задана, используется сгенерированный UUID на основе
  /// микросекунд и случайного числа.
  final String Function()? generateId;

  /// Создаёт экземпляр [NexoRequestIdInterceptor].
  ///
  /// [logger] — логгер для записи событий (опционально).
  /// [generateId] — кастомная функция генерации ID (опционально).
  NexoRequestIdInterceptor({this.logger, this.generateId});

  String _nextId() {
    final g = generateId;
    if (g != null) return g();
    final r = Random();
    return '${DateTime.now().microsecondsSinceEpoch}-${r.nextInt(1 << 30)}';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = _nextId();
    options.headers[headerName] = id;
    options.extra[extraRequestIdKey] = id;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log('Response', response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('Error', err.requestOptions);
    handler.next(err);
  }

  void _log(String phase, RequestOptions options) {
    final log = logger;
    if (log == null) return;
    final id = options.extra[extraRequestIdKey]?.toString() ?? '?';
    log.debug('[RequestId] $phase $id ${options.method} ${options.uri}');
  }
}
