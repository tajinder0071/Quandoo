import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/app_bloc.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'auth_screen.dart';
import 'bookings_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        final user = state.currentUser;
        final initials = _initials(user?.name ?? 'Guest');
        final name = user?.name ?? 'Guest';
        final email = user?.email ?? '';

        return Scaffold(
          backgroundColor: AppTheme.bg,
          body: CustomScrollView(
            slivers: [
              // ── Hero header ────────────────────────────────────
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  initials: initials,
                  name: name,
                  email: email,
                  onEdit: () => _showEditSheet(context, name, email),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Stats ─────────────────────────────────────
                      _StatsRow(state: state),
                      SizedBox(height: 20),

                      // ── Membership card ───────────────────────────
                      _MembershipCard(bookingCount: state.bookings.length),
                      SizedBox(height: 24),

                      // ── Recent bookings ───────────────────────────
                      if (state.bookings.isNotEmpty) ...[
                        _SectionTitle('Recent Bookings'),
                        SizedBox(height: 12),
                        _RecentBookings(
                          bookings: state.bookings.take(3).toList(),
                          onSeeAll: () =>
                              context.read<AppBloc>().add(ChangeTab(2)),
                        ),
                        SizedBox(height: 24),
                      ],

                      // ── Account settings ──────────────────────────
                      _SectionTitle('Account'),
                      SizedBox(height: 12),
                      _MenuCard(
                        items: [
                          _MenuItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Edit Profile',
                            color: AppTheme.primary,
                            onTap: () => _showEditSheet(context, name, email),
                          ),
                          _MenuItem(
                            icon: Icons.credit_card_outlined,
                            label: 'Payment Methods',
                            color: AppTheme.gold,
                            onTap: () =>
                                _showComingSoon(context, 'Payment Methods'),
                          ),
                          _MenuItem(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            color: AppTheme.warning,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AppBloc>(),
                                  child: NotificationsScreen(),
                                ),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icons.lock_outline_rounded,
                            label: 'Change Password',
                            color: AppTheme.success,
                            onTap: () => _showChangePasswordSheet(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // ── Preferences ───────────────────────────────
                      _SectionTitle('Preferences'),
                      SizedBox(height: 12),
                      _PreferencesCard(),
                      SizedBox(height: 16),

                      // ── Support ───────────────────────────────────
                      _SectionTitle('Support'),
                      SizedBox(height: 12),
                      _MenuCard(
                        items: [
                          _MenuItem(
                            icon: Icons.help_outline_rounded,
                            label: 'Help Center',
                            color: AppTheme.primary,
                            onTap: () =>
                                _showComingSoon(context, 'Help Center'),
                          ),
                          _MenuItem(
                            icon: Icons.privacy_tip_outlined,
                            label: 'Privacy Policy',
                            color: AppTheme.text2,
                            onTap: () =>
                                _showComingSoon(context, 'Privacy Policy'),
                          ),
                          _MenuItem(
                            icon: Icons.people_outline_rounded,
                            label: 'Invite Friends',
                            color: AppTheme.gold,
                            onTap: () =>
                                _showComingSoon(context, 'Invite Friends'),
                          ),
                          _MenuItem(
                            icon: Icons.star_border_rounded,
                            label: 'Rate TableLux',
                            color: AppTheme.star,
                            onTap: () => _showComingSoon(context, 'Rate App'),
                            trailing: '⭐ 4.8',
                          ),
                          _MenuItem(
                            icon: Icons.info_outline_rounded,
                            label: 'App Version',
                            color: AppTheme.text3,
                            onTap: () {},
                            trailing: 'v1.0.0',
                            isChevron: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Logout button ─────────────────────────────
                      _LogoutButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'G';
  }

  void _showEditSheet(BuildContext context, String name, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AppBloc>(),
        child: _EditProfileSheet(name: name, email: email),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label coming soon!',
          style: GoogleFonts.dmSans(color: AppTheme.white),
        ),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ── Profile header ────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String initials, name, email;
  final VoidCallback onEdit;

  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.email,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.bg, AppTheme.card, AppTheme.bg],
          stops: [0, 0.6, 1],
        ),
      ),
      child: Stack(
        children: [
          // Decorative rings
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.gold.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
          ),

          // Settings button (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: AppTheme.text1,
                  size: 18,
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.primary, AppTheme.primaryDk],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.bg, width: 2),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            size: 12,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // Name
                  Text(
                    name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Email
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 13,
                        color: AppTheme.text3,
                      ),
                      SizedBox(width: 5),
                      Text(
                        email,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.text2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // Edit button
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.primary.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: AppTheme.primary.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: AppTheme.primary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
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

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AppState state;

  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _statCard(
        '${state.bookings.length}',
        'Bookings',
        Icons.event_seat_rounded,
        AppTheme.primary,
      ),
      SizedBox(width: 10),
      _statCard(
        '${state.favorites.length}',
        'Favourites',
        Icons.favorite_rounded,
        AppTheme.error,
      ),
      SizedBox(width: 10),
      _statCard(
        '${state.activeBookings.length}',
        'Active',
        Icons.check_circle_outline_rounded,
        AppTheme.success,
      ),
    ],
  );

  Widget _statCard(String v, String l, IconData icon, Color color) => Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: 8),
          Text(
            v,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.text1,
            ),
          ),
          Text(
            l,
            style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text2),
          ),
        ],
      ),
    ),
  );
}

