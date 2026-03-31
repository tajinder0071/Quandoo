import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/reservation/reservation_bloc.dart';
import '../models/dining_space.dart';
import '../models/restaurant_table.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_widgets.dart';
import 'reservation_flow_screen.dart';

class SpaceDetailScreen extends StatefulWidget {
  final DiningSpace space;
  const SpaceDetailScreen({super.key, required this.space});

  @override
  State<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  bool _titleVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      final show = _scrollCtrl.offset > 320;
      if (show != _titleVisible) setState(() => _titleVisible = show);
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final isWide = MediaQuery.of(context).size.width > 800;
    final screenW = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // white icons over hero photo
      child: Scaffold(
        backgroundColor: AppTheme.darkSurface,
        extendBodyBehindAppBar: true,

        // ── Transparent → opaque AppBar on scroll ────────────────
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            color: _titleVisible
                ? AppTheme.cream.withOpacity(0.97)
                : Colors.transparent,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: _titleVisible ? AppTheme.gold : Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: AnimatedOpacity(
                      opacity: _titleVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        space.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.gold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),
            ),
          ),
        ),

        // ── Sticky bottom CTA ─────────────────────────────────────
        bottomNavigationBar: _ReserveCTA(space: space),

        body: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [

            // ── Hero Image ──────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: isWide ? 520 : 400,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      space.heroUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, p) => p == null
                          ? child
                          : Container(
                              color: AppTheme.cream,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.gold, strokeWidth: 1.5),
                              ),
                            ),
                    ),
                    // Bottom fade into background
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppTheme.darkSurface,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Tag badge
                    Positioned(
                      top: 80,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        color: Colors.black.withOpacity(0.65),
                        child: Text(
                          space.tag.toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.gold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Title block ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    isWide ? 80 : 24, 0, isWide ? 80 : 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Curated Environments'),
                    const SizedBox(height: 10),
                    Text(
                      space.title,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: isWide ? 52 : 40,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const GoldDivider(width: 120),
                    const SizedBox(height: 20),
                    Text(
                      space.shortDesc,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Quick stats row ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 80 : 24, vertical: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    border: Border.all(color: AppTheme.textPrimary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _QuickStat(Icons.people_outline, 'Capacity', space.capacity),
                      Container(width: 1, height: 44, color: AppTheme.textPrimary),
                      _QuickStat(Icons.watch_later_outlined, 'Hours', space.openHours),
                      Container(width: 1, height: 44, color: AppTheme.textPrimary),
                      _QuickStat(Icons.checkroom_outlined, 'Dress Code', space.dressCode),
                    ],
                  ),
                ),
              ),
            ),

            // ── Long description ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('About This Space'),
                    const SizedBox(height: 14),
                    Text(
                      space.longDesc,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Features grid ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    isWide ? 80 : 24, 36, isWide ? 80 : 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('What to Expect'),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isWide ? 3 : 2,
                      childAspectRatio: isWide ? 3.0 : 2.4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: space.features
                          .map((f) => _FeatureTile(feature: f))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Photo Gallery ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    0, 36, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: isWide ? 80 : 24, bottom: 16),
                      child: const SectionLabel('Gallery'),
                    ),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: isWide ? 80 : 24),
                        itemCount: space.galleryUrls.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => ClipRect(
                          child: SizedBox(
                            width: screenW * 0.55,
                            child: Stack(fit: StackFit.expand, children: [
                              Image.network(
                                space.galleryUrls[i],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppTheme.darkSurface,
                                  child:  Icon(Icons.image_not_supported_outlined,
                                      color: AppTheme.textPrimary),
                                ),
                              ),
                              // Gold bottom strip on first image
                              if (i == 0)
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      color: Colors.black.withOpacity(0.6),
                                      child: Text(
                                        '${space.galleryUrls.length} PHOTOS',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.gold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Ambiance block ──────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                    isWide ? 80 : 24, 36, isWide ? 80 : 24, 36),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFDF8EE), Color(0xFFF5EDD8)],
                  ),
                  border: Border.all(
                      color: AppTheme.goldDark.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 3, height: 24, color: AppTheme.gold),
                      const SizedBox(width: 12),
                      Text(
                        'The Ambiance',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Text(
                      space.ambiance,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.8,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom padding for sticky bar ───────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Sticky Reserve CTA ────────────────────────────────────────────────────────
class _ReserveCTA extends StatelessWidget {
  final DiningSpace space;
  const _ReserveCTA({required this.space});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: const Border(top: BorderSide(color: AppTheme.textPrimary)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Capacity summary
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  space.title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  space.capacity,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          LuxuryButton(
            label: 'Reserve This Space',
            width: 200,
            onPressed: () => _reserve(context),
          ),
        ],
      ),
    );
  }

  void _reserve(BuildContext context) {
    // Find the linked table
    final table = sampleTables.firstWhere(
      (t) => t.id == space.tableId,
      orElse: () => sampleTables.first,
    );

    // Dispatch SelectTable → sets currentStep = selectDateTime in BLoC
    context.read<ReservationBloc>().add(SelectTable(table));

    // Navigate to the reservation flow — it will open at Step 2 (Date & Time)
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => BlocProvider.value(
          value: context.read<ReservationBloc>(),
          child: const ReservationFlowScreen(),
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _QuickStat(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: AppTheme.gold, size: 20),
      const SizedBox(height: 6),
      Text(label,
          style: GoogleFonts.montserrat(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 1.5)),
      const SizedBox(height: 3),
      Text(value,
          style: GoogleFonts.montserrat(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary),
          textAlign: TextAlign.center),
    ],
  );
}

class _FeatureTile extends StatelessWidget {
  final SpaceFeature feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppTheme.darkSurface,
      border: Border.all(color: AppTheme.textPrimary),
    ),
    child: Row(
      children: [
        Text(feature.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(feature.label,
                  style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 1.2)),
              Text(feature.value,
                  style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    ),
  );
}
