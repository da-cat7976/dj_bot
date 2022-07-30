part of dj_bot.core;

abstract class DjBotDelegate {
  @protected
  late final Logger logger;

  @protected
  TeleDart get client => _bot!.client;

  DjBot? _bot;

  Future<void> _init(DjBot bot) async {
    logger = DjBot.logger(
      runtimeType.toString(),
    );

    _bot = bot;
    await init();

    logger.info('Initialized');
  }

  Future<void> _dispose() async {
    await dispose();

    logger.info('Disposed');
  }

  @protected
  FutureOr<void> init();

  @protected
  FutureOr<void> dispose() {}
}

abstract class ListeningDjBotDelegate extends DjBotDelegate {
  late final _TelegramStreamDispatcher _dispatcher;

  @override
  Future<void> _init(DjBot bot) async {
    logger = DjBot.logger(
      runtimeType.toString(),
    );
    _dispatcher = _TelegramStreamDispatcher(logger);

    _bot = bot;
    await init();

    logger.info('Initialized with ${_dispatcher.streamCount} listeners');
  }

  @override
  Future<void> _dispose() async {
    await _dispatcher.dispose();
    await dispose();

    logger.info('Disposed');
  }

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