// ── Membership card ───────────────────────────────────────────────────────────
class _MembershipCard extends StatelessWidget {
  final int bookingCount;

  const _MembershipCard({required this.bookingCount});

  String get _tier {
    if (bookingCount >= 20) return 'Platinum';
    if (bookingCount >= 10) return 'Gold';
    if (bookingCount >= 3) return 'Silver';
    return 'Bronze';
  }

  Color get _tierColor {
    switch (_tier) {
      case 'Platinum':
        return const Color(0xFFB4C7D4);
      case 'Gold':
        return AppTheme.gold;
      case 'Silver':
        return const Color(0xFFA8A9AD);
      default:
        return const Color(0xFFCD7F32);
    }
  }

  int get _nextMilestone {
    if (bookingCount < 3) return 3;
    if (bookingCount < 10) return 10;
    if (bookingCount < 20) return 20;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final progress = (bookingCount / _nextMilestone).clamp(0.0, 1.0);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.card, AppTheme.surface],
        ),
        border: Border.all(color: _tierColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: _tierColor.withOpacity(0.1),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _tierColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _tierColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: _tierColor,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '$_tier Member',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _tierColor,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                'TableLux',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text1.withOpacity(0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Booking count
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$bookingCount',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text1,
                  height: 1,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 6, left: 6),
                child: Text(
                  'bookings',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.text2,
                  ),
                ),
              ),
              Spacer(),
              if (bookingCount < 20)
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _tierColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_nextMilestone - bookingCount} more',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: _tierColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'to next tier',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: AppTheme.text3,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.border,
              color: _tierColor,
              minHeight: 6,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Progress to ${_tier == 'Platinum' ? 'max tier' : _nextTier}',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3),
              ),
              Spacer(),
              Text(
                '$bookingCount / $_nextMilestone',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: _tierColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _nextTier {
    if (bookingCount < 3) return 'Silver';
    if (bookingCount < 10) return 'Gold';
    return 'Platinum';
  }
}

// ── Recent bookings ───────────────────────────────────────────────────────────
class _RecentBookings extends StatelessWidget {
  final List<Booking> bookings;
  final VoidCallback onSeeAll;

  const _RecentBookings({required this.bookings, required this.onSeeAll});

  Color _statusColor(BookingStatus s) => s == BookingStatus.active
      ? AppTheme.success
      : s == BookingStatus.cancelled
      ? AppTheme.error
      : AppTheme.primary;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ...bookings.map(
        (b) => Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // Restaurant image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: NetImg(b.restaurantImage),
                ),
              ),
              SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.restaurantName,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3),
                    Text(
                      '${DateFormat('MMM d, y').format(b.date)} · ${b.timeSlot}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppTheme.text2,
                      ),
                    ),
                    Text(
                      '${b.guests} guests · ${b.tableType}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppTheme.text3,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(b.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  b.status.name[0].toUpperCase() + b.status.name.substring(1),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(b.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      TextButton(
        onPressed: onSeeAll,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View All Bookings',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_rounded,
              size: 14,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    ],
  );
}

