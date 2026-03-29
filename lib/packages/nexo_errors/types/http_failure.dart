enum HttpFailure {
  // 4xx Client Errors

  /// 400 — Некорректный запрос
  badRequest,

  /// 401 — Не авторизован
  unauthorized,

  /// 402 — Требуется оплата
  paymentRequired,

  /// 403 — Доступ запрещён
  forbidden,

  /// 404 — Ресурс не найден
  notFound,

  /// 405 — Метод не поддерживается
  methodNotAllowed,

  /// 406 — Неприемлемый формат ответа
  notAcceptable,

  /// 407 — Требуется аутентификация прокси
  proxyAuthRequired,

  /// 408 — Таймаут запроса
  requestTimeout,

  /// 409 — Конфликт данных
  conflict,

  /// 410 — Ресурс удалён навсегда
  gone,

  /// 411 — Требуется длина содержимого
  lengthRequired,

  /// 412 — Предварительное условие не выполнено
  preconditionFailed,

  /// 413 — Тело запроса слишком большое
  payloadTooLarge,

  /// 414 — URI слишком длинный
  uriTooLong,

  /// 415 — Неподдерживаемый тип содержимого
  unsupportedMediaType,

  /// 416 — Запрошенный диапазон недоступен
  rangeNotSatisfiable,

  /// 417 — Ожидание не выполнено
  expectationFailed,

  /// 418 — Я чайник (RFC 2324)
  teapot,

  /// 421 — Неверно перенаправленный запрос
  misdirectedRequest,

  /// 422 — Ошибки валидации от сервера
  unprocessableEntity,

  /// 423 — Ресурс заблокирован
  locked,

  /// 424 — Зависимость не выполнена
  failedDependency,

  /// 425 — Слишком рано (Too Early)
  tooEarly,

  /// 426 — Требуется обновление протокола
  upgradeRequired,

  /// 428 — Требуется предварительное условие
  preconditionRequired,

  /// 429 — Слишком много запросов
  tooManyRequests,

  /// 431 — Заголовки запроса слишком большие
  requestHeaderFieldsTooLarge,

  /// 451 — Недоступно по юридическим причинам
  unavailableForLegalReasons,

  // 5xx Server Errors

  /// 500 — Внутренняя ошибка сервера
  internalServerError,

  /// 501 — Метод не реализован на сервере
  notImplemented,

  /// 502 — Плохой шлюз
  badGateway,

  /// 503 — Сервис недоступен
  serviceUnavailable,

  /// 504 — Таймаут шлюза
  gatewayTimeout,

  /// 505 — Версия HTTP не поддерживается
  httpVersionNotSupported,

  /// 506 — Вариант также проводит переговоры
  variantAlsoNegotiates,

  /// 507 — Недостаточно места на сервере
  insufficientStorage,

  /// 508 — Обнаружена петля
  loopDetected,

  /// 510 — Расширение не требуется
  notExtended,

  /// 511 — Требуется сетевая аутентификация
  networkAuthenticationRequired,

  /// Любой другой HTTP-статус с ошибкой
  unknown,
}
