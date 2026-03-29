import 'dart:async';

mixin SubscriptionMixin {
  final Map<Object, StreamSubscription<dynamic>> _subscriptions = {};

  Future<void> trackSubscription(
    Object key,
    StreamSubscription<dynamic> subscription,
  ) async {
    await _subscriptions[key]?.cancel();
    _subscriptions[key] = subscription;
  }

  Future<void> cancelSubscription(Object key) async {
    final subscription = _subscriptions.remove(key);
    await subscription?.cancel();
  }

  Future<void> cancelSubscriptions() async {
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  bool hasSubscription(Object key) {
    return _subscriptions.containsKey(key);
  }
}
