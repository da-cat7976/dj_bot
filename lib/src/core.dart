import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
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
  @protected
  late final Logger logger;

  late final _TelegramStreamDispatcher _dispatcher;

  @protected
  TeleDart get client => _bot!.client;

  DjBot? _bot;

  Future<void> _init(DjBot bot) async {
    logger = DjBot.logger(
      runtimeType.toString(),
    );
    _dispatcher = _TelegramStreamDispatcher(logger);

    _bot = bot;
    await init();

    logger.info('Initialized with ${_dispatcher.streamCount} listeners');
  }

  Future<void> _dispose() async {
    await _dispatcher.dispose();
    await dispose();

    logger.info('Disposed');
  }

  @protected
  FutureOr<void> init();

  @protected
  FutureOr<void> dispose() {}

  @protected
  void listen({
    required Stream<TeleDartMessage> stream,
    required MessageStreamListener listener,
  }) =>
      _dispatcher.listen(
        stream: stream,
        listener: listener,
      );

  @protected
  void stop(MessageStreamListener listener) => _dispatcher.stop(listener);
}

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
