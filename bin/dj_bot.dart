import 'package:dj_bot/src/actions/link.dart';
import 'package:dj_bot/src/core/lib.dart';
import 'package:dj_bot/src/gen/config.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';

void main() {
  hierarchicalLoggingEnabled = true;
  PrintAppender.setupLogging(level: BotConfig.logLevel);

  DjBot(
    delegates: [
      LinkAction(),
    ],
  ).start();
}
