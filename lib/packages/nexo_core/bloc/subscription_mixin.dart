import 'dart:async';

/// Миксин для управления потоковыми подписками с возможностью отмены по ключу.
///
/// Используется в [NexoCubit] для автоматического управления подписками на потоки.
/// Позволяет отменять предыдущую подписку при повторной подписке с тем же ключом,
/// что предотвращает утечки памяти и гонки данных.
///
/// ## Методы
///
/// - [trackSubscription] — добавляет подписку под ключом, отменяя предыдущую.
/// - [cancelSubscription] — отменяет подписку по ключу.
/// - [cancelSubscriptions] — отменяет все подписки.
/// - [hasSubscription] — проверяет наличие подписки по ключу.
///
/// ## Пример
///
/// ```dart
/// class MyCubit extends Cubit<State> with SubscriptionMixin {
///   void subscribeToStream() {
///     final subscription = stream.listen((data) => emit(State.loaded(data)));
///     trackSubscription('my_stream', subscription);
///   }
/// }
/// ```
///
/// См. также: [NexoCubit].
mixin SubscriptionMixin {
  final Map<Object, StreamSubscription<dynamic>> _subscriptions = {};

  /// Отслеживает подписку по ключу, отменяя предыдущую подписку с тем же ключом.
  ///
  /// [key] — уникальный идентификатор подписки.
  /// [subscription] — подписка на поток для отслеживания.
  ///
  /// Если подписка с таким ключом уже существует, она будет отменена перед
  /// сохранением новой. Это предотвращает утечки памяти при повторной подписке.
  ///
  /// **Возвращает:** [Future], который завершается после отмены предыдущей подписки.
  Future<void> trackSubscription(
    Object key,
    StreamSubscription<dynamic> subscription,
  ) async {
    await _subscriptions[key]?.cancel();
    _subscriptions[key] = subscription;
  }

  /// Отменяет подписку по ключу.
  ///
  /// [key] — уникальный идентификатор подписки для отмены.
  ///
  /// Если подписка с указанным ключом не найдена, метод ничего не делает.
  ///
  /// **Возвращает:** [Future], который завершается после отмены подписки.
  Future<void> cancelSubscription(Object key) async {
    final subscription = _subscriptions.remove(key);
    await subscription?.cancel();
  }

  /// Отменяет все активные подписки и очищает внутреннюю таблицу.
  ///
  /// **Возвращает:** [Future], который завершается после отмены всех подписок.
  ///
  /// Обычно вызывается в методе `close()` Cubit/Bloc.
  Future<void> cancelSubscriptions() async {
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }

  /// Проверяет, существует ли активная подписка с указанным ключом.
  ///
  /// [key] — уникальный идентификатор подписки для проверки.
  ///
  /// **Возвращает:** `true`, если подписка с таким ключом существует и активна;
  /// `false` в противном случае.
  bool hasSubscription(Object key) {
    return _subscriptions.containsKey(key);
  }
}
