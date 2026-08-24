import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/packages/nexo_core/network/interceptors/nexo_logging_interceptor.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

class _CapturingLogger implements NexoLogger {
  final lines = <String>[];

  @override
  void debug(String message) => lines.add(message);

  @override
  void info(String message) => lines.add(message);

  @override
  void warning(String message) => lines.add(message);

  @override
  void error({
    required String message,
    required Object error,
    StackTrace? stackTrace,
  }) => lines.add(message);
}

class _StubAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{"ok":true}',
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

Future<Dio> _dio(NexoLogger logger) async {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.local'))
    ..httpClientAdapter = _StubAdapter()
    ..interceptors.add(NexoLoggingInterceptor(logger: logger));
  return dio;
}

void main() {
  test('Authorization-заголовок и токен в query маскируются', () async {
    final logger = _CapturingLogger();
    final dio = await _dio(logger);

    final response = await dio.get(
      '/items?access_token=SECRET123&q=1',
      options: Options(headers: {'Authorization': 'Bearer SECRET123'}),
    );
    expect(response.statusCode, 200);

    final all = logger.lines.join('\n');

    expect(
      all.contains('SECRET123'),
      isFalse,
      reason: 'токен не должен попасть в лог',
    );
    expect(all.contains('***FILTERED***'), isTrue);
    expect(all.contains('/items?access_token='), isTrue);
  });

  test('пароль в JSON-теле запроса маскируется', () async {
    final logger = _CapturingLogger();
    final dio = await _dio(logger);

    await dio.post('/login', data: {'email': 'a@b.c', 'password': 'hunter2'});

    final all = logger.lines.join('\n');

    expect(all.contains('hunter2'), isFalse);
    expect(
      all.contains('a@b.c'),
      isTrue,
      reason: 'не-чувствительные поля остаются',
    );
  });

  test('обычные query-параметры не маскируются', () async {
    final logger = _CapturingLogger();
    final dio = await _dio(logger);

    await dio.get('/items?page=2&limit=10');

    final all = logger.lines.join('\n');

    expect(all.contains('page=2'), isTrue);
    expect(all.contains('limit=10'), isTrue);
  });

  test('URL без query не изменяется', () async {
    final logger = _CapturingLogger();
    final dio = await _dio(logger);

    await dio.get('/health');

    expect(logger.lines.join('\n').contains('/health'), isTrue);
  });
}
