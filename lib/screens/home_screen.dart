import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/reservation/reservation_bloc.dart';
import '../models/dining_space.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_widgets.dart';
import 'reservation_flow_screen.dart';
import 'my_reservations_screen.dart';
import 'space_detail_screen.dart';

// ── Network image helper ──────────────────────────────────────────────────────
Widget _netImg(String url, {BoxFit fit = BoxFit.cover, Widget? fallback}) {
  return Image.network(
    url,
    fit: fit,
    loadingBuilder: (_, child, progress) => progress == null
        ? child
        : Container(
            color: AppTheme.darkCard,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: AppTheme.gold,
                ),
              ),
            ),
          ),
    errorBuilder: (_, __, ___) =>
        fallback ??
        Container(
          color: AppTheme.darkCard,
          child: const Icon(
            Icons.image_not_supported_outlined,
            color: AppTheme.darkBorder,
            size: 28,
          ),
        ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: CustomScrollView(
        slivers: [
          // ── Hero ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: isWide ? 720 : 580,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _netImg(
                    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=1400&q=85',
                    fallback: Container(color: AppTheme.cream),
                  ),
                  Container(
                    decoration: BoxDecoration(color: AppTheme.darkSurface),
                  ),
                  Positioned.fill(
                    child: CustomPaint(painter: _HeroPatternPainter()),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 80 : 24,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        const SectionLabel('Maison Dorée · Est. 1987'),
                        const SizedBox(height: 24),
                        Text(
                          'An Extraordinary\nDining Experience',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: isWide
                                ? 64
                                : isTablet
                                ? 52
                                : 40,
                            fontWeight: FontWeight.w300,
                            color: AppTheme.textPrimary,
                            height: 1.1,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(width: 50, height: 1, color: AppTheme.gold),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: isWide ? 460 : double.infinity,
                          child: Text(
                            'Where culinary artistry meets timeless elegance. Curated menus, exceptional wines, and impeccable service await you in the heart of the city.',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            LuxuryButton(
                              label: 'Reserve a Table',
                              onPressed: () {
                                context.read<ReservationBloc>().add(
                                  ResetReservation(),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<ReservationBloc>(),
                                      child: const ReservationFlowScreen(),
                                    ),
                                  ),
                                );
                              },
                              width: 200,
                            ),
                            LuxuryButton(
                              label: 'My Reservations',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ReservationBloc>(),
                                    child: const MyReservationsScreen(),
                                  ),
                                ),
                              ),
                              outlined: true,
                              width: 200,
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

          // ── Awards Bar ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.darkCard,
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AwardBadge(
                    icon: Icons.star,
                    label: 'Michelin',
                    sublabel: '3 Stars',
                  ),
                  Container(width: 1, height: 40, color: AppTheme.darkBorder),
                  _AwardBadge(
                    icon: Icons.wine_bar,
                    label: 'Wine Spectator',
                    sublabel: 'Grand Award',
                  ),
                  Container(width: 1, height: 40, color: AppTheme.darkBorder),
                  _AwardBadge(
                    icon: Icons.restaurant,
                    label: 'World\'s 50 Best',
                    sublabel: '#12',
                  ),
                  if (isTablet) ...[
                    Container(width: 1, height: 40, color: AppTheme.darkBorder),
                    _AwardBadge(
                      icon: Icons.local_florist,
                      label: 'Condé Nast',
                      sublabel: 'Gold List',
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Featured Spaces ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: 60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Our Spaces'),
                  const SizedBox(height: 12),
                  Text(
                    'Curated Environments',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  const GoldDivider(width: 120),
                  const SizedBox(height: 40),
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: diningSpaces
                              .asMap()
                              .entries
                              .map(
                                (e) => Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: e.key < diningSpaces.length - 1
                                          ? 20
                                          : 0,
                                    ),
                                    child: _SpaceCard(space: e.value),
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : Column(
                          children: diningSpaces
                              .map(
                                (s) => Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: _SpaceCard(space: s),
                                ),
                              )
                              .toList(),
                        ),
                ],
              ),
            ),
          ),

          // ── Horizontal Photo Gallery ──────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: isWide ? 80 : 24, bottom: 16),
                  child: const SectionLabel('Gallery'),
                ),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24),
                    itemCount: _galleryUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => ClipRect(
                      child: SizedBox(
                        width: 260,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _netImg(_galleryUrls[i]),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),

          // ── Experience + Menu Highlights ──────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.darkSurface,
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: 60,
              ),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _ExperienceColumn()),
                        const SizedBox(width: 60),
                        Expanded(child: _MenuHighlights()),
                      ],
                    )
                  : Column(
                      children: [
                        _ExperienceColumn(),
                        const SizedBox(height: 40),
                        _MenuHighlights(),
                      ],
                    ),
            ),
          ),

          // ── Chef Section ──────────────────────────────────────
          SliverToBoxAdapter(child: _ChefSection(isWide: isWide)),

          // ── CTA ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isWide ? 80 : 24,
                vertical: 60,
              ),
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.goldDark.withOpacity(0.3)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFDF8EE), Color(0xFFF5EDD8)],
                ),
              ),
              child: Column(
                children: [
                  const GoldDivider(width: 80),
                  const SizedBox(height: 24),
                  Text(
                    'Reserve Your Evening',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: isWide ? 42 : 32,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.gold,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Join us for an unforgettable culinary journey. Tables are limited.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  LuxuryButton(
                    label: 'Make a Reservation',
                    onPressed: () {
                      context.read<ReservationBloc>().add(ResetReservation());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ReservationBloc>(),
                            child: const ReservationFlowScreen(),
                          ),
                        ),
                      );
                    },
                    width: 220,
                  ),
                ],
              ),
            ),
          ),

          // ── Footer ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.cream,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                children: [
                  const GoldDivider(width: 60),
                  const SizedBox(height: 16),
                  Text(
                    'MAISON DORÉE',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18,
                      letterSpacing: 4,
                      color: AppTheme.gold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '28 Rue de la Paix · Paris · +33 1 23 45 67 89',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '© 2024 Maison Dorée. All rights reserved.',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: AppTheme.darkBorder,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Static data ───────────────────────────────────────────────────────────────
const _galleryUrls = [
  'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
  'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=600&q=80',
  'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?w=600&q=80',
  'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=600&q=80',
  'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=600&q=80',
  'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600&q=80',
];

// ── Widgets ───────────────────────────────────────────────────────────────────
class _AwardBadge extends StatelessWidget {
  final IconData icon;
  final String label, sublabel;

  const _AwardBadge({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: AppTheme.gold, size: 18),
      const SizedBox(height: 4),
      Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      Text(
        sublabel,
        style: GoogleFonts.montserrat(fontSize: 10, color: AppTheme.gold),
      ),
    ],
  );
}

