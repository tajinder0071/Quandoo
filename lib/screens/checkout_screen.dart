// ── screens/checkout_screen.dart ──────────────────────────────────────────────

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'my_order_screen.dart'; // ← MyOrderItem, PlacedOrder, OrderStore

class CheckoutScreen extends StatefulWidget {
  final Map<String, CartItem> cart;
  final OrderType orderType;
  final dynamic restaurant;
  final double subtotal, deliveryFee, tax, discount, total;
  final String deliveryAddress;

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
    required this.deliveryAddress,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  int  _selectedPayment = 0;
  bool _isPlacing       = false;

  static const _payments = [
    (Icons.credit_card_rounded,            '•••• •••• •••• 4242', 'Visa'),
    (Icons.credit_card_rounded,            '•••• •••• •••• 8881', 'Mastercard'),
    (Icons.account_balance_wallet_rounded, 'TableLux Wallet',     '\$24.50'),
  ];

  // ── Success-overlay state ──────────────────────────────────────────────────
  bool _showSuccess = false;
  late final AnimationController _successCtrl;
  late final Animation<double>   _scaleAnim;
  late final Animation<double>   _fadeAnim;
  Timer? _redirectTimer;
  int    _countdown = 3;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _scaleAnim = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
    _fadeAnim  = CurvedAnimation(parent: _successCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _successCtrl.dispose();
    _redirectTimer?.cancel();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _placeOrder(BuildContext context) async {
    setState(() => _isPlacing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // 1. Convert cart → MyOrderItem list
    final items = widget.cart.values
        .map((c) => MyOrderItem(name: c.name, quantity: c.quantity, price: c.price))
        .toList();

    // 2. Push to OrderStore — instantly visible on MyOrdersScreen
    OrderStore.add(PlacedOrder.fromCheckout(
      restaurant:      widget.restaurant,
      isDelivery:      widget.orderType == OrderType.delivery,
      items:           items,
      deliveryAddress: widget.orderType == OrderType.delivery
          ? widget.deliveryAddress : null,
    ));

    // 3. Show animated success overlay
    setState(() { _isPlacing = false; _showSuccess = true; });
    _successCtrl.forward();

    // 4. Auto-redirect countdown: 3 → 2 → 1 → go
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) { t.cancel(); _goToMyOrders(); }
    });
  }

  void _goToMyOrders() {
    if (!mounted) return;
    _redirectTimer?.cancel();
    context.read<AppBloc>().add(const ChangeTab(3)); // My Orders = tab 3
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Stack(children: [
    _checkoutScaffold(context),
    if (_showSuccess) _successOverlay(context),
  ]);

  // ── Checkout scaffold ──────────────────────────────────────────────────────

  Widget _checkoutScaffold(BuildContext context) {
    final isDelivery = widget.orderType == OrderType.delivery;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        title: Text('Checkout',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.text1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        children: [

          // ── Restaurant strip ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 56, height: 56,
                    child: NetImg(widget.restaurant.imageUrl)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.restaurant.name,
                    style: GoogleFonts.dmSans(fontSize: 15,
                        fontWeight: FontWeight.w700, color: AppTheme.text1)),
                Text('${widget.cart.length} item${widget.cart.length != 1 ? 's' : ''} · '
                    '${isDelivery ? 'Delivery' : 'Takeaway'}',
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
              ])),
              Text('\$${widget.total.toStringAsFixed(2)}',
                  style: GoogleFonts.playfairDisplay(fontSize: 18,
                      fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Delivery address ──────────────────────────────────────────
          if (isDelivery) ...[
            _sectionTitle('Delivery Address'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.25))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.location_on_rounded,
                        color: AppTheme.primary, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Deliver To', style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                  const SizedBox(height: 2),
                  Text(widget.deliveryAddress, style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppTheme.text2, height: 1.5)),
                ])),
                const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          // ── Pickup info ───────────────────────────────────────────────
          if (!isDelivery) ...[
            _sectionTitle('Pickup Location'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.success.withOpacity(0.3))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.storefront_rounded,
                        color: AppTheme.success, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.restaurant.name, style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                  Text('${widget.restaurant.location} · Ready in ~20 min',
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),
          ],

          // ── Payment method ────────────────────────────────────────────
          _sectionTitle('Payment Method'),
          const SizedBox(height: 10),
          ..._payments.asMap().entries.map((e) => _SelectableCard(
            selected: _selectedPayment == e.key,
            onTap:    () => setState(() => _selectedPayment = e.key),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _selectedPayment == e.key
                          ? AppTheme.primary.withOpacity(0.12) : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(e.value.$1,
                      color: _selectedPayment == e.key
                          ? AppTheme.primary : AppTheme.text3, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value.$3, style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                Text(e.value.$2, style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppTheme.text2)),
              ])),
              if (_selectedPayment == e.key)
                const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
            ]),
          )),

          const SizedBox(height: 24),

          // ── Order summary ─────────────────────────────────────────────
          _sectionTitle('Order Summary'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              ...widget.cart.values.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  Text('${item.quantity}×', style: GoogleFonts.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name,
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text1))),
                  Text('\$${item.subtotal.toStringAsFixed(2)}',
                      style: GoogleFonts.dmSans(fontSize: 13,
                          fontWeight: FontWeight.w600, color: AppTheme.text1)),
                ]),
              )),
              const Divider(color: AppTheme.border, height: 20),
              _summaryRow('Subtotal', '\$${widget.subtotal.toStringAsFixed(2)}'),
              const SizedBox(height: 6),
              _summaryRow(
                isDelivery ? 'Delivery Fee' : 'Takeaway',
                isDelivery ? '\$${widget.deliveryFee.toStringAsFixed(2)}' : 'FREE',
                valueColor: !isDelivery ? AppTheme.success : null,
              ),
              const SizedBox(height: 6),
              _summaryRow('Tax (8%)', '\$${widget.tax.toStringAsFixed(2)}'),
              if (widget.discount > 0) ...[
                const SizedBox(height: 6),
                _summaryRow('Discount', '-\$${widget.discount.toStringAsFixed(2)}',
                    valueColor: AppTheme.success),
              ],
              const SizedBox(height: 14),
              const Divider(color: AppTheme.border, height: 1),
              const SizedBox(height: 14),
              Row(children: [
                Text('Total', style: GoogleFonts.playfairDisplay(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                const Spacer(),
                Text('\$${widget.total.toStringAsFixed(2)}',
                    style: GoogleFonts.playfairDisplay(fontSize: 22,
                        fontWeight: FontWeight.w700, color: AppTheme.primary)),
              ]),
            ]),
          ),
        ],
      ),

      // ── Place Order CTA ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
          boxShadow: [BoxShadow(
              color: Color(0x33000000), blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: ElevatedButton(
          onPressed: _isPlacing ? null : () => _placeOrder(context),
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          child: _isPlacing
              ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(
                  color: AppTheme.white, strokeWidth: 2.5))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.lock_rounded, size: 16),
            const SizedBox(width: 8),
            Text('Place Order · \$${widget.total.toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(
                    fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  // ── Success overlay ────────────────────────────────────────────────────────

  Widget _successOverlay(BuildContext context) {
    final isDelivery = widget.orderType == OrderType.delivery;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: AppTheme.bg,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Animated check circle
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [AppTheme.primary, AppTheme.primaryDk]),
                      boxShadow: [BoxShadow(
                          color: AppTheme.primary.withOpacity(0.45),
                          blurRadius: 36, spreadRadius: 4)],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 58),
                  ),
                ),

                const SizedBox(height: 28),

                Text('Order Placed! 🎉',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 28, fontWeight: FontWeight.w700,
                        color: AppTheme.text1)),
                const SizedBox(height: 10),
                Text(
                  isDelivery
                      ? 'Your order is confirmed and on its way.'
                      : 'Your order is confirmed. Head over to pick it up!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: AppTheme.text2, height: 1.65),
                ),

                const SizedBox(height: 32),

                // Order snapshot card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border)),
                  child: Column(children: [
                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(width: 52, height: 52,
                            child: NetImg(widget.restaurant.imageUrl)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.restaurant.name,
                                style: GoogleFonts.dmSans(fontSize: 14,
                                    fontWeight: FontWeight.w700, color: AppTheme.text1)),
                            Text(isDelivery ? 'Home Delivery' : 'Takeaway',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12, color: AppTheme.text2)),
                          ])),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('CONFIRMED',
                            style: GoogleFonts.dmSans(fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.success)),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    const Divider(color: AppTheme.border, height: 1),
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(
                          isDelivery
                              ? Icons.delivery_dining_rounded
                              : Icons.storefront_rounded,
                          size: 14, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(isDelivery ? 'ETA ~35 min' : 'Ready in ~20 min',
                          style: GoogleFonts.dmSans(fontSize: 12,
                              fontWeight: FontWeight.w700, color: AppTheme.primary)),
                      const Spacer(),
                      Text('Total  ',
                          style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
                      Text('\$${widget.total.toStringAsFixed(2)}',
                          style: GoogleFonts.playfairDisplay(fontSize: 16,
                              fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ]),
                  ]),
                ),

                const SizedBox(height: 32),

                // Countdown bar
                _CountdownBar(seconds: 3, label: 'Going to My Orders in $_countdown s…'),

                const SizedBox(height: 24),

                // PRIMARY — Track My Order
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _goToMyOrders,
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: Text('Track My Order',
                        style: GoogleFonts.dmSans(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),

                const SizedBox(height: 12),

                // SECONDARY — Back to Home
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _redirectTimer?.cancel();
                      context.read<AppBloc>().add(const ChangeTab(0));
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: Text('Back to Home',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t.toUpperCase(),
      style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.text3, letterSpacing: 1.2));

  Widget _summaryRow(String label, String value, {Color? valueColor}) =>
      Row(children: [
        Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
        const Spacer(),
        Text(value, style: GoogleFonts.dmSans(fontSize: 13,
            fontWeight: FontWeight.w600, color: valueColor ?? AppTheme.text1)),
      ]);
}

// ── Animated countdown bar ────────────────────────────────────────────────────

class _CountdownBar extends StatefulWidget {
  final int    seconds;
  final String label;
  const _CountdownBar({required this.seconds, required this.label});

  @override
  State<_CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<_CountdownBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: Duration(seconds: widget.seconds))
      ..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(widget.label,
        style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text3)),
    const SizedBox(height: 8),
    ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => LinearProgressIndicator(
          value: 1 - _ctrl.value,
          minHeight: 4,
          backgroundColor: AppTheme.surface,
          color: AppTheme.primary,
        ),
      ),
    ),
  ]);
}

// ── Selectable card ───────────────────────────────────────────────────────────

class _SelectableCard extends StatelessWidget {
  final bool      selected;
  final VoidCallback onTap;
  final Widget    child;
  const _SelectableCard(
      {required this.selected, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin:   const EdgeInsets.only(bottom: 10),
      padding:  const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withOpacity(0.06) : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 1.5 : 1),
      ),
      child: child,
    ),
  );
}