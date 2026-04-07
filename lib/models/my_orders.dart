// ── models/my_order.dart ──────────────────────────────────────────────────────

import 'order_model.dart'; // for OrderType & CartItem

enum OrderStatus { pending, cooking, ready, completed, cancelled }

class MyOrder {
  final String id;
  final String restaurantName;
  final String restaurantImage;
  final String restaurantPhone;
  final OrderType type;
  final OrderStatus status;
  final List<MyOrderItem> items;
  final DateTime placedAt;
  final int estimatedMinutes;
  final String? deliveryAddress;

  const MyOrder({
    required this.id,
    required this.restaurantName,
    required this.restaurantImage,
    required this.restaurantPhone,
    required this.type,
    required this.status,
    required this.items,
    required this.placedAt,
    required this.estimatedMinutes,
    this.deliveryAddress,
  });

  double get total => items.fold(0, (s, i) => s + i.subtotal);

  int get minutesLeft {
    final eta = placedAt.add(Duration(minutes: estimatedMinutes));
    final left = eta.difference(DateTime.now()).inMinutes;
    return left < 0 ? 0 : left;
  }

  /// Creates a copy with a new status (used when cancelling).
  MyOrder copyWith({OrderStatus? status}) => MyOrder(
    id: id,
    restaurantName: restaurantName,
    restaurantImage: restaurantImage,
    restaurantPhone: restaurantPhone,
    type: type,
    status: status ?? this.status,
    items: items,
    placedAt: placedAt,
    estimatedMinutes: estimatedMinutes,
    deliveryAddress: deliveryAddress,
  );

  /// Build a MyOrder from the data available right after payment.
  factory MyOrder.fromCart({
    required String id,
    required dynamic restaurant, // your Restaurant model
    required OrderType type,
    required Map<String, CartItem> cart,
    required String? deliveryAddress,
  }) =>
      MyOrder(
        id: id,
        restaurantName: restaurant.name as String,
        restaurantImage: restaurant.imageUrl as String,
        // Add a `phone` field to your Restaurant model, or hard-code a fallback
        restaurantPhone: (restaurant.phone as String?) ?? '',
        type: type,
        status: OrderStatus.pending,
        items: cart.values
            .map((c) => MyOrderItem(
          name: c.name,
          quantity: c.quantity,
          price: c.price,
        ))
            .toList(),
        placedAt: DateTime.now(),
        estimatedMinutes: type == OrderType.delivery ? 45 : 25,
        deliveryAddress: deliveryAddress,
      );
}

class MyOrderItem {
  final String name;
  final int quantity;
  final double price;
  const MyOrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
  double get subtotal => price * quantity;
}