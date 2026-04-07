// ── screens/my_orders_screen.dart ─────────────────────────────────────────────
//
//  ✅ ZERO BLoC changes required.
//  Orders are stored in a static ValueNotifier<List<PlacedOrder>>.
//  To add an order after payment, call:
//
//    OrderStore.add(PlacedOrder.fromCheckout(...));
//
//  See checkout_screen.dart for the exact call.
//
//  pubspec.yaml:  url_launcher: ^6.2.5
//  AndroidManifest.xml (inside <manifest>):
//    <uses-permission android:name="android.permission.CALL_PHONE"/>
//  AndroidManifest.xml (inside <queries>):
//    <intent><action android:name="android.intent.action.DIAL"/></intent>
// ---------------------------------------------------------------------------

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enums & Models
// ─────────────────────────────────────────────────────────────────────────────

enum MyOrderType { delivery, takeaway }

enum MyOrderStatus { pending, cooking, ready, completed, cancelled }

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

class PlacedOrder {
  final String id;
  final String restaurantName;
  final String restaurantImage;
  final String restaurantPhone;
  final MyOrderType type;
  final MyOrderStatus status;
  final List<MyOrderItem> items;
  final DateTime placedAt;
  final int estimatedMinutes;
  final String? deliveryAddress;

  const PlacedOrder({
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

  double get total => items.fold(0.0, (s, i) => s + i.subtotal);

  int get minutesLeft {
    final eta = placedAt.add(Duration(minutes: estimatedMinutes));
    final left = eta.difference(DateTime.now()).inMinutes;
    return left < 0 ? 0 : left;
  }

  PlacedOrder _withStatus(MyOrderStatus s) => PlacedOrder(
    id: id,
    restaurantName: restaurantName,
    restaurantImage: restaurantImage,
    restaurantPhone: restaurantPhone,
    type: type,
    status: s,
    items: items,
    placedAt: placedAt,
    estimatedMinutes: estimatedMinutes,
    deliveryAddress: deliveryAddress,
  );

  /// Call this from checkout_screen.dart after payment succeeds.
  ///
  /// [restaurant] — your dynamic Restaurant object.
  ///   Must have: .name (String), .imageUrl (String)
  ///   Optional:  .phone (String?) — used for the Call button
  factory PlacedOrder.fromCheckout({
    required dynamic restaurant,
    required bool isDelivery,
    required List<MyOrderItem> items,
    required String? deliveryAddress,
  }) {
    final id =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    String phone = '';
    try {
      phone = (restaurant.phone as String?) ?? '';
    } catch (_) {}

    return PlacedOrder(
      id: id,
      restaurantName: restaurant.name as String,
      restaurantImage: restaurant.imageUrl as String,
      restaurantPhone: phone,
      type: isDelivery ? MyOrderType.delivery : MyOrderType.takeaway,
      status: MyOrderStatus.pending,
      items: items,
      placedAt: DateTime.now(),
      estimatedMinutes: isDelivery ? 45 : 25,
      deliveryAddress: deliveryAddress,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OrderStore — static in-memory store; survives navigation, no BLoC needed
// ─────────────────────────────────────────────────────────────────────────────

class OrderStore {
  OrderStore._();

  static final ValueNotifier<List<PlacedOrder>> notifier =
  ValueNotifier(const []);

  /// Add a brand-new order (called from checkout_screen after payment).
  static void add(PlacedOrder order) {
    notifier.value = [order, ...notifier.value];
  }

  /// Cancel a pending order.
  static void cancel(String id) {
    notifier.value = notifier.value.map((o) {
      return o.id == id ? o._withStatus(MyOrderStatus.cancelled) : o;
    }).toList();
  }

  /// Re-order: creates a fresh pending copy of a past order.
  static void reorder(String id) {
    final original = notifier.value.firstWhere((o) => o.id == id);
    final newId =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final reOrder = PlacedOrder(
      id: newId,
      restaurantName: original.restaurantName,
      restaurantImage: original.restaurantImage,
      restaurantPhone: original.restaurantPhone,
      type: original.type,
      status: MyOrderStatus.pending,
      items: original.items,
      placedAt: DateTime.now(),
      estimatedMinutes: original.estimatedMinutes,
      deliveryAddress: original.deliveryAddress,
    );
    notifier.value = [reOrder, ...notifier.value];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MyOrdersScreen
// ─────────────────────────────────────────────────────────────────────────────

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PlacedOrder>>(
      valueListenable: OrderStore.notifier,
      builder: (context, orders, _) {
        final delivery =
        orders.where((o) => o.type == MyOrderType.delivery).toList();
        final takeaway =
        orders.where((o) => o.type == MyOrderType.takeaway).toList();

        bool hasActive(List<PlacedOrder> list) => list.any((o) =>
        o.status == MyOrderStatus.pending ||
            o.status == MyOrderStatus.cooking ||
            o.status == MyOrderStatus.ready);

        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            backgroundColor: AppTheme.bg,
            automaticallyImplyLeading: false,
            title: Text('My Orders',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text1)),
            bottom: TabBar(
              controller: _tab,
              labelStyle: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.text3,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: AppTheme.primary, width: 2.5),
                insets: EdgeInsets.symmetric(horizontal: 12),
              ),
              dividerColor: AppTheme.border,
              tabs: [
                _tab_(Icons.delivery_dining_rounded, 'Delivery',
                    hasActive(delivery)),
                _tab_(Icons.shopping_bag_outlined, 'Takeaway',
                    hasActive(takeaway)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              _OrderList(orders: delivery),
              _OrderList(orders: takeaway),
            ],
          ),
        );
      },
    );
  }

  Tab _tab_(IconData icon, String label, bool dot) => Tab(
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16),
      const SizedBox(width: 6),
      Text(label),
      if (dot) ...[const SizedBox(width: 6), _LiveDot()],
    ]),
  );
}

