enum LocationFailure {
  /// Разрешение на геолокацию не выдано
  permissionDenied,

  /// Разрешение на геолокацию отклонено навсегда
  permissionPermanentlyDenied,

  /// GPS отключён
  gpsDisabled,

  /// Не удалось получить местоположение
  locationUnavailable,

  /// Таймаут получения местоположения
  timeout,

  /// Ошибка геокодирования (координаты → адрес)
  geocodingFailed,

  /// Ошибка обратного геокодирования (адрес → координаты)
  reverseGeocodingFailed,

  /// Неверный формат координат
  invalidCoordinates,

  /// Местоположение за пределами допустимой зоны
  outOfBounds,
}
