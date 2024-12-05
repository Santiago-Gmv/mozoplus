class Order {
  final List<OrderItem> items;
  final double total;
  final int tableNumber;
  final String waiterName;
  final int numberOfAdults;
  final int numberOfChildren;

  Order({
    required this.items,
    required this.total,
    required this.tableNumber,
    required this.waiterName,
    required this.numberOfAdults,
    required this.numberOfChildren,
  });
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
} 