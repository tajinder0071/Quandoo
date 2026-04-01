// ── discover_screen.dart ──────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import '../models/restaurant.dart';
import '../widgets/common.dart';
import 'restaurant_detail_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final results = state.filteredRestaurants;
      return Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.bg,
          title: Text('Discover', style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text1)),
          automaticallyImplyLeading: false,
        ),
        body: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (v) => context.read<AppBloc>().add(SetSearchQuery(v)),
              style: GoogleFonts.dmSans(color: AppTheme.text1),
              decoration: InputDecoration(
                hintText: 'Search restaurants, cuisine...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.text3),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close_rounded, color: AppTheme.text3),
                        onPressed: () => context.read<AppBloc>().add(const SetSearchQuery('')))
                    : null,
              ),
            )),
          // Cuisine filter
          SizedBox(height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: cuisineCategories.length,
              itemBuilder: (_, i) => TagChip(
                label: cuisineCategories[i],
                selected: state.selectedCuisine == cuisineCategories[i],
                onTap: () => context.read<AppBloc>().add(SelectCuisine(cuisineCategories[i])),
              ),
            )),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Text('${results.length} restaurants found', style: GoogleFonts.dmSans(
                  fontSize: 13, color: AppTheme.text2)),
              const Spacer(),
              Icon(Icons.tune_rounded, size: 16, color: AppTheme.primary),
              const SizedBox(width: 4),
              Text('Filter', style: GoogleFonts.dmSans(
                  fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            ])),
          const SizedBox(height: 12),
          Expanded(child: results.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.text3),
                  const SizedBox(height: 12),
                  Text('No restaurants found', style: GoogleFonts.dmSans(
                      fontSize: 16, color: AppTheme.text2)),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: results.length,
                  itemBuilder: (context, i) => RestaurantCardH(
                    r: results[i],
                    onTap: () {
                      context.read<AppBloc>().add(SelectRestaurant(results[i]));
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AppBloc>(),
                            child: const RestaurantDetailScreen())));
                    },
                    onFav: () => context.read<AppBloc>().add(ToggleFavorite(results[i].id)),
                  ),
                )),
        ]),
      );
    });
  }
}
