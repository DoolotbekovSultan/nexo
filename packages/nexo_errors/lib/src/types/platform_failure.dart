enum PlatformFailure {
  /// Метод не реализован на платформе
  methodNotImplemented,

  /// Ошибка нативного плагина
  pluginError,

  /// Ошибка операционной системы
  osError,

  /// Устройство не поддерживает функцию
  notSupported,

  /// GPS отключён на устройстве
  gpsDisabled,

  /// Bluetooth отключён на устройстве
  bluetoothDisabled,

  /// NFC отключён на устройстве
  nfcDisabled,

  /// Wi-Fi отключён на устройстве
  wifiDisabled,

  /// Устройство оффлайн
  deviceOffline,

  /// Устройство в режиме полёта
  airplaneModeEnabled,

  /// Ошибка PlatformChannel
  channelError,

  /// Таймаут PlatformChannel
  channelTimeout,

  /// Недостаточно памяти на устройстве
  outOfMemory,

  /// Устройство в режиме экономии энергии
  lowPowerMode,
}