// ── Animated live dot ─────────────────────────────────────────────────────────
class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.5 + 0.5 * _c.value),
        shape: BoxShape.circle,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Order list
// ─────────────────────────────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  final List<PlacedOrder> orders;
  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_outlined, size: 52, color: AppTheme.text3),
          const SizedBox(height: 14),
          Text('No orders yet',
              style: GoogleFonts.dmSans(fontSize: 16, color: AppTheme.text2)),
          const SizedBox(height: 6),
          Text('Your orders will appear here after payment.',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3)),
        ]),
      );
    }

    final active = orders
        .where((o) =>
    o.status == MyOrderStatus.pending ||
        o.status == MyOrderStatus.cooking ||
        o.status == MyOrderStatus.ready)
        .toList();
    final past = orders
        .where((o) =>
    o.status == MyOrderStatus.completed ||
        o.status == MyOrderStatus.cancelled)
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        if (active.isNotEmpty) ...[
          _label('Active Orders', AppTheme.success),
          const SizedBox(height: 10),
          ...active.map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _OrderCard(order: o))),
        ],
        if (past.isNotEmpty) ...[
          if (active.isNotEmpty) const SizedBox(height: 4),
          _label('Past Orders', AppTheme.text3),
          const SizedBox(height: 10),
          ...past.map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _OrderCard(order: o))),
        ],
      ],
    );
  }

  Widget _label(String text, Color color) => Row(children: [
    Container(
        width: 4,
        height: 16,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 13, fontWeight: FontWeight.w700, color: color)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Order card
// ─────────────────────────────────────────────────────────────────────────────

class _OrderCard extends StatefulWidget {
  final PlacedOrder order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;
  Timer? _timer;
  late int _minutesLeft;

  @override
  void initState() {
    super.initState();
    _minutesLeft = widget.order.minutesLeft;
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _timer = Timer.periodic(const Duration(seconds: 30),
            (_) { if (mounted) setState(() => _minutesLeft = widget.order.minutesLeft); });
  }

  @override
  void dispose() {
    _pulse.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── Status helpers ────────────────────────────────────────────────────────

  bool get _isActive =>
      widget.order.status == MyOrderStatus.pending ||
          widget.order.status == MyOrderStatus.cooking ||
          widget.order.status == MyOrderStatus.ready;

  Color _color(MyOrderStatus s) {
    switch (s) {
      case MyOrderStatus.pending:   return AppTheme.warning;
      case MyOrderStatus.cooking:   return AppTheme.primary;
      case MyOrderStatus.ready:     return AppTheme.success;
      case MyOrderStatus.completed: return AppTheme.text3;
      case MyOrderStatus.cancelled: return AppTheme.error;
    }
  }

  String _label(MyOrderStatus s) {
    switch (s) {
      case MyOrderStatus.pending:   return 'Pending';
      case MyOrderStatus.cooking:   return 'Cooking';
      case MyOrderStatus.ready:
        return widget.order.type == MyOrderType.takeaway
            ? 'Ready for Pickup' : 'Out for Delivery';
      case MyOrderStatus.completed: return 'Delivered';
      case MyOrderStatus.cancelled: return 'Cancelled';
    }
  }

  IconData _icon(MyOrderStatus s) {
    switch (s) {
      case MyOrderStatus.pending:   return Icons.hourglass_top_rounded;
      case MyOrderStatus.cooking:   return Icons.local_fire_department_rounded;
      case MyOrderStatus.ready:
        return widget.order.type == MyOrderType.takeaway
            ? Icons.shopping_bag_rounded : Icons.delivery_dining_rounded;
      case MyOrderStatus.completed: return Icons.check_circle_rounded;
      case MyOrderStatus.cancelled: return Icons.cancel_rounded;
    }
  }

  List<_Step> get _steps {
    final d = widget.order.type == MyOrderType.delivery;
    return [
      const _Step(icon: Icons.receipt_long_rounded,           label: 'Order\nPlaced'),
      const _Step(icon: Icons.local_fire_department_rounded,  label: 'Preparing\nFood'),
      _Step(icon: d ? Icons.delivery_dining_rounded : Icons.shopping_bag_rounded,
          label: d ? 'On the\nWay' : 'Ready for\nPickup'),
      _Step(icon: Icons.check_circle_rounded,
          label: d ? 'Delivered' : 'Picked Up'),
    ];
  }

  int get _stepIndex {
    switch (widget.order.status) {
      case MyOrderStatus.pending:   return 0;
      case MyOrderStatus.cooking:   return 1;
      case MyOrderStatus.ready:     return 2;
      case MyOrderStatus.completed: return 3;
      case MyOrderStatus.cancelled: return -1;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _call() async {
    final raw = widget.order.restaurantPhone;
    if (raw.isEmpty) { _snack('Phone number not available.', AppTheme.error); return; }
    final digits = raw.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: digits);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _snack('Could not open phone dialler.', AppTheme.error);
    }
  }

  void _snack(String msg, Color bg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.dmSans(color: Colors.white)),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  void _cancelDialog() => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Cancel Order?',
          style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppTheme.text1)),
      content: Text(
          'Are you sure you want to cancel order ${widget.order.id}?',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2, height: 1.6)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep',
                style: GoogleFonts.dmSans(
                    color: AppTheme.primary, fontWeight: FontWeight.w600))),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
              OrderStore.cancel(widget.order.id); // ← static call, no BLoC
            },
            child: Text('Cancel Order',
                style: GoogleFonts.dmSans(
                    color: AppTheme.error, fontWeight: FontWeight.w600))),
      ],
    ),
  );

  void _doReorder() {
    OrderStore.reorder(widget.order.id); // ← static call, no BLoC
    _snack('New order created!', AppTheme.primary);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final sc = _color(o.status);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: _isActive ? Border.all(color: sc.withOpacity(0.35), width: 1.2) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Hero image ────────────────────────────────────────────────────
        Stack(children: [
          SizedBox(
            height: 120, width: double.infinity,
            child: Image.network(o.restaurantImage, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppTheme.surface)),
          ),
          Container(height: 120, decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.75)]))),

          // Status badge
          Positioned(top: 10, right: 10,
              child: _StatusBadge(
                  label: _label(o.status), icon: _icon(o.status), color: sc,
                  pulse: _isActive && o.status != MyOrderStatus.ready,
                  pulseAnim: _pulseAnim)),

          // Order ID chip
          Positioned(top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      o.type == MyOrderType.delivery
                          ? Icons.delivery_dining_rounded : Icons.shopping_bag_outlined,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                      '${o.type == MyOrderType.delivery ? 'Delivery' : 'Takeaway'} · ${o.id}',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                ]),
              )),

          // Restaurant name
          Positioned(bottom: 12, left: 14,
              child: Text(o.restaurantName,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white))),

          // ETA chip
          if (_isActive)
            Positioned(bottom: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: sc.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.timer_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(_minutesLeft > 0 ? '~$_minutesLeft min' : 'Arriving',
                        style: GoogleFonts.dmSans(
                            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                  ]),
                )),
        ]),

        // ── Stepper ───────────────────────────────────────────────────────
        if (o.status != MyOrderStatus.cancelled) ...[
          const SizedBox(height: 16),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _StatusStepper(steps: _steps, currentIndex: _stepIndex, pulseAnim: _pulseAnim)),
        ],

        // ── Items ─────────────────────────────────────────────────────────
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: o.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Text('${item.quantity}×',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                const SizedBox(width: 6),
                Expanded(child: Text(item.name,
                    style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text1))),
                Text('\$${item.subtotal.toStringAsFixed(0)}',
                    style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text2)),
              ]),
            )).toList(),
          ),
        ),

        // ── Meta ──────────────────────────────────────────────────────────
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            Text(DateFormat('d MMM, h:mm a').format(o.placedAt),
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
            const Spacer(),
            Text('Total  ', style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
            Text('\$${o.total.toStringAsFixed(2)}',
                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1)),
          ]),
        ),

        // ── Delivery address ──────────────────────────────────────────────
        if (o.deliveryAddress?.isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.text3),
              const SizedBox(width: 4),
              Expanded(child: Text(o.deliveryAddress!,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3))),
            ]),
          ),
        ],

        // ── Action bar ────────────────────────────────────────────────────
        const SizedBox(height: 14),
        const Divider(color: AppTheme.border, height: 1),
        _ActionBar(
          onCall: _call,
          onChat: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _ChatSheet(order: o)),
          onCancel:  o.status == MyOrderStatus.pending  ? _cancelDialog : null,
          onReorder: (o.status == MyOrderStatus.completed ||
              o.status == MyOrderStatus.cancelled) ? _doReorder : null,
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status stepper
// ─────────────────────────────────────────────────────────────────────────────

