// ── screens/checkout_screen.dart ──────────────────────────────────────────────
// Address/payment selection → order summary → place order → success.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, CartItem> cart;
  final OrderType orderType;
  final dynamic restaurant;
  final double subtotal, deliveryFee, tax, discount, total;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.orderType,
    required this.restaurant,
    required this.subtotal,
    required this.deliveryFee,
    required this.tax,
    required this.discount,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Delivery address selection
  int _selectedAddress = 0;
  static const _addresses = [
    ('42 Maple Street, Downtown', 'Home'),
    ('7 Business Park, Suite 4B', 'Work'),
    ('88 Lakeview Drive, Apt 12', 'Other'),
  ];

  // Payment method selection
  int _selectedPayment = 0;
  static const _payments = [
    (Icons.credit_card_rounded, '•••• •••• •••• 4242', 'Visa'),
    (Icons.credit_card_rounded, '•••• •••• •••• 8881', 'Mastercard'),
    (Icons.account_balance_wallet_rounded, 'TableLux Wallet', '\$24.50'),
  ];

  bool _isPlacing = false;

  void _placeOrder(BuildContext context) async {
    setState(() => _isPlacing = true);
    // Simulate a short network round-trip
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // Dispatch to BLoC so order history can be tracked
/*
    context.read<AppBloc>().add(PlaceOrder(
      cart: widget.cart,
      orderType: widget.orderType,
      restaurant: widget.restaurant,
      total: widget.total,
      deliveryAddress: widget.orderType == OrderType.delivery
          ? _addresses[_selectedAddress].$1
          : null,
    ));
*/

    // Navigate to success
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AppBloc>(),
          child: OrderSuccessScreen(
            restaurant: widget.restaurant,
            orderType: widget.orderType,
            cart: widget.cart,
            total: widget.total,
            deliveryAddress: widget.orderType == OrderType.delivery
                ? _addresses[_selectedAddress].$1
                : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDelivery = widget.orderType == OrderType.delivery;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text(
          'Checkout',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.text1,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [
          // ── Restaurant summary strip ────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: NetImg(widget.restaurant.imageUrl),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text1,
                      ),
                    ),
                    Text(
                      '${widget.cart.length} item${widget.cart.length != 1 ? 's' : ''} · ${isDelivery ? 'Delivery' : 'Takeaway'}',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppTheme.text2),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${widget.total.toStringAsFixed(2)}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Delivery address (only for delivery) ───────────
          if (isDelivery) ...[
            _sectionTitle('Delivery Address'),
            const SizedBox(height: 10),
            ..._addresses.asMap().entries.map((e) => _SelectableCard(
              selected: _selectedAddress == e.key,
              onTap: () => setState(() => _selectedAddress = e.key),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedAddress == e.key
                        ? AppTheme.primary.withOpacity(0.12)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    e.value.$2 == 'Home'
                        ? Icons.home_rounded
                        : e.value.$2 == 'Work'
                        ? Icons.business_rounded
                        : Icons.location_on_rounded,
                    color: _selectedAddress == e.key
                        ? AppTheme.primary
                        : AppTheme.text3,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.value.$2,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text1,
                        ),
                      ),
                      Text(
                        e.value.$1,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.text2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedAddress == e.key)
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.primary, size: 20),
              ]),
            )),
            const SizedBox(height: 24),
          ],

          // ── Pickup info (for takeaway) ──────────────────────
          if (!isDelivery) ...[
            _sectionTitle('Pickup Location'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: AppTheme.success, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text1,
                        ),
                      ),
                      Text(
                        '${widget.restaurant.location} · Ready in ~20 min',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppTheme.text2),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          // ── Payment method ──────────────────────────────────
          _sectionTitle('Payment Method'),
          const SizedBox(height: 10),
          ..._payments.asMap().entries.map((e) => _SelectableCard(
            selected: _selectedPayment == e.key,
            onTap: () => setState(() => _selectedPayment = e.key),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedPayment == e.key
                      ? AppTheme.primary.withOpacity(0.12)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(e.value.$1,
                    color: _selectedPayment == e.key
                        ? AppTheme.primary
                        : AppTheme.text3,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.value.$3,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text1,
                      ),
                    ),
                    Text(
                      e.value.$2,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppTheme.text2,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedPayment == e.key)
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.primary, size: 20),
            ]),
          )),

          const SizedBox(height: 24),

          // ── Order summary ───────────────────────────────────
          _sectionTitle('Order Summary'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              ...widget.cart.values.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Text(
                    '${item.quantity}×',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.name,
                      style: GoogleFonts.dmSans(
                          fontSize: 13, color: AppTheme.text1),
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.text1,
                    ),
                  ),
                ]),
              )),
              const Divider(color: AppTheme.border, height: 20),
              _summaryRow('Subtotal',
                  '\$${widget.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _summaryRow(
                isDelivery ? 'Delivery Fee' : 'Takeaway',
                isDelivery
                    ? '\$${widget.deliveryFee.toStringAsFixed(2)}'
                    : 'FREE',
                valueColor:
                !isDelivery ? AppTheme.success : null,
              ),
              const SizedBox(height: 6),
              _summaryRow(
                  'Tax (8%)', '\$${widget.tax.toStringAsFixed(2)}'),
              if (widget.discount > 0) ...[
                const SizedBox(height: 6),
                _summaryRow(
                    'Discount',
                    '-\$${widget.discount.toStringAsFixed(2)}',
                    valueColor: AppTheme.success),
              ],
              const SizedBox(height: 14),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 14),
              Row(children: [
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
                  '\$${widget.total.toStringAsFixed(2)}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),

      // ── Place Order button ──────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border:
          Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
          boxShadow: [
            BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, -4)),
          ],
        ),
        child: ElevatedButton(
          onPressed:
          _isPlacing ? null : () => _placeOrder(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 54),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _isPlacing
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                color: AppTheme.white, strokeWidth: 2.5),
          )
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock_rounded, size: 16),
            const SizedBox(width: 8),
            Text(
              'Place Order · \$${widget.total.toStringAsFixed(2)}',
              style: GoogleFonts.dmSans(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t.toUpperCase(),
    style: GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppTheme.text3,
      letterSpacing: 1.2,
    ),
  );

  Widget _summaryRow(String label, String value, {Color? valueColor}) =>
      Row(children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppTheme.text2)),
        const Spacer(),
        Text(value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.text1,
            )),
      ]);
}

