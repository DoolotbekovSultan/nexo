import 'package:nexo/packages/nexo_errors/types/network_failure.dart';

/// Утилиты для строк, используемые в мапперах ошибок.
extension StringContainsAny on String {
  /// `true`, если строка содержит хотя бы одну из [patterns].
  bool containsAny(Iterable<String> patterns) => patterns.any(contains);
}

/// Маппинг сообщений сокет-ошибок на [NetworkFailure].
///
/// Вынесен из [DioFailureMapper] и [CommonFailureMapper] для устранения
/// дублирования. Использует [StringContainsAny] для анализа ключевых слов.
NetworkFailure mapSocketMessageToNetworkFailure(String? socketMessage) {
  final message = socketMessage?.toLowerCase() ?? '';

  if (message.containsAny(const ['timed out', 'timeout'])) {
    return NetworkFailure.timeout;
  }

  if (message.containsAny(const [
    'failed host lookup',
    'name or service not known',
    'temporary failure in name resolution',
    'dns',
  ])) {
    return NetworkFailure.dnsLookupFailed;
  }

  if (message.containsAny(const ['connection refused'])) {
    return NetworkFailure.connectionRefused;
  }

  if (message.containsAny(const [
    'no route to host',
    'host is down',
    'network is unreachable',
    'host unreachable',
  ])) {
    return NetworkFailure.hostUnreachable;
  }

  if (message.containsAny(const [
    'connection reset',
    'connection reset by peer',
    'broken pipe',
  ])) {
    return NetworkFailure.connectionReset;
  }

  if (message.containsAny(const ['proxy'])) {
    return NetworkFailure.proxyError;
  }

  return NetworkFailure.noInternet;
}
