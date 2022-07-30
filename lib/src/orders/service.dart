part of dj_bot.orders;

class OrderService extends DjBotDelegate {
  late final Box<Order> _box;

  @override
  FutureOr<void> init() async {
    _box = await Hive.openBox<Order>('orders');
  }

  Future<void> add(Order order) async {
    await _box.add(order);

    informOwner(order);
  }

  Iterable<Order> all() => _box.values;

  Future<void> clear() => _box.clear();

  @override
  FutureOr<void> dispose() => _box.close();

  @protected
  void informOwner(Order order) {
    client.sendMessage(
      BotConfig.owner,
      '${Emoji.bell} Новый заказ:\n\n'
      '${order.toMessage()}',
    );
  }
}
