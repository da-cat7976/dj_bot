import 'dart:async';

import 'package:dj_bot/src/core/lib.dart';
import 'package:dj_bot/src/misc/emoji.dart';
import 'package:teledart/model.dart';

class HelloAction extends ListeningDjBotDelegate {
  @override
  FutureOr<void> init() {
    listen(
      stream: client.onCommand('start'),
      listener: reply,
    );
  }

  void reply(TeleDartMessage message) async {
    await message.reply(Emoji.hello);
    await Future.delayed(
      Duration(seconds: 1),
    );
    await message.reply(
      'Привет!\n'
      'Я — бот-помощник DJ. Отправляй в этот чат ссылки на музыку, '
      'а я их передам ${Emoji.winking}\n\n'
      'Однако, тебе придётся учесть пару моментов:\n'
      '1) Я умею принимать заказы только из яндекс.музыки и вк\n'
      '2) В одном сообщении можно отправлять только одну ссылку\n'
      '3) Если я не ответил на твоё сообщение, значит я не принял заказ',
    );
  }
}
