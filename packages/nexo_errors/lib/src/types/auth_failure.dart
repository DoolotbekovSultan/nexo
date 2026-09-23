enum AuthFailure {
  /// Нет активной сессии
  unauthorized,

  /// Нет прав на действие
  forbidden,

  /// Access-токен истёк
  tokenExpired,

  /// Токен недействителен / повреждён
  tokenInvalid,

  /// Refresh-токен истёк
  refreshTokenExpired,

  /// Refresh-токен недействителен
  refreshTokenInvalid,

  /// Сессия отозвана (выход с другого устройства / блокировка)
  sessionRevoked,

  /// Сессия не найдена
  sessionNotFound,

  /// Неверные учётные данные (логин / пароль)
  wrongCredentials,

  /// Аккаунт заблокирован
  accountBlocked,

  /// Аккаунт временно заблокирован (много неудачных попыток)
  accountTemporarilyLocked,

  /// Аккаунт не подтверждён (email / телефон)
  accountNotVerified,

  /// Аккаунт удалён
  accountDeleted,

  /// Аккаунт не найден
  accountNotFound,

  /// Аккаунт уже существует
  accountAlreadyExists,

  /// Пароль истёк и требует смены
  passwordExpired,

  /// Требуется двухфакторная аутентификация
  twoFactorRequired,

  /// Неверный код двухфакторной аутентификации
  twoFactorFailed,

  /// Код двухфакторной аутентификации истёк
  twoFactorExpired,

  /// Ошибка биометрической аутентификации
  biometricFailed,

  /// Биометрия не настроена на устройстве
  biometricNotAvailable,

  /// Биометрия заблокирована (много неудачных попыток)
  biometricLocked,

  /// Ошибка OAuth провайдера (Google, Apple, Facebook…)
  oauthFailed,

  /// OAuth провайдер отклонил запрос
  oauthDenied,

  /// Неверный OAuth токен
  oauthTokenInvalid,

  /// Аккаунт не привязан к OAuth провайдеру
  oauthAccountNotLinked,
}
