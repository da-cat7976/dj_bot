import 'dart:async';

import 'package:dj_bot/src/core/lib.dart';
import 'package:dj_bot/src/gen/config.dart';
import 'package:dj_bot/src/misc/emoji.dart';
import 'package:dj_bot/src/orders/lib.dart';
import 'package:teledart/model.dart';

class OrderListControls extends ListeningDjBotDelegate {
  late final OrderService _service;

  @override
  FutureOr<void> init() {
    _service = delegateOf();

    listen(
      stream: client.onCommand('list'),
      listener: onList,
    );

    listen(stream: client.onCommand('clear'), listener: onClear);
  }

  void onList(TeleDartMessage message) async {
    final Iterable<Order> orders = _service.all();

    String reply = '${Emoji.note} Вот все треки, которые были заказаны:\n\n';

    if (orders.isNotEmpty)
      for (int i = 0; i < orders.length; i++) {
        final int number = i + 1;
        final String message = orders.elementAt(i).toMessage();

        reply += '$number) $message\n\n';
      }
    else
      reply += 'А их и нет))0)';

    await message.reply(
      reply,
      disable_web_page_preview: true,
    );
  }

  void onClear(TeleDartMessage message) async {
    if (isDj(message)) {
      await _service.clear();

      await message.reply('Список заказов очищен');
    } else
      await message.reply('Разве ты DJ?');
  }

  bool isDj(TeleDartMessage message) => message.from?.id == BotConfig.owner;
}