// ── Selectable card ───────────────────────────────────────────────────────────
class _SelectableCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _SelectableCard(
      {required this.selected,
        required this.onTap,
        required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.primary.withOpacity(0.06)
            : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: child,
    ),
  );
}

// ── Order Success Screen ──────────────────────────────────────────────────────
class OrderSuccessScreen extends StatelessWidget {
  final dynamic restaurant;
  final OrderType orderType;
  final Map<String, CartItem> cart;
  final double total;
  final String? deliveryAddress;

  const OrderSuccessScreen({
    super.key,
    required this.restaurant,
    required this.orderType,
    required this.cart,
    required this.total,
    this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivery = orderType == OrderType.delivery;
    // Simple order number from timestamp
    final orderNum =
    DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),

            // ── Success icon ──────────────────────────────────
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryDk],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppTheme.white, size: 56),
            ),

            const SizedBox(height: 28),
            Text(
              'Order Placed! 🎉',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.text1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isDelivery
                  ? 'Your order is confirmed and on its way.'
                  : 'Your order is confirmed. Head over to pick it up!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.text2, height: 1.6),
            ),
            const SizedBox(height: 32),

            // ── Order receipt card ────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(children: [
                // Header
                Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: NetImg(restaurant.imageUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.text1,
                          ),
                        ),
                        Text(
                          isDelivery ? 'Home Delivery' : 'Takeaway',
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppTheme.text2),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CONFIRMED',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
                ]),

                const SizedBox(height: 16),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 12),

                // Order number + ETA
                Row(children: [
                  Text(
                    'ORDER #$orderNum',
                    style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppTheme.text3,
                        letterSpacing: 1),
                  ),
                  const Spacer(),
                  Icon(
                    isDelivery
                        ? Icons.delivery_dining_rounded
                        : Icons.storefront_rounded,
                    size: 13,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isDelivery ? 'ETA ~35 min' : 'Ready in ~20 min',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ]),

                const SizedBox(height: 14),

                // Items list
                ...cart.values.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Text(
                      '${item.quantity}×',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppTheme.text1),
                      ),
                    ),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text2,
                      ),
                    ),
                  ]),
                )),

                const SizedBox(height: 6),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 6),

                Row(children: [
                  Text(
                    'Total Paid',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ]),

                // Delivery address
                if (isDelivery && deliveryAddress != null) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: AppTheme.text3),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        deliveryAddress!,
                        style: GoogleFonts.dmSans(
                            fontSize: 11, color: AppTheme.text2),
                      ),
                    ),
                  ]),
                ],
              ]),
            ),

            const Spacer(),

            // ── Actions ───────────────────────────────────────
            PrimaryBtn(
              label: 'Back to Home',
              onPressed: () {
                context.read<AppBloc>().add(const ChangeTab(0));
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.read<AppBloc>().add(const ChangeTab(1));
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Order from Another Restaurant',
                style: GoogleFonts.dmSans(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}