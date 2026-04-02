// ── screens/order_screen.dart ─────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';

class OrderScreen extends StatefulWidget {
  final dynamic restaurant;

  const OrderScreen({
    super.key,
    required this.restaurant,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  OrderType _orderType = OrderType.delivery;

  // Local cart: menuItemId → CartItem
  final Map<String, CartItem> _cart = {};

  static const _categories = ['All', 'Starters', 'Mains', 'Desserts', 'Drinks'];
  int _selectedCat = 0;

  // Delivery address
  String _deliveryAddress = '42 Maple Street, Downtown';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _categories.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() => _selectedCat = _tab.index);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  double get _cartTotal => _cart.values.fold(0, (s, i) => s + i.subtotal);

  int get _cartCount => _cart.values.fold(0, (s, i) => s + i.quantity);

  void _addItem(dynamic menuItem) {
    final key = menuItem.name as String;
    setState(() {
      if (_cart.containsKey(key)) {
        _cart[key] = _cart[key]!.copyWith(
          quantity: _cart[key]!.quantity + 1,
        );
      } else {
        _cart[key] = CartItem(
          menuItemId: key,
          name: menuItem.name,
          imageUrl: menuItem.imageUrl,
          price: menuItem.price,
          category: menuItem.category,
          quantity: 1,
        );
      }
    });
  }

  void _removeItem(dynamic menuItem) {
    final key = menuItem.name as String;
    setState(() {
      if (_cart.containsKey(key)) {
        final qty = _cart[key]!.quantity;
        if (qty <= 1) {
          _cart.remove(key);
        } else {
          _cart[key] = _cart[key]!.copyWith(quantity: qty - 1);
        }
      }
    });
  }

  List<dynamic> _filteredMenu(List<dynamic> menu) {
    if (_selectedCat == 0) return menu;
    final cat = _categories[_selectedCat];
    return menu.where((m) => m.category == cat).toList();
  }

  Future<void> _changeDeliveryAddress() async {
    final controller = TextEditingController(text: _deliveryAddress);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Address',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the address where you want your order delivered.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppTheme.text3,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.text1,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. House no. 12, Raj Nagar, Ghaziabad',
                  hintStyle: GoogleFonts.dmSans(color: AppTheme.text3),
                  filled: true,
                  fillColor: AppTheme.card,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newAddress = controller.text.trim();
                    if (newAddress.isNotEmpty) {
                      Navigator.pop(context, newAddress);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save Address',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _deliveryAddress = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final filtered = _filteredMenu(r.menu);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          // ── Hero sliver ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.white,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetImg(r.imageUrl),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.bg],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: AppTheme.star,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              r.rating.toStringAsFixed(1),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppTheme.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppTheme.text2,
                            ),
                            Text(
                              ' ${r.distance} km',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppTheme.text2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Order type toggle ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: _OrderTypeToggle(
                selected: _orderType,
                onChanged: (t) => setState(() => _orderType = t),
              ),
            ),
          ),

          // ── Delivery / Pickup strip ──────────────────────
          SliverToBoxAdapter(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: _orderType == OrderType.delivery
                  ? _DeliveryInfoStrip(
                address: _deliveryAddress,
                onChangeTap: _changeDeliveryAddress,
              )
                  : _TakeawayInfoStrip(restaurant: r),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Category tabs ────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _CatTabDelegate(
              TabBar(
                controller: _tab,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 2.5,
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 8),
                ),
                labelStyle: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.text3,
                dividerColor: AppTheme.border,
                tabs: _categories.map((c) => Tab(text: c)).toList(),
              ),
            ),
          ),
        ],

        // ── Menu items ────────────────────────────────────
        body: filtered.isEmpty
            ? Center(
          child: Text(
            'No items in this category',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppTheme.text3,
            ),
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) {
            final item = filtered[i];
            final inCart = _cart[item.name as String];
            return _MenuItemCard(
              item: item,
              cartQty: inCart?.quantity ?? 0,
              onAdd: () => _addItem(item),
              onRemove: () => _removeItem(item),
            );
          },
        ),
      ),

      // ── Cart bottom bar ────────────────────────────────
      bottomNavigationBar: _cartCount > 0
          ? _CartBar(
        count: _cartCount,
        total: _cartTotal,
        onView: () {
          final bloc = context.read<AppBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: CartScreen(
                  cart: Map.from(_cart),
                  orderType: _orderType,
                  restaurant: r,
                  deliveryAddress: _deliveryAddress,
                ),
              ),
            ),
          );
        },
      )
          : null,
    );
  }
}

