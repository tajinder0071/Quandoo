import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import 'splash_screen.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: CustomScrollView(slivers: [

          // ── Profile header ────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.bg,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Container(padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.settings_outlined,
                      color: AppTheme.text1, size: 18)),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Container(decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A2E45), AppTheme.bg]))),
                // Decorative circles
                Positioned(top: -30, right: -30, child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.08), width: 1)))),
                SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  const SizedBox(height: 16),
                  Stack(alignment: Alignment.bottomRight, children: [
                    Container(width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDk]),
                        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.35),
                            blurRadius: 20, spreadRadius: 2)]),
                      child: Center(child: Text('A',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 38, fontWeight: FontWeight.w700,
                            color: AppTheme.white)))),
                    Container(width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.bg, width: 2)),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 13, color: AppTheme.primary)),
                  ]),
                  const SizedBox(height: 12),
                  Text('Alex Johnson', style: GoogleFonts.playfairDisplay(
                      fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                  const SizedBox(height: 3),
                  Text('alex.johnson@email.com', style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppTheme.text2)),
                ])),
              ]),
            ),
          ),

          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Stats row
              Row(children: [
                _stat('${state.bookings.length}', 'Bookings', Icons.event_seat_rounded),
                const SizedBox(width: 10),
                _stat('${state.favorites.length}', 'Favourites', Icons.favorite_rounded),
                const SizedBox(width: 10),
                _stat('4.8', 'Avg Rating', Icons.star_rounded),
              ]),
              const SizedBox(height: 24),

              // Account section
              _sectionTitle('Account'),
              const SizedBox(height: 10),
              _menuCard([
                _MenuItem(Icons.person_outline_rounded, 'Your Profile', AppTheme.primary, () {}),
                _MenuItem(Icons.credit_card_outlined, 'Payment Methods', AppTheme.gold, () {}),
                _MenuItem(Icons.notifications_outlined, 'Notifications', AppTheme.warning, () {}),
                _MenuItem(Icons.language_rounded, 'Language', AppTheme.success, () {}, trailing: 'English'),
              ]),

              const SizedBox(height: 16),
              _sectionTitle('Support'),
              const SizedBox(height: 10),
              _menuCard([
                _MenuItem(Icons.help_outline_rounded, 'Help Center', AppTheme.primary, () {}),
                _MenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', AppTheme.text2, () {}),
                _MenuItem(Icons.people_outline_rounded, 'Invite Friends', AppTheme.gold, () {}),
                _MenuItem(Icons.star_border_rounded, 'Rate the App', AppTheme.star, () {}),
              ]),

              const SizedBox(height: 16),
              // Logout
              GestureDetector(
                onTap: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.error.withOpacity(0.2))),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.logout_rounded,
                          color: AppTheme.error, size: 18)),
                    const SizedBox(width: 14),
                    Text('Log Out', style: GoogleFonts.dmSans(
                        fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.error)),
                  ]),
                ),
              ),
              const SizedBox(height: 30),
            ]),
          )),
        ]),
      );
    });
  }

  Widget _stat(String value, String label, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.playfairDisplay(
            fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.text1)),
        Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text2)),
      ]),
    ),
  );

  Widget _sectionTitle(String t) => Text(t.toUpperCase(),
    style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w700,
        color: AppTheme.text3, letterSpacing: 1.2));

  Widget _menuCard(List<_MenuItem> items) => Container(
    decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
    child: Column(children: List.generate(items.length * 2 - 1, (i) {
      if (i.isOdd) return const Divider(color: AppTheme.border, height: 1, indent: 54);
      final item = items[i ~/ 2];
      return ListTile(
        onTap: item.onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
          child: Icon(item.icon, color: item.color, size: 18)),
        title: Text(item.label, style: GoogleFonts.dmSans(
            fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.text1)),
        trailing: item.trailing != null
            ? Text(item.trailing!, style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.text2))
            : const Icon(Icons.chevron_right_rounded,
                color: AppTheme.text3, size: 20),
      );
    })),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? trailing;
  const _MenuItem(this.icon, this.label, this.color, this.onTap, {this.trailing});
}