class _Step {
  final IconData icon;
  final String label;
  const _Step({required this.icon, required this.label});
}

class _StatusStepper extends StatelessWidget {
  final List<_Step> steps;
  final int currentIndex;
  final Animation<double> pulseAnim;
  const _StatusStepper({required this.steps, required this.currentIndex, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final done = currentIndex > i ~/ 2;
          return Expanded(child: Container(height: 2, color: done ? AppTheme.primary : AppTheme.border));
        }
        final idx = i ~/ 2;
        return _StepNode(step: steps[idx], done: currentIndex >= idx,
            active: currentIndex == idx, pulseAnim: pulseAnim);
      }),
    );
  }
}

class _StepNode extends StatelessWidget {
  final _Step step;
  final bool done, active;
  final Animation<double> pulseAnim;
  const _StepNode({required this.step, required this.done, required this.active, required this.pulseAnim});

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Stack(alignment: Alignment.center, children: [
      if (active)
        AnimatedBuilder(animation: pulseAnim, builder: (_, __) => Container(
            width: 38, height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.15 * pulseAnim.value)))),
      Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppTheme.primary : AppTheme.surface,
              border: Border.all(color: done ? AppTheme.primary : AppTheme.border, width: 1.5)),
          child: Icon(step.icon, size: 14, color: done ? Colors.white : AppTheme.text3)),
    ]),
    const SizedBox(height: 5),
    Text(step.label, textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(fontSize: 9, height: 1.3,
            fontWeight: done ? FontWeight.w700 : FontWeight.w400,
            color: done ? AppTheme.primary : AppTheme.text3)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool pulse;
  final Animation<double> pulseAnim;
  const _StatusBadge({required this.label, required this.icon, required this.color,
    required this.pulse, required this.pulseAnim});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.92), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (pulse)
        AnimatedBuilder(animation: pulseAnim, builder: (_, __) => Container(
            width: 6, height: 6, margin: const EdgeInsets.only(right: 5),
            decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(pulseAnim.value)))),
      Icon(icon, size: 11, color: Colors.white),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Action bar
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final Future<void> Function() onCall;
  final VoidCallback onChat;
  final VoidCallback? onCancel;
  final VoidCallback? onReorder;
  const _ActionBar({required this.onCall, required this.onChat, this.onCancel, this.onReorder});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
    child: Row(children: [
      _Btn(icon: Icons.call_rounded,  label: 'Call', color: AppTheme.success, onTap: onCall),
      const SizedBox(width: 8),
      _Btn(icon: Icons.chat_rounded,  label: 'Chat', color: AppTheme.primary, onTap: () async => onChat()),
      const Spacer(),
      if (onCancel != null)
        OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text('Cancel', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600))),
      if (onReorder != null)
        ElevatedButton.icon(
            onPressed: onReorder,
            icon: const Icon(Icons.replay_rounded, size: 14),
            label: Text('Reorder', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
                minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
    ]),
  );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;
  const _Btn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ChatSheet extends StatefulWidget {
  final PlacedOrder order;
  const _ChatSheet({required this.order});

  @override
  State<_ChatSheet> createState() => _ChatSheetState();
}