// ── Preferences card (toggles) ────────────────────────────────────────────────
class _PreferencesCard extends StatefulWidget {
  @override
  State<_PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<_PreferencesCard> {
  bool _pushNotifs = true;
  bool _emailPromo = false;
  bool _locationAccess = true;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        _toggle(
          'Push Notifications',
          Icons.notifications_outlined,
          AppTheme.warning,
          _pushNotifs,
          (v) => setState(() => _pushNotifs = v),
        ),
        Divider(color: AppTheme.border, height: 1, indent: 54),
        _toggle(
          'Promotional Emails',
          Icons.mail_outline_rounded,
          AppTheme.primary,
          _emailPromo,
          (v) => setState(() => _emailPromo = v),
        ),
        Divider(color: AppTheme.border, height: 1, indent: 54),
        _toggle(
          'Location Access',
          Icons.location_on_outlined,
          AppTheme.success,
          _locationAccess,
          (v) => setState(() => _locationAccess = v),
        ),
      ],
    ),
  );

  Widget _toggle(
    String label,
    IconData icon,
    Color color,
    bool value,
    ValueChanged<bool> onChanged,
  ) => ListTile(
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    leading: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    ),
    title: Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppTheme.text1,
      ),
    ),
    trailing: Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
    ),
  );
}

// ── Menu card ─────────────────────────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(16),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: List.generate(items.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Divider(color: AppTheme.border, height: 1, indent: 54);
        }
        final item = items[i ~/ 2];
        return ListTile(
          onTap: item.onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          title: Text(
            item.label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.text1,
            ),
          ),
          trailing: item.trailing != null
              ? Text(
                  item.trailing!,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.text2,
                  ),
                )
              : item.isChevron
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.text3,
                  size: 20,
                )
              : null,
        );
      }),
    ),
  );
}

// ── Logout button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _confirmLogout(context),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.error.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.logout_rounded, color: AppTheme.error, size: 16),
          ),
          SizedBox(width: 10),
          Text(
            'Log Out',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.error,
            ),
          ),
        ],
      ),
    ),
  );

  void _confirmLogout(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Log Out?',
        style: GoogleFonts.playfairDisplay(fontSize: 20, color: AppTheme.text1),
      ),
      content: Text(
        'Are you sure you want to log out of your account?',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppTheme.text2,
          height: 1.6,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.dmSans(
              color: AppTheme.text2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AppBloc>().add(LogoutUser());
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => AuthScreen()),
              (_) => false,
            );
          },
          child: Text(
            'Log Out',
            style: GoogleFonts.dmSans(
              color: AppTheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Section title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppTheme.text3,
      letterSpacing: 1.2,
    ),
  );
}

// ── Edit profile bottom sheet ─────────────────────────────────────────────────
class _EditProfileSheet extends StatefulWidget {
  final String name, email;

  const _EditProfileSheet({required this.name, required this.email});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _emailCtrl = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Edit Profile',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.text1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Update your personal information.',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2),
          ),
          SizedBox(height: 24),
          _sheetLabel('Full Name'),
          SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1),
            decoration: InputDecoration(
              hintText: 'Your full name',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: AppTheme.text3,
              ),
            ),
          ),
          SizedBox(height: 16),

          _sheetLabel('Email Address'),
          SizedBox(height: 6),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1),
            decoration: InputDecoration(
              hintText: 'your@email.com',
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                size: 20,
                color: AppTheme.text3,
              ),
            ),
          ),
          SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      await Future.delayed(Duration(milliseconds: 800));
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Profile updated!',
                            style: GoogleFonts.dmSans(color: AppTheme.white),
                          ),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Save Changes',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetLabel(String t) => Text(
    t,
    style: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppTheme.text2,
    ),
  );
}

// ── Change password bottom sheet ──────────────────────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confCtrl = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _currCtrl.dispose();
    _newCtrl.dispose();
    _confCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Change Password',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.text1,
            ),
          ),
          SizedBox(height: 20),

          _passField('Current Password', _currCtrl),
          SizedBox(height: 12),
          _passField('New Password', _newCtrl),
          SizedBox(height: 12),
          _passField('Confirm New Password', _confCtrl),
          SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      if (_newCtrl.text != _confCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Passwords do not match.',
                              style: GoogleFonts.dmSans(color: AppTheme.white),
                            ),
                            backgroundColor: AppTheme.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }
                      setState(() => _saving = true);
                      await Future.delayed(Duration(milliseconds: 900));
                      if (!mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Password updated successfully!',
                            style: GoogleFonts.dmSans(color: AppTheme.white),
                          ),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Update Password',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passField(String label, TextEditingController ctrl) => TextField(
    controller: ctrl,
    obscureText: _obscure,
    style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1),
    decoration: InputDecoration(
      hintText: label,
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        size: 20,
        color: AppTheme.text3,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppTheme.text3,
          size: 18,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
    ),
  );
}

// ── Data model ────────────────────────────────────────────────────────────────
class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? trailing;
  final bool isChevron;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.trailing,
    this.isChevron = true,
  });
}
