part of dj_bot.orders;

@HiveType(typeId: 0)
class Order extends HiveObject {
  @HiveField(0)
  final String? issuer;

  @HiveField(1)
  final String link;

  Order({
    this.issuer,
    required this.link,
  });

  String toMessage() {
    final String issuerLine = issuer is String ? 'Прислал(-а) @$issuer\n' : '';

    return '$issuerLine$link';
  }
}
