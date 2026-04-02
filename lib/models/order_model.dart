// ── models/order.dart ─────────────────────────────────────────────────────────
// Drop this file into lib/models/order.dart

enum OrderType { delivery, takeaway }

enum OrderStatus { pending, confirmed, preparing, readyForPickup, outForDelivery, delivered, cancelled }

class CartItem {
  final String menuItemId;
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  int quantity;
  String? specialNote;

  CartItem({
    required this.menuItemId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.quantity = 1,
    this.specialNote,
  });

  CartItem copyWith({int? quantity, String? specialNote}) => CartItem(
    menuItemId: menuItemId,
    name: name,
    imageUrl: imageUrl,
    price: price,
    category: category,
    quantity: quantity ?? this.quantity,
    specialNote: specialNote ?? this.specialNote,
  );

  double get subtotal => price * quantity;
}

class FoodOrder {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final OrderType type;
  final OrderStatus status;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double tax;
  final double total;
  final DateTime placedAt;
  final String? deliveryAddress;
  final String estimatedTime;

  const FoodOrder({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.type,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    required this.placedAt,
    this.deliveryAddress,
    required this.estimatedTime,
  });

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.confirmed: return 'Confirmed';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.readyForPickup: return 'Ready for Pickup';
      case OrderStatus.outForDelivery: return 'Out for Delivery';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
    }
  }
}