class _SpaceCard extends StatelessWidget {
  final DiningSpace space;

  const _SpaceCard({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ReservationBloc>(),
            child: SpaceDetailScreen(space: space),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          border: Border.all(color: AppTheme.gold),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _netImg(space.heroUrl),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppTheme.cream.withOpacity(0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      color: AppTheme.black.withOpacity(0.75),
                      child: Text(
                        space.tag.toUpperCase(),
                        style: GoogleFonts.montserrat(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    space.title,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(width: 30, height: 1, color: AppTheme.goldDark),
                  const SizedBox(height: 10),
                  Text(
                    space.shortDesc,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Explore',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        size: 13,
                        color: AppTheme.gold,
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
}

class _ExperienceColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel('The Experience'),
      const SizedBox(height: 12),
      Text('Beyond Dining', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 16),
      Text(
        'At Maison Dorée, we believe every meal should be a memory. Our executive chef crafts seasonal tasting menus that honour the finest local ingredients with classical French technique.',
        style: GoogleFonts.montserrat(
          fontSize: 13,
          color: AppTheme.textSecondary,
          height: 1.9,
        ),
      ),
      const SizedBox(height: 24),
      ...[
        ('🕯', 'Tasting Menu', '7-course chef\'s selection'),
        ('🍾', 'Sommelier Service', 'World-class wine pairing'),
        ('🎶', 'Live Jazz', 'Friday & Saturday evenings'),
        ('🎂', 'Special Occasions', 'Personalised celebrations'),
      ].map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Text(item.$1, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$2,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    item.$3,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _MenuHighlights extends StatelessWidget {
  static const _dishes = [
    (
      'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=180&q=80',
      'Caviar en Gelée',
      'Oscietra, champagne jelly, crème fraîche',
      '€95',
    ),
    (
      'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=180&q=80',
      'Turbot Entier',
      'Beurre blanc, sea vegetables, roe',
      '€120',
    ),
    (
      'https://images.unsplash.com/photo-1558030006-450675393462?w=180&q=80',
      'Wagyu A5 Rossini',
      'Foie gras, truffle jus, pommes Anna',
      '€165',
    ),
    (
      'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=180&q=80',
      'Soufflé Grand Marnier',
      'Crème anglaise, blood orange sorbet',
      '€35',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel('Signature Dishes'),
      const SizedBox(height: 12),
      Text(
        'Tonight\'s Highlights',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 24),
      ..._dishes.map(
        (d) => Container(
          margin: EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              SizedBox(width: 90, height: 90, child: _netImg(d.$1)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.$2,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      d.$3,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  d.$4,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 18,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _ChefSection extends StatelessWidget {
  final bool isWide;

  const _ChefSection({required this.isWide});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: isWide ? 420 : 480,
    child: Stack(
      fit: StackFit.expand,
      children: [
        _netImg(
          'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?w=1200&q=85',
          fallback: Container(color: AppTheme.darkCard),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isWide ? Alignment.centerRight : Alignment.bottomCenter,
              end: isWide ? Alignment.centerLeft : Alignment.topCenter,
              colors: const [Color(0xF5000000), Color(0x88000000)],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 24,
            vertical: 48,
          ),
          child: isWide
              ? Row(
                  children: [
                    Expanded(child: _chefText()),
                    const Spacer(),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_chefText()],
                ),
        ),
      ],
    ),
  );

  Widget _chefText() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel('Meet the Chef'),
      const SizedBox(height: 12),
      Text(
        'Chef Étienne\nDubois',
        style: GoogleFonts.cormorantGaramond(
          fontSize: isWide ? 48 : 36,
          fontWeight: FontWeight.w300,
          color: AppTheme.textPrimary,
          height: 1.1,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 16),
      Container(width: 40, height: 1, color: AppTheme.gold),
      const SizedBox(height: 16),
      SizedBox(
        width: isWide ? 400 : double.infinity,
        child: Text(
          'With 25 years at the helm of Europe\'s most celebrated kitchens, Chef Dubois brings unparalleled creativity and precision to every plate — a philosophy that has earned Maison Dorée its three Michelin stars.',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.9,
          ),
        ),
      ),
    ],
  );
}

// ── Decorative painter ────────────────────────────────────────────────────────
class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.goldDark.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double i = 0; i < size.width + size.height; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
