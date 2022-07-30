part of dj_bot.core;

typedef MessageStreamListener = void Function(TeleDartMessage message);

class _TelegramStreamDispatcher {
  final Logger logger;

  final Map<MessageStreamListener, StreamSubscription<TeleDartMessage>>
      _subscriptions = {};

  int get streamCount => _subscriptions.length;

  _TelegramStreamDispatcher(this.logger);

  void listen({
    required Stream<TeleDartMessage> stream,
    required MessageStreamListener listener,
  }) {
    if (_subscriptions[listener] is StreamSubscription)
      throw StateError('Listener should not be used multiple times');

    final StreamSubscription<TeleDartMessage> subscription = stream.listen(
      (event) {
        final String eventString = JsonEncoder.withIndent('  ').convert(
          event.toJson(),
        );

        logger.finest('Got new message:\n$eventString');
        listener(event);
      },
    );

    _subscriptions[listener] = subscription;
  }

  Future<void> stop(MessageStreamListener listener) async {
    final StreamSubscription? subscription = _subscriptions.remove(listener);

    if (subscription is StreamSubscription) await subscription.cancel();
  }

  Future<void> dispose() async {
    for (StreamSubscription subscription in _subscriptions.values)
      await subscription.cancel();

    _subscriptions.clear();
  }
}
