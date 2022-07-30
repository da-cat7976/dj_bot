part of dj_bot.core;

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

  DjBotDelegate delegateOf<DelegateType extends DjBotDelegate>() {
    for (DjBotDelegate delegate in delegates)
      if (delegate is DelegateType) return delegate;

    throw ArgumentError('No such delegate');
  }
}
