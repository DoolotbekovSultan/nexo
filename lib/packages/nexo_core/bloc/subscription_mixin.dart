import 'dart:async';

mixin SubscriptionMixin {
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  void trackSubscription(StreamSubscription<dynamic> subscription) {
    _subscriptions.add(subscription);
  }

  Future<void> cancelSubscriptions() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
