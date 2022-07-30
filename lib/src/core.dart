import 'dart:async';

import 'package:logging/logging.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'gen/config.dart';

class DjBot {
  static Logger logger(String name) =>
      Logger('[$name]')..level = BotConfig.logLevel;

  final Iterable<DjBotDelegate> delegates;

  late final Logger _logger;

  TeleDart get client => _client!;

  TeleDart? _client;

  DjBot({
    required this.delegates,
  });

  void start() async {
    _logger = logger('Bot');
    _logger.info('Starting...');

    final User me = await Telegram(BotConfig.token).getMe();

    _client = TeleDart(
      BotConfig.token,
      Event(me.username!),
    );

    client.start();

    _logger.info('Telegram service started');

    for (DjBotDelegate delegate in delegates) await delegate._init(this);

    _logger.info('Started with ${delegates.length} delegates');
  }

  void stop() async {
    for (DjBotDelegate delegate in delegates) await delegate._dispose();

    client.stop();
    _logger.info('Stopped');
  }
}

typedef MessageStreamListener = void Function(TeleDartMessage message);

abstract class DjBotDelegate {
  late final Logger logger;

  TeleDart get client => _bot!.client;

  DjBot? _bot;

  final Map<MessageStreamListener, StreamSubscription<TeleDartMessage>>
      _subscriptions = {};

  Future<void> _init(DjBot bot) async {
    logger = DjBot.logger(
      runtimeType.toString(),
    );

    _bot = bot;
    await init();

    logger.info('Initialized with ${_subscriptions.length} listeners');
  }

  void listen({
    required Stream<TeleDartMessage> stream,
    required MessageStreamListener listener,
  }) {
    if (_subscriptions[listener] is StreamSubscription)
      throw StateError('Listener should not be used multiple times');

    final StreamSubscription<TeleDartMessage> subscription =
        stream.listen(listener);

    _subscriptions[listener] = subscription;
  }

  Future<void> stop(MessageStreamListener listener) async {
    final StreamSubscription? subscription = _subscriptions.remove(listener);

    if (subscription is StreamSubscription) await subscription.cancel();
  }

  Future<void> _dispose() async {
    for (StreamSubscription subscription in _subscriptions.values)
      await subscription.cancel();

    _subscriptions.clear();
    dispose();

    logger.info('Disposed');
  }

  FutureOr<void> init();

  FutureOr<void> dispose() {}
}
