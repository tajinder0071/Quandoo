import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/reservation/reservation_bloc.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_widgets.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        final reservation = state.reservations.isNotEmpty
            ? state.reservations.last
            : null;

        return Scaffold(
          backgroundColor: AppTheme.black,
          body: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 200 : 24,
                    vertical: 60,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated check icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.gold, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppTheme.gold,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const GoldDivider(width: 80),
                      const SizedBox(height: 24),
                      Text(
                        'Reservation Confirmed',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: isWide ? 42 : 32,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.textPrimary,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We look forward to welcoming you to Maison Dorée.',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      if (reservation != null) _ConfirmationCard(reservation: reservation),
                      const SizedBox(height: 40),

                      // Action buttons
                      Column(
                        children: [
                          LuxuryButton(
                            label: 'Return Home',
                            onPressed: () {
                              Navigator.popUntil(context, (r) => r.isFirst);
                            },
                            width: double.infinity,
                          ),
                          const SizedBox(height: 12),
                          LuxuryButton(
                            label: 'View My Reservations',
                            outlined: true,
                            onPressed: () {
                              Navigator.popUntil(context, (r) => r.isFirst);
                              // Navigate to My Reservations — handled from home
                            },
                            width: double.infinity,
                          ),
                        ],
                      ),
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
}

class _ConfirmationCard extends StatelessWidget {
  final dynamic reservation;
  const _ConfirmationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, MMMM d, y');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF8EE), Color(0xFFF5EDD8)],
        ),
        border: Border.all(color: AppTheme.goldDark.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MAISON DORÉE',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  color: AppTheme.gold,
                  letterSpacing: 3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.success,
                ),
                child: Text(
                  'CONFIRMED',
                  style: GoogleFonts.montserrat(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reservation #${reservation.id.substring(0, 8).toUpperCase()}',
            style: GoogleFonts.montserrat(
              fontSize: 10,
              color: AppTheme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
           Divider(color: AppTheme.cream),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailItem(Icons.person_outline, 'Guest', reservation.guestName),
                    const SizedBox(height: 12),
                    _DetailItem(Icons.table_restaurant, 'Table', reservation.tableName),
                    const SizedBox(height: 12),
                    _DetailItem(Icons.people_outline, 'Party Size', '${reservation.guests} guests'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailItem(Icons.calendar_today_outlined, 'Date',
                        df.format(reservation.date)),
                    const SizedBox(height: 12),
                    _DetailItem(Icons.access_time_outlined, 'Time', reservation.timeSlot),
                    const SizedBox(height: 12),
                    if (reservation.occasion != 'None')
                      _DetailItem(Icons.celebration_outlined, 'Occasion', reservation.occasion),
                  ],
                ),
              ),
            ],
          ),
          if (reservation.specialRequests != null && reservation.specialRequests!.isNotEmpty) ...[
            const SizedBox(height: 16),
             Divider(color: AppTheme.cream),
            const SizedBox(height: 12),
            _DetailItem(Icons.notes, 'Special Requests', reservation.specialRequests!),
          ],
          const SizedBox(height: 16),
          const Divider(color: AppTheme.cream),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.mail_outline, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Confirmation sent to ${reservation.guestEmail}',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.gold),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.montserrat(
                  fontSize: 9,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
