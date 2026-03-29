enum PaymentFailure {
  /// Платёж отклонён банком
  declined,

  /// Недостаточно средств
  insufficientFunds,

  /// Карта заблокирована
  cardBlocked,

  /// Карта истекла
  cardExpired,

  /// Неверный CVV
  invalidCvv,

  /// Неверный номер карты
  invalidCardNumber,

  /// Неверный PIN
  invalidPin,

  /// Превышен лимит транзакций
  limitExceeded,

  /// Платёж отменён пользователем
  cancelledByUser,

  /// Таймаут платежа
  timeout,

  /// Ошибка платёжного шлюза
  gatewayError,

  /// 3D Secure аутентификация провалилась
  threeDSecureFailed,

  /// Транзакция уже существует
  duplicateTransaction,

  /// Возврат средств провалился
  refundFailed,

  /// Платёжный сервис недоступен
  serviceUnavailable,

  /// Неверная валюта
  invalidCurrency,

  /// Сумма вне допустимого диапазона
  invalidAmount,
}
