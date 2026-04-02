// ── screens/cart_screen.dart ──────────────────────────────────────────────────
// Shows cart items, pricing breakdown, coupon, and leads to checkout.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final Map<String, CartItem> cart;
  final OrderType orderType;
  final dynamic restaurant;
  final String deliveryAddress;

  const CartScreen({
    super.key,
    required this.cart,
    required this.orderType,
    required this.restaurant,
    required this.deliveryAddress,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final Map<String, CartItem> _cart;
  final _couponCtrl = TextEditingController();
  bool _couponApplied = false;
  double _discount = 0;

  @override
  void initState() {
    super.initState();
    _cart = Map.from(widget.cart);
  }

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  double get _subtotal => _cart.values.fold(0, (s, i) => s + i.subtotal);
  double get _deliveryFee =>
      widget.orderType == OrderType.delivery ? 3.99 : 0.0;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _deliveryFee + _tax - _discount;
  int get _totalItems => _cart.values.fold(0, (s, i) => s + i.quantity);

  void _increment(String id) {
    setState(() {
      _cart[id] = _cart[id]!.copyWith(quantity: _cart[id]!.quantity + 1);
    });
  }

  void _decrement(String id) {
    setState(() {
      if (_cart[id]!.quantity <= 1) {
        _cart.remove(id);
      } else {
        _cart[id] = _cart[id]!.copyWith(quantity: _cart[id]!.quantity - 1);
      }
    });
  }

  void _applyCoupon() {
    if (_couponCtrl.text.trim().toUpperCase() == 'TABLELUX20') {
      setState(() {
        _couponApplied = true;
        _discount = _subtotal * 0.20;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '20% discount applied!',
            style: GoogleFonts.dmSans(color: AppTheme.white),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid coupon code.',
            style: GoogleFonts.dmSans(color: AppTheme.white),
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cart.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.bg,
          title: Text(
            'Your Cart',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.text1,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppTheme.text3,
              ),
              const SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.text1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add items from the menu to get started.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppTheme.text2,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Browse Menu',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text(
          'Your Cart',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.text1,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_bag_rounded,
                  size: 14,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_totalItems items',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          // ── Order type indicator ────────────────────────────
          _OrderTypeBadge(
            type: widget.orderType,
            restaurant: widget.restaurant,
            deliveryAddress: widget.deliveryAddress,
          ),
          const SizedBox(height: 20),

          // ── Cart items ──────────────────────────────────────
          Text(
            'Order Items',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.text3,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ..._cart.values.map(
                (item) => _CartItemRow(
              item: item,
              onIncrement: () => _increment(item.menuItemId),
              onDecrement: () => _decrement(item.menuItemId),
            ),
          ),

          const SizedBox(height: 20),

          // ── Coupon ──────────────────────────────────────────
          _CouponBox(
            controller: _couponCtrl,
            applied: _couponApplied,
            onApply: _applyCoupon,
          ),

          const SizedBox(height: 20),

          // ── Price breakdown ─────────────────────────────────
          _PriceBreakdown(
            subtotal: _subtotal,
            deliveryFee: _deliveryFee,
            tax: _tax,
            discount: _discount,
            total: _total,
            orderType: widget.orderType,
          ),
        ],
      ),

      // ── Proceed to Checkout button ─────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            final bloc = context.read<AppBloc>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bloc,
                  child: CheckoutScreen(
                    cart: Map.from(_cart),
                    orderType: widget.orderType,
                    restaurant: widget.restaurant,
                    deliveryAddress: widget.deliveryAddress,
                    subtotal: _subtotal,
                    deliveryFee: _deliveryFee,
                    tax: _tax,
                    discount: _discount,
                    total: _total,
                  ),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 52),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Proceed to Checkout',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· \$${_total.toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _OrderTypeBadge extends StatelessWidget {
  final OrderType type;
  final dynamic restaurant;
  final String deliveryAddress;

  const _OrderTypeBadge({
    required this.type,
    required this.restaurant,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivery = type == OrderType.delivery;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isDelivery ? AppTheme.primary : AppTheme.success)
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isDelivery ? AppTheme.primary : AppTheme.success)
              .withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDelivery ? AppTheme.primary : AppTheme.success)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDelivery
                  ? Icons.delivery_dining_rounded
                  : Icons.storefront_rounded,
              color: isDelivery ? AppTheme.primary : AppTheme.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDelivery ? 'Home Delivery' : 'Takeaway',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text1,
                  ),
                ),
                Text(
                  isDelivery
                      ? 'Delivering to $deliveryAddress · ~35 min'
                      : 'Pick up at ${restaurant.location} · ~20 min',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.text2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isDelivery ? '~35 min' : '~20 min',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDelivery ? AppTheme.primary : AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemRow({
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 64,
            height: 64,
            child: NetImg(item.imageUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$${item.price.toStringAsFixed(0)} each',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppTheme.text2,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _circleBtn(Icons.remove_rounded, onDecrement),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1,
                    ),
                  ),
                ),
                _circleBtn(Icons.add_rounded, onIncrement),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  Widget _circleBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(icon, size: 14, color: AppTheme.text1),
    ),
  );
}

class _CouponBox extends StatelessWidget {
  final TextEditingController controller;
  final bool applied;
  final VoidCallback onApply;

  const _CouponBox({
    required this.controller,
    required this.applied,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_offer_rounded,
              size: 16,
              color: AppTheme.gold,
            ),
            const SizedBox(width: 8),
            Text(
              'Promo Code',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.text1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !applied,
                style: GoogleFonts.dmSans(
                  color: AppTheme.text1,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter coupon code',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: applied ? null : onApply,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: applied ? AppTheme.success : AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  applied ? 'Applied!' : 'Apply',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (!applied)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Try: TABLELUX20 for 20% off',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppTheme.text3,
              ),
            ),
          ),
      ],
    ),
  );
}

class _PriceBreakdown extends StatelessWidget {
  final double subtotal, deliveryFee, tax, discount, total;
  final OrderType orderType;

  const _PriceBreakdown({
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
    required this.orderType,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        _row('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 10),
        _row(
          orderType == OrderType.delivery
              ? 'Delivery Fee'
              : 'Takeaway (Free)',
          orderType == OrderType.delivery
              ? '\$${deliveryFee.toStringAsFixed(2)}'
              : 'FREE',
          valueColor:
          orderType == OrderType.takeaway ? AppTheme.success : null,
        ),
        const SizedBox(height: 10),
        _row('Tax & Fees (8%)', '\$${tax.toStringAsFixed(2)}'),
        if (discount > 0) ...[
          const SizedBox(height: 10),
          _row(
            'Discount',
            '-\$${discount.toStringAsFixed(2)}',
            valueColor: AppTheme.success,
          ),
        ],
        const SizedBox(height: 14),
        const Divider(color: AppTheme.border, height: 1),
        const SizedBox(height: 14),
        Row(
          children: [
            Text(
              'Total',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.text1,
              ),
            ),
            const Spacer(),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _row(String label, String value, {Color? valueColor}) => Row(
    children: [
      Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppTheme.text2,
        ),
      ),
      const Spacer(),
      Text(
        value,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: valueColor ?? AppTheme.text1,
        ),
      ),
    ],
  );
}