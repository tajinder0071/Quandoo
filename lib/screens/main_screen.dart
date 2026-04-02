import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'bookings_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const _screens = [
    HomeScreen(),
    DiscoverScreen(),
    BookingsScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (a, b) => a.currentTab != b.currentTab,
      builder: (context, state) => Scaffold(
        backgroundColor: AppTheme.bg,
        body: IndexedStack(index: state.currentTab, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border:  Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2),
                blurRadius: 16, offset:  Offset(0, -4))],
          ),
          child: SafeArea(
            child: Padding(
              padding:  EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
                  _NavItem(icon: Icons.explore_rounded, label: 'Discover', index: 1),
                  _NavItem(icon: Icons.bookmark_rounded, label: 'Bookings', index: 2),
                  _NavItem(icon: Icons.favorite_rounded, label: 'Wishlist', index: 3),
                  _NavItem(icon: Icons.person_rounded, label: 'Profile', index: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  const _NavItem({required this.icon, required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      buildWhen: (a, b) => a.currentTab != b.currentTab,
      builder: (context, state) {
        final selected = state.currentTab == index;
        return GestureDetector(
          onTap: () => context.read<AppBloc>().add(ChangeTab(index)),
          child: AnimatedContainer(
            duration:  Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: selected ? AppTheme.primary : AppTheme.text3, size: 22),
              SizedBox(height: 3),
              Text(label, style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.primary : AppTheme.text3)),
            ]),
          ),
        );
      },
    );
  }
}