class _ChatSheetState extends State<_ChatSheet> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  late final List<Map<String, dynamic>> _msgs;
  int _ri = 0;

  static const _replies = [
    'Hi! How can we help you? 😊',
    "We're working on your order right now!",
    'Your order will be ready shortly.',
    'Is there anything else we can help with?',
    'Thank you for your patience!',
  ];

  @override
  void initState() {
    super.initState();
    _msgs = [{'text': 'Hello! You\'re chatting with ${widget.order.restaurantName}. How can we help?',
      'fromUser': false, 'time': DateTime.now()}];
  }

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  void _send() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() { _msgs.add({'text': t, 'fromUser': true, 'time': DateTime.now()}); _ctrl.clear(); });
    _scrollDown();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() { _msgs.add({'text': _replies[_ri++ % _replies.length], 'fromUser': false, 'time': DateTime.now()}); });
      _scrollDown();
    });
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  });

  Future<void> _callFromChat() async {
    Navigator.pop(context);
    final raw = widget.order.restaurantPhone;
    if (raw.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: raw.replaceAll(RegExp(r'[^\d+]'), ''));
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) => Container(
    height: MediaQuery.of(context).size.height * 0.72,
    decoration: const BoxDecoration(color: AppTheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    child: Column(children: [
      const SizedBox(height: 10),
      Container(width: 40, height: 4,
          decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),

      // Header
      Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Row(children: [
          Container(width: 42, height: 42,
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.restaurant_rounded, color: AppTheme.primary, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.order.restaurantName, style: GoogleFonts.dmSans(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.text1)),
            Row(children: [
              Container(width: 7, height: 7,
                  decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('Online', style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.success)),
            ]),
          ])),
          GestureDetector(onTap: _callFromChat,
              child: Container(padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.call_rounded, color: AppTheme.success, size: 18))),
        ]),
      ),
      const Divider(color: AppTheme.border, height: 1),

      // Order strip
      Container(color: AppTheme.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          const Icon(Icons.receipt_outlined, size: 13, color: AppTheme.text3),
          const SizedBox(width: 6),
          Text('Order ${widget.order.id}  ·  ${widget.order.items.length} item${widget.order.items.length > 1 ? 's' : ''}',
              style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3)),
        ]),
      ),

      // Messages
      Expanded(child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        itemCount: _msgs.length,
        itemBuilder: (_, i) => _Bubble(
            text: _msgs[i]['text'] as String,
            fromUser: _msgs[i]['fromUser'] as bool,
            time: _msgs[i]['time'] as DateTime),
      )),

      // Input
      Container(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + MediaQuery.of(context).padding.bottom),
        decoration: const BoxDecoration(color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.border))),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _ctrl,
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1),
            decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: GoogleFonts.dmSans(color: AppTheme.text3),
                filled: true, fillColor: AppTheme.card,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none)),
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
          )),
          const SizedBox(width: 8),
          GestureDetector(onTap: _send,
              child: Container(width: 42, height: 42,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
        ]),
      ),
    ]),
  );
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool fromUser;
  final DateTime time;
  const _Bubble({required this.text, required this.fromUser, required this.time});

  @override
  Widget build(BuildContext context) => Align(
    alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Column(
          crossAxisAlignment: fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: fromUser ? AppTheme.primary : AppTheme.card,
                    borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(fromUser ? 16 : 4),
                        bottomRight: Radius.circular(fromUser ? 4 : 16))),
                child: Text(text, style: GoogleFonts.dmSans(
                    fontSize: 13, color: fromUser ? Colors.white : AppTheme.text1, height: 1.45))),
            const SizedBox(height: 3),
            Text(DateFormat('h:mm a').format(time),
                style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3)),
          ]),
    ),
  );
}