import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import '../models/restaurant.dart';
import '../widgets/common.dart';
import 'restaurant_detail_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final offers = state.restaurants.where((r) => r.hasOffer).toList();
        final popular = state.restaurants.take(4).toList();
        final nearby = state.restaurants.where((r) => r.distance < 2).toList();

        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: CustomScrollView(slivers: [

            // ── App Bar ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 0,
              pinned: true,
              backgroundColor: AppTheme.bg,
              title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Good Evening, Alex 👋', style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppTheme.text2)),
                Text('Where to dine tonight?', style: GoogleFonts.playfairDisplay(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.text1)),
              ]),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => BlocProvider.value(
                        value: context.read<AppBloc>(),
                        child: const NotificationsScreen()))),
                  child: Container(margin: const EdgeInsets.only(right: 16),
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12)),
                    child: Stack(alignment: Alignment.center, children: [
                      const Icon(Icons.notifications_outlined, color: AppTheme.text1, size: 22),
                      Positioned(top: 8, right: 8,
                        child: Container(width: 7, height: 7,
                          decoration: const BoxDecoration(
                              color: AppTheme.primary, shape: BoxShape.circle))),
                    ])),
                ),
              ],
            ),

            SliverToBoxAdapter(child: Column(children: [

              // ── Search bar ──────────────────────────────────
              Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: () => context.read<AppBloc>().add(const ChangeTab(1)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border)),
                    child: Row(children: [
                      Icon(Icons.search_rounded, color: AppTheme.text3, size: 20),
                      const SizedBox(width: 10),
                      Text('Search restaurants, cuisine...', style: GoogleFonts.dmSans(
                          color: AppTheme.text3, fontSize: 14)),
                      const Spacer(),
                      Container(padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.tune_rounded, color: AppTheme.primary, size: 16)),
                    ]),
                  ),
                )),

              // ── Special Offers banner ───────────────────────
              const SizedBox(height: 24),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader('Special Offers 🔥',
                  action: 'See All', onAction: () {})),
              const SizedBox(height: 14),
              SizedBox(height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemCount: offers.length,
                  itemBuilder: (context, i) {
                    final r = offers[i];
                    return GestureDetector(
                      onTap: () => _goToDetail(context, r),
                      child: SizedBox(width: 280,
                        child: Stack(fit: StackFit.expand, children: [
                          ClipRRect(borderRadius: BorderRadius.circular(16),
                            child: NetImg(r.imageUrl)),
                          ClipRRect(borderRadius: BorderRadius.circular(16),
                            child: Container(decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)])))),
                          Positioned(top: 12, left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(r.offerText!, style: GoogleFonts.dmSans(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.white)))),
                          Positioned(bottom: 14, left: 14, right: 14, child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r.name, style: GoogleFonts.playfairDisplay(
                                  fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.white)),
                              const SizedBox(height: 4),
                              Row(children: [
                                StarRating(r.rating, size: 12),
                                const SizedBox(width: 8),
                                Text(r.cuisine, style: GoogleFonts.dmSans(
                                    fontSize: 11, color: AppTheme.text2)),
                              ]),
                            ])),
                        ])),
                    );
                  },
                )),

              // ── Cuisine categories ──────────────────────────
              const SizedBox(height: 24),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader('Cuisines', action: 'See All', onAction: () {})),
              const SizedBox(height: 14),
              SizedBox(height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemCount: _cuisineIcons.length,
                  itemBuilder: (context, i) {
                    final item = _cuisineIcons[i];
                    return GestureDetector(
                      onTap: () {
                        context.read<AppBloc>()
                          ..add(SelectCuisine(item.$1))
                          ..add(const ChangeTab(1));
                      },
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 58, height: 58,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border)),
                          child: Center(child: Text(item.$2, style: const TextStyle(fontSize: 26)))),
                        const SizedBox(height: 6),
                        Text(item.$1, style: GoogleFonts.dmSans(
                            fontSize: 11, color: AppTheme.text2, fontWeight: FontWeight.w500)),
                      ]),
                    );
                  },
                )),

              // ── Popular restaurants ─────────────────────────
              const SizedBox(height: 24),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader('Popular Near You',
                  action: 'See All', onAction: () => context.read<AppBloc>().add(const ChangeTab(1)))),
              const SizedBox(height: 14),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemCount: popular.length,
                itemBuilder: (context, i) => RestaurantCardH(
                  r: popular[i],
                  onTap: () => _goToDetail(context, popular[i]),
                  onFav: () => context.read<AppBloc>().add(ToggleFavorite(popular[i].id)),
                ),
              ),

              // ── Nearby ─────────────────────────────────────
              const SizedBox(height: 24),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SectionHeader('Nearby Restaurants')),
              const SizedBox(height: 14),
              SizedBox(height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemCount: nearby.length,
                  itemBuilder: (context, i) => SizedBox(width: 200,
                    child: RestaurantCardV(
                      r: nearby[i],
                      onTap: () => _goToDetail(context, nearby[i]),
                      onFav: () => context.read<AppBloc>().add(ToggleFavorite(nearby[i].id)),
                    )),
                )),
              const SizedBox(height: 30),
            ])),
          ]),
        );
      },
    );
  }

  void _goToDetail(BuildContext context, Restaurant r) {
    context.read<AppBloc>().add(SelectRestaurant(r));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AppBloc>(),
          child: RestaurantDetailScreen(restaurant: r),
        ),
      ),
    );
  }
  static const _cuisineIcons = [
    ('French', '🥐'), ('Japanese', '🍱'), ('Italian', '🍝'),
    ('American', '🥩'), ('Indian', '🍛'), ('Chinese', '🥢'),
    ('Mexican', '🌮'), ('Mediterranean', '🥙'),
  ];
}
