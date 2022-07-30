import 'dart:async';
import 'dart:convert';

import 'package:dj_bot/src/core/core.dart';
import 'package:teledart/model.dart';

class LinkAction extends ListeningDjBotDelegate {
  @override
  FutureOr<void> init() {
    listen(stream: client.onMessage(), listener: onMessage);
  }

  void onMessage(TeleDartMessage message) {
    message.reply(JsonEncoder.withIndent('  ').convert(message.toJson()));
  }
}
