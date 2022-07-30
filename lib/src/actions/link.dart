import 'dart:async';

import 'package:dj_bot/src/core/lib.dart';
import 'package:dj_bot/src/misc/emoji.dart';
import 'package:dj_bot/src/orders/lib.dart';
import 'package:teledart/model.dart';

class OrderFromLink extends ListeningDjBotDelegate {
  late final OrderService _service;

  @override
  FutureOr<void> init() {
    _service = delegateOf();

    listen(stream: client.onUrl(), listener: onLink);
  }

  void onLink(TeleDartMessage message) async {
    final bool result = await _service.addFrom(message);

    if (result)
      await message.reply(
        '${Emoji.disc} Заказ принят',
      );
  }
}
