/// Сначала кэш, при отсутствии — сеть и опционально сохранение в кэш.
Future<T> fetchCacheThenNetwork<T>({
  required Future<T?> Function() loadCache,
  required Future<T> Function() loadNetwork,
  Future<void> Function(T data)? saveCache,
}) async {
  final cached = await loadCache();
  if (cached != null) return cached;
  final fresh = await loadNetwork();
  if (saveCache != null) await saveCache(fresh);
  return fresh;
}

/// Сначала сеть и сохранение в кэш; при ошибке — опционально устаревшие данные из кэша.
Future<T> fetchNetworkThenCache<T>({
  required Future<T> Function() loadNetwork,
  required Future<void> Function(T data) saveCache,
  Future<T?> Function()? onNetworkFailureLoadCache,
}) async {
  try {
    final fresh = await loadNetwork();
    await saveCache(fresh);
    return fresh;
  } catch (_) {
    if (onNetworkFailureLoadCache != null) {
      final stale = await onNetworkFailureLoadCache();
      if (stale != null) return stale;
    }
    rethrow;
  }
}
