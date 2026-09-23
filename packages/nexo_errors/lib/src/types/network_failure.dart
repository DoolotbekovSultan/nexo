enum NetworkFailure {
  /// Нет подключения к интернету
  noInternet,

  /// Превышено время ожидания соединения
  timeout,

  /// Недействительный SSL-сертификат
  badCertificate,

  /// Запрос был отменён
  cancelled,

  /// Ошибка DNS — не удалось определить хост
  dnsLookupFailed,

  /// Сервер отклонил соединение
  connectionRefused,

  /// Хост недоступен
  hostUnreachable,

  /// Соединение прервано
  connectionReset,

  /// Ошибка прокси-сервера
  proxyError,

  /// Ошибка VPN
  vpnError,

  /// Слишком много редиректов
  tooManyRedirects,

  /// Неверный URL
  invalidUrl,
}
