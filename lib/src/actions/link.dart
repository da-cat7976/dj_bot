import 'dart:async';

import 'package:dj_bot/src/core/lib.dart';
import 'package:dj_bot/src/orders/lib.dart';
import 'package:teledart/model.dart';

import '../misc/emoji.dart';

class OrderFromLink extends ListeningDjBotDelegate {
  final Iterable<LinkOrderFactory> factories;

  late final OrderService _service;

  OrderFromLink({
    required this.factories,
  });

  @override
  FutureOr<void> init() {
    _service = delegateOf();

    listen(stream: client.onTextLink(), listener: onLink);
  }

  void onLink(TeleDartMessage message) async {
    for (LinkOrderFactory factory in factories)
      if (message.text!.contains(factory.pattern)) {
        final Order order = factory.create(message);
        _service.add(order);

        await message.reply(
          '${Emoji.note} Заказ принят!\n'
          '${order.toMessage()}',
        );
        return;
      }
  }
}

abstract class LinkOrderFactory {
  Pattern get pattern;

  Order create(TeleDartMessage message);
}
