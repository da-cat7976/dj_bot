part of dj_bot.orders;

class OrderService extends DjBotDelegate {
  final Iterable<MessageOrderParser> parsers;

  late final Box<Order> _box;

  OrderService({
    required this.parsers,
  });

  @override
  FutureOr<void> init() async {
    Hive.registerAdapter(
      OrderAdapter(),
    );

    _box = await Hive.openBox<Order>(
      'orders',
      path: './',
    );
  }

  Future<void> add(Order order) async {
    await _box.add(order);

    logger.info('Added new order');

    informOwner(order);
  }

  Future<bool> addFrom(TeleDartMessage message) async {
    for (MessageOrderParser parser in parsers) {
      final Order? order = parser.create(message);

      if (order is Order) {
        await add(order);
        return true;
      }
    }

    return false;
  }

  Iterable<Order> all() => _box.values;

  Future<void> clear() => _box.clear();

  @override
  FutureOr<void> dispose() => _box.close();

  @protected
  void informOwner(Order order) {
    client.sendMessage(
      BotConfig.owner,
      '${Emoji.bell} Новый заказ\n\n'
      '${order.toMessage()}',
    );
  }
}

abstract class MessageOrderParser {
  Order? create(TeleDartMessage message);
}
