enum NotificationFailure {
  /// Разрешение на уведомления не выдано
  permissionDenied,

  /// Ошибка регистрации push-токена
  tokenRegistrationFailed,

  /// Push-токен устарел / недействителен
  tokenExpired,

  /// Ошибка отправки уведомления
  sendFailed,

  /// Ошибка планирования локального уведомления
  scheduleFailed,

  /// Ошибка отмены уведомления
  cancelFailed,

  /// FCM / APNs недоступен
  serviceUnavailable,

  /// Неверные данные уведомления
  invalidPayload,

  /// Канал уведомлений не найден (Android)
  channelNotFound,
}
