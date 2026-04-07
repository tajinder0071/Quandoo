import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import '../models/restaurant.dart';
import '../widgets/common.dart';
import 'book_table_screen.dart';
import 'order_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key, required Restaurant restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _DetailState();
}

class _DetailState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }


  Future<void> _callRestaurant(BuildContext context, String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri    = Uri(scheme: 'tel', path: digits);
    try {
      await launchUrl(uri);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not open phone dialler.',
              style: GoogleFonts.dmSans(color: Colors.white)),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final r = state.selectedRestaurant!;
        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 280,
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
                    child: const Icon(Icons.arrow_back_rounded, color: AppTheme.white),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => context.read<AppBloc>().add(ToggleFavorite(r.id)),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                          color: Colors.black38, shape: BoxShape.circle),
                      child: Icon(
                        r.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: r.isFavorite ? AppTheme.primary : AppTheme.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: Colors.black38, shape: BoxShape.circle),
                    child: const Icon(Icons.share_outlined,
                        color: AppTheme.white, size: 20),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(fit: StackFit.expand, children: [
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
                  ]),
                ),
              ),
            ],
            body: Column(children: [
              // ── Restaurant info ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(r.name,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text1)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: r.isOpen
                              ? AppTheme.success.withOpacity(0.15)
                              : AppTheme.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.circle,
                              size: 6,
                              color: r.isOpen ? AppTheme.success : AppTheme.error),
                          const SizedBox(width: 4),
                          Text(r.isOpen ? 'Open' : 'Closed',
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: r.isOpen
                                      ? AppTheme.success : AppTheme.error)),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(r.cuisine,
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: AppTheme.text2)),
                    const SizedBox(height: 10),
                    Row(children: [
                      StarRating(r.rating, count: r.reviewCount),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined,
                          size: 15, color: AppTheme.text3),
                      Text(' ${r.distance} km · ${r.location}',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppTheme.text2)),
                      const Spacer(),
                      Text(r.priceString,
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.gold)),
                    ]),
                    const SizedBox(height: 12),
                    // Tags
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: r.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.border)),
                        child: Text(t,
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: AppTheme.text2)),
                      )).toList(),
                    ),
                    const SizedBox(height: 14),

                    // ── Key info row: Hours | Tables | CALL ─────────────
                    Row(children: [
                      _InfoBadge(Icons.access_time_rounded,
                          '${r.openTime} – ${r.closeTime}'),
                      const SizedBox(width: 8),
                      _InfoBadge(Icons.table_restaurant_outlined,
                          '${r.availableTables} tables'),
                      const SizedBox(width: 8),

                      // ── Call button ───────────────────────────────────
                      GestureDetector(
                        onTap: () => _callRestaurant(context, r.phone),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.success.withOpacity(0.4)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.call_rounded,
                                size: 14, color: AppTheme.success),
                            const SizedBox(width: 5),
                            Text('Call',
                                style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.success)),
                          ]),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Tabs ────────────────────────────────────────────────────
              Container(
                color: AppTheme.bg,
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicator: const UnderlineTabIndicator(
                    borderSide: BorderSide(color: AppTheme.primary, width: 2.5),
                    insets: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  labelStyle: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 14),
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.text3,
                  dividerColor: AppTheme.border,
                  tabs: const [
                    Tab(text: 'Menu'),
                    Tab(text: 'About'),
                    Tab(text: 'Gallery'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _MenuTab(r: r),
                    _AboutTab(r: r),
                    _GalleryTab(r: r),
                    _ReviewsTab(r: r),
                  ],
                ),
              ),
            ]),
          ),

          // ── Bottom bar ─────────────────────────────────────────────────
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                  top: BorderSide(color: AppTheme.border, width: 0.5)),
            ),
            child: Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: r.isOpen
                      ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AppBloc>(),
                        child: OrderScreen(restaurant: r),
                      ),
                    ),
                  )
                      : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(
                        color: r.isOpen ? AppTheme.primary : AppTheme.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delivery_dining_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Order Online',
                            style: GoogleFonts.dmSans(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AppBloc>(),
                        child: const BookTableScreen(),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event_seat_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text('Book Table',
                            style: GoogleFonts.dmSans(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ── Info badge ────────────────────────────────────────────────────────────────
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppTheme.primary),
      const SizedBox(width: 5),
      Text(label,
          style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text2)),
    ]),
  );
}

