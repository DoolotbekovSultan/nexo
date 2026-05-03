import 'dart:math';

import 'package:dio/dio.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

/// Добавляет `x-request-id` к запросу и пишет его в логи ответа / ошибки.
class NexoRequestIdInterceptor extends Interceptor {
  static const String headerName = 'x-request-id';
  static const String extraRequestIdKey = '_nexo_request_id';

  final NexoLogger? logger;
  final String Function()? generateId;

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
