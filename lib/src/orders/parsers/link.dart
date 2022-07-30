import 'package:dj_bot/src/orders/lib.dart';
import 'package:teledart/model.dart';

abstract class LinkOrderParser extends MessageOrderParser {
  RegExp get pattern;

  @override
  Order? create(TeleDartMessage message) {
    final String text = message.text!;
    final String? link = pattern.firstMatch(text)?.group(0);

    if (link is String)
      return Order(
        issuer: message.from?.username,
        link: link,
      );

    return null;
  }
}

class YandexLinkParser extends LinkOrderParser {
  @override
  final RegExp pattern = RegExp(r'https:\/\/music\.yandex\.ru\/[^ ]*');
}

class VkLinkParser extends LinkOrderParser {
  @override
  final RegExp pattern = RegExp(r'https:\/\/vk\.com\/audio[^ ]*');
}