// ── Menu Tab ──────────────────────────────────────────────────────────────────
class _MenuTab extends StatelessWidget {
  final Restaurant r;
  const _MenuTab({required this.r});

  @override
  Widget build(BuildContext context) => Stack(children: [
    ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: r.menu.map((item) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
                width: 72, height: 72, child: NetImg(item.imageUrl)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name,
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text1)),
            const SizedBox(height: 3),
            Text(item.description,
                style: GoogleFonts.dmSans(
                    fontSize: 12, color: AppTheme.text2),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(children: [
              Text('\$${item.price.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AppBloc>(),
                      child: OrderScreen(restaurant: r),
                    ),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('Order',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white)),
                ),
              ),
            ]),
          ])),
        ]),
      )).toList(),
    ),
  ]);
}

// ── About Tab ─────────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  final Restaurant r;
  const _AboutTab({required this.r});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text('About',
          style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.text1)),
      const SizedBox(height: 10),
      Text(r.description,
          style: GoogleFonts.dmSans(
              fontSize: 14, color: AppTheme.text2, height: 1.7)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          // Phone row with tap-to-call
          GestureDetector(
            onTap: () async {
              final digits = r.phone.replaceAll(RegExp(r'[^\d+]'), '');
              final uri    = Uri(scheme: 'tel', path: digits);
              try { await launchUrl(uri); } catch (_) {}
            },
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.call_rounded,
                    size: 16, color: AppTheme.success),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Phone',
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppTheme.text3)),
                Text(r.phone,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.success)),
              ])),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppTheme.text3),
            ]),
          ),
          const Divider(color: AppTheme.border, height: 20),
          InfoRow(icon: Icons.location_on_outlined,
              label: 'Address', value: r.location),
          const Divider(color: AppTheme.border, height: 20),
          InfoRow(icon: Icons.access_time_rounded,
              label: 'Hours', value: '${r.openTime} – ${r.closeTime}'),
          const Divider(color: AppTheme.border, height: 20),
          InfoRow(icon: Icons.table_restaurant_outlined,
              label: 'Available', value: '${r.availableTables} tables'),
        ]),
      ),
    ],
  );
}

// ── Gallery Tab ───────────────────────────────────────────────────────────────
class _GalleryTab extends StatelessWidget {
  final Restaurant r;
  const _GalleryTab({required this.r});

  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1),
    itemCount: r.gallery.length,
    itemBuilder: (_, i) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: NetImg(r.gallery[i])),
  );
}

// ── Reviews Tab ───────────────────────────────────────────────────────────────
class _ReviewsTab extends StatelessWidget {
  final Restaurant r;
  const _ReviewsTab({required this.r});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Column(children: [
            Text(r.rating.toStringAsFixed(1),
                style: GoogleFonts.playfairDisplay(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary)),
            StarRating(r.rating, size: 16),
            const SizedBox(height: 4),
            Text('${r.reviewCount} reviews',
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppTheme.text3)),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Column(
            children: [5, 4, 3, 2, 1].map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Text('$s',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppTheme.text3)),
                const SizedBox(width: 6),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: s == 5 ? 0.7 : s == 4 ? 0.2 : 0.05,
                    backgroundColor: AppTheme.surface,
                    color: AppTheme.primary,
                    minHeight: 6,
                  ),
                )),
              ]),
            )).toList(),
          )),
        ]),
      ),
      const SizedBox(height: 16),
      ...r.reviews.map((rev) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              backgroundColor: AppTheme.primary,
              radius: 18,
              child: Text(rev.userAvatar,
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700, color: AppTheme.white)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rev.userName,
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1)),
              Text(rev.date,
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppTheme.text3)),
            ])),
            StarRating(rev.rating, size: 13),
          ]),
          const SizedBox(height: 8),
          Text(rev.comment,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppTheme.text2, height: 1.6)),
        ]),
      )),
    ],
  );
}