// ── Order type toggle ─────────────────────────────────────────────────────────
class _OrderTypeToggle extends StatelessWidget {
  final OrderType selected;
  final ValueChanged<OrderType> onChanged;

  const _OrderTypeToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(
      children: [
        _toggle(
          OrderType.delivery,
          Icons.delivery_dining_rounded,
          'Delivery',
        ),
        _toggle(
          OrderType.takeaway,
          Icons.storefront_rounded,
          'Takeaway',
        ),
      ],
    ),
  );

  Widget _toggle(OrderType type, IconData icon, String label) {
    final active = selected == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          height: 50,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? AppTheme.white : AppTheme.text3,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? AppTheme.white : AppTheme.text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Delivery info strip ───────────────────────────────────────────────────────
class _DeliveryInfoStrip extends StatelessWidget {
  final String address;
  final VoidCallback onChangeTap;

  const _DeliveryInfoStrip({
    required this.address,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppTheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.location_on_rounded,
          size: 16,
          color: AppTheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Delivering to: $address',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.text2,
            ),
          ),
        ),
        GestureDetector(
          onTap: onChangeTap,
          child: Text(
            'Change',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Takeaway info strip ───────────────────────────────────────────────────────
class _TakeawayInfoStrip extends StatelessWidget {
  final dynamic restaurant;

  const _TakeawayInfoStrip({required this.restaurant});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppTheme.success.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.success.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.storefront_rounded,
          size: 16,
          color: AppTheme.success,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Pick up at: ${restaurant.location}',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppTheme.text2,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 13,
              color: AppTheme.success,
            ),
            const SizedBox(width: 4),
            Text(
              '~20 min',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.success,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Menu item card ────────────────────────────────────────────────────────────
class _MenuItemCard extends StatelessWidget {
  final dynamic item;
  final int cartQty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemCard({
    required this.item,
    required this.cartQty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
      border: cartQty > 0
          ? Border.all(color: AppTheme.primary.withOpacity(0.4))
          : null,
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 90,
              height: 90,
              child: NetImg(item.imageUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text1,
                        ),
                      ),
                    ),
                    _FoodTypeBadge(isVeg: item.category != 'Mains'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppTheme.text3,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(0)}',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const Spacer(),
                    cartQty == 0
                        ? GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Add',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.white,
                          ),
                        ),
                      ),
                    )
                        : _QtyControl(
                      qty: cartQty,
                      onAdd: onAdd,
                      onRemove: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _FoodTypeBadge extends StatelessWidget {
  final bool isVeg;

  const _FoodTypeBadge({required this.isVeg});

  @override
  Widget build(BuildContext context) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      border: Border.all(
        color: isVeg ? AppTheme.success : AppTheme.error,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Center(
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isVeg ? AppTheme.success : AppTheme.error,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QtyControl({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.remove_rounded,
              size: 16,
              color: AppTheme.white,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$qty',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 16,
              color: AppTheme.white,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Cart bottom bar ───────────────────────────────────────────────────────────
class _CartBar extends StatelessWidget {
  final int count;
  final double total;
  final VoidCallback onView;

  const _CartBar({
    required this.count,
    required this.total,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      16,
      12,
      16,
      12 + MediaQuery.of(context).padding.bottom,
    ),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      border: const Border(
        top: BorderSide(color: AppTheme.border, width: 0.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: GestureDetector(
      onTap: onView,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDk],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'View Cart',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
            const Spacer(),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Persistent header delegate ────────────────────────────────────────────────
class _CatTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _CatTabDelegate(this.child);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) =>
      Container(
        color: AppTheme.bg,
        child: child,
      );

  @override
  bool shouldRebuild(_CatTabDelegate old) => false;
}