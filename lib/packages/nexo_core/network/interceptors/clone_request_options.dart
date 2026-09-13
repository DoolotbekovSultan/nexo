import 'package:dio/dio.dart';

/// Клонирует [RequestOptions] в новый [Options], сохраняя метод,
/// заголовки, extra и прочие параметры.
///
/// Используется в [NexoAuthInterceptor] и [NexoRetryInterceptor]
/// для повторных запросов с обновлёнными заголовками/extra.
Options cloneRequestOptions(
  RequestOptions options, {
  Map<String, dynamic>? headers,
  Map<String, dynamic>? extra,
}) => Options(
  method: options.method,
  headers: headers ?? options.headers,
  extra: extra ?? options.extra,
  responseType: options.responseType,
  contentType: options.contentType,
  followRedirects: options.followRedirects,
  receiveDataWhenStatusError: options.receiveDataWhenStatusError,
  validateStatus: options.validateStatus,
  receiveTimeout: options.receiveTimeout,
  sendTimeout: options.sendTimeout,
);
