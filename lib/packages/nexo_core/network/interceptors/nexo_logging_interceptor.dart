import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:nexo/packages/nexo_logger/nexo_logger.dart';

class NexoLoggingInterceptor extends Interceptor {
  static const String _startedAtKey = '_nexo_request_started_at';
  static const String _isLoggingKey = '_nexo_is_logging';
  static const int _maxBodyLength = 2000;

  final NexoLogger logger;

  final bool logRequests;
  final bool logRequestHeaders;
  final bool logRequestBody;

  final bool logResponses;
  final bool logResponseHeaders;
  final bool logResponseBody;

  final bool logErrors;
  final bool logErrorResponseBody;

  final Set<String> sensitiveFields;

  const NexoLoggingInterceptor({
    required this.logger,
    this.logRequests = true,
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponses = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.logErrors = true,
    this.logErrorResponseBody = true,
    this.sensitiveFields = const {
      'password',
      'token',
      'access_token',
      'refresh_token',
      'authorization',
      'cookie',
      'set-cookie',
      'secret',
      'api_key',
      'apikey',
    },
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAtKey] = DateTime.now();

    if (!logRequests || options.extra[_isLoggingKey] == true) {
      handler.next(options);
      return;
    }

    _safeLog(() {
      final buffer = StringBuffer()
        ..writeln('HTTP REQUEST')
        ..writeln('${options.method} ${options.uri}');

      if (logRequestHeaders) {
        buffer
          ..writeln('Headers:')
          ..writeln(_formatValue(_filterSensitiveData(options.headers)));
      }

      if (logRequestBody && options.data != null) {
        buffer
          ..writeln('Body:')
          ..writeln(_formatValue(_filterSensitiveData(options.data)));
      }

      logger.debug(buffer.toString());
    }, options);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;

    if (!logResponses || options.extra[_isLoggingKey] == true) {
      handler.next(response);
      return;
    }

    _safeLog(() {
      final duration = _getDuration(options);

      final buffer = StringBuffer()
        ..writeln('HTTP RESPONSE')
        ..writeln('${options.method} ${options.uri}')
        ..writeln('Status: ${response.statusCode}')
        ..writeln('Time: ${_formatDuration(duration)}');

      if (logResponseHeaders) {
        buffer
          ..writeln('Headers:')
          ..writeln(
            _formatValue(
              _filterSensitiveData(_normalizeHeaders(response.headers)),
            ),
          );
      }

      if (logResponseBody && response.data != null) {
        buffer
          ..writeln('Body:')
          ..writeln(_formatValue(_filterSensitiveData(response.data)));
      }

      logger.info(buffer.toString());
    }, options);

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;

    if (!logErrors || options.extra[_isLoggingKey] == true) {
      handler.next(err);
      return;
    }

    _safeLog(() {
      final duration = _getDuration(options);

      final buffer = StringBuffer()
        ..writeln('HTTP ERROR')
        ..writeln('${options.method} ${options.uri}')
        ..writeln('Status: ${err.response?.statusCode}')
        ..writeln('Time: ${_formatDuration(duration)}')
        ..writeln('Type: ${err.type}')
        ..writeln('Message: ${err.message}');

      if (logErrorResponseBody && err.response?.data != null) {
        buffer
          ..writeln('Response Body:')
          ..writeln(_formatValue(_filterSensitiveData(err.response?.data)));
      }

      logger.error(
        message: buffer.toString(),
        error: err,
        stackTrace: err.stackTrace,
      );
    }, options);

    handler.next(err);
  }

  void _safeLog(void Function() action, RequestOptions options) {
    if (options.extra[_isLoggingKey] == true) return;

    options.extra[_isLoggingKey] = true;

    try {
      action();
    } catch (_) {
      // Logging should never break network flow.
    } finally {
      options.extra[_isLoggingKey] = false;
    }
  }

  Duration? _getDuration(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey];

    if (startedAt is DateTime) {
      return DateTime.now().difference(startedAt);
    }

    return null;
  }

  Map<String, String> _normalizeHeaders(Headers headers) {
    return headers.map.map(
      (key, value) => MapEntry(key, value.join(', ')),
    );
  }

  dynamic _filterSensitiveData(dynamic data) {
    if (data == null) return null;

    if (data is FormData) {
      return {
        'fields': _filterSensitiveData(Map.fromEntries(data.fields)),
        'files': data.files.map((file) {
          return {
            'field': file.key,
            'filename': file.value.filename,
            'contentType': file.value.contentType?.toString(),
            'length': file.value.length,
          };
        }).toList(),
      };
    }

    if (data is Map) {
      return data.map((key, value) {
        final keyString = key.toString();

        if (_isSensitiveField(keyString)) {
          return MapEntry(key, '***FILTERED***');
        }

        return MapEntry(key, _filterSensitiveData(value));
      });
    }

    if (data is List<int>) {
      return '<binary data: ${data.length} bytes>';
    }

    if (data is List) {
      return data.map(_filterSensitiveData).toList();
    }

    if (data is String) {
      return _filterSensitiveString(data);
    }

    return data;
  }

  String _filterSensitiveString(String value) {
    final trimmed = value.trim();

    if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
      try {
        final decoded = jsonDecode(trimmed);
        return jsonEncode(_filterSensitiveData(decoded));
      } catch (_) {
        return _maskSensitiveValues(value);
      }
    }

    return _maskSensitiveValues(value);
  }

  String _maskSensitiveValues(String value) {
    var result = value;

    for (final field in sensitiveFields) {
      final escaped = RegExp.escape(field);

      result = result.replaceAllMapped(
        RegExp(
          '("$escaped"\\s*:\\s*")([^"]*)(")',
          caseSensitive: false,
        ),
        (match) => '${match.group(1)}***FILTERED***${match.group(3)}',
      );

      result = result.replaceAllMapped(
        RegExp(
          '($escaped\\s*=\\s*)([^&\\s]+)',
          caseSensitive: false,
        ),
        (match) => '${match.group(1)}***FILTERED***',
      );
    }

    return result;
  }

  bool _isSensitiveField(String fieldName) {
    final lowerField = fieldName.toLowerCase();

    return sensitiveFields.any(
      (sensitive) => lowerField.contains(sensitive.toLowerCase()),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'unknown';

    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }

    return '${(duration.inMilliseconds / 1000).toStringAsFixed(2)}s';
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';

    try {
      final text = value.toString();

      if (text.length > _maxBodyLength) {
        return '${text.substring(0, _maxBodyLength)}... [truncated]';
      }

      return text;
    } catch (_) {
      return '<unprintable>';
    }
  }
}