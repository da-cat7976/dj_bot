import 'package:logging/logging.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'gen/config.dart';

class DjBot {
  static Logger logger(String name) => Logger(name)..level = BotConfig.logLevel;

  final Iterable<DjBotDelegate> delegates;

  TeleDart? _client;

  TeleDart get client => _client!;

  DjBot({
    required this.delegates,
  });

  void start() async {
    final User me = await Telegram(BotConfig.token).getMe();

    _client = TeleDart(
      BotConfig.token,
      Event(me.username!),
    );

    client.start();

    delegates.forEach(_initDelegate);
  }

  void stop() => client.stop();

  void _initDelegate(DjBotDelegate delegate) => delegate._init(this);
}

abstract class DjBotDelegate {
  DjBot? _bot;

  TeleDart get client => _bot!.client;

  void _init(DjBot bot) {
    _bot = bot;
    init();
  }

  void init();

  void dispose();
}
