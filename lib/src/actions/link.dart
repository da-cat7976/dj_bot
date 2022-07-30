import 'dart:async';
import 'dart:convert';

import 'package:teledart/model.dart';

import '../core/lib.dart';

class LinkAction extends ListeningDjBotDelegate {
  @override
  FutureOr<void> init() {
    listen(stream: client.onMessage(), listener: onMessage);
  }

  void onMessage(TeleDartMessage message) {
    message.reply(JsonEncoder.withIndent('  ').convert(message.toJson()));
  }
}
