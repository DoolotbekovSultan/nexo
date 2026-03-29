enum PermissionFailure {
  /// Пользователь отклонил разрешение
  denied,

  /// Пользователь отклонил навсегда (нужно открыть настройки)
  permanentlyDenied,

  /// Ограничено системой (родительский контроль и т.д.)
  restricted,

  /// Разрешение ещё не запрошено
  notDetermined,

  /// Камера
  cameraDenied,

  /// Микрофон
  microphoneDenied,

  /// Геолокация
  locationDenied,

  /// Геолокация всегда (фоновый режим)
  locationAlwaysDenied,

  /// Уведомления
  notificationDenied,

  /// Контакты
  contactsDenied,

  /// Хранилище / галерея
  storageDenied,

  /// Календарь
  calendarDenied,

  /// Bluetooth
  bluetoothDenied,

  /// Отслеживание активности (HealthKit / Activity)
  activityDenied,

  /// Отслеживание (App Tracking Transparency — iOS)
  trackingDenied,

  /// Распознавание речи
  speechRecognitionDenied,

  /// Биометрия
  biometricDenied,

  /// NFC
  nfcDenied,
}
