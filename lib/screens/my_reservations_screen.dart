import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/reservation/reservation_bloc.dart';
import '../models/reservation.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_widgets.dart';
import 'reservation_flow_screen.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      backgroundColor: AppTheme.darkSurface,
      appBar: AppBar(
        backgroundColor: AppTheme.darkCard,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 16, color: AppTheme.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MY RESERVATIONS',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.gold,
            letterSpacing: 3,
          ),
        ),
      ),
      body: BlocBuilder<ReservationBloc, ReservationState>(
        builder: (context, state) {
          final reservations = state.reservations;

          if (reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: AppTheme.gold,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Reservations Yet',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your upcoming reservations will appear here.',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  LuxuryButton(
                    label: 'Make a Reservation',
                    onPressed: () {
                      context.read<ReservationBloc>().add(ResetReservation());
                      Navigator.pushReplacement(
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
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 80 : 20,
              vertical: 32,
            ),
            itemCount: reservations.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ReservationCard(reservation: reservations[i]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.gold,
        foregroundColor: AppTheme.black,
        icon: const Icon(Icons.add),
        label: Text(
          'NEW',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
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
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({required this.reservation});

  Color get _statusColor {
    switch (reservation.status) {
      case ReservationStatus.confirmed:
        return AppTheme.success;
      case ReservationStatus.pending:
        return AppTheme.gold;
      case ReservationStatus.cancelled:
        return AppTheme.error;
    }
  }

  String get _statusLabel {
    switch (reservation.status) {
      case ReservationStatus.confirmed:
        return 'CONFIRMED';
      case ReservationStatus.pending:
        return 'PENDING';
      case ReservationStatus.cancelled:
        return 'CANCELLED';
    }
  }

  bool get _isPast =>
      reservation.date.isBefore(DateTime.now()) ||
      reservation.status == ReservationStatus.cancelled;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, MMM d · y');
    return Opacity(
      opacity: _isPast ? 0.6 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          border: Border.all(
            color: reservation.status == ReservationStatus.confirmed
                ? AppTheme.cream
                : reservation.status == ReservationStatus.cancelled
                ? AppTheme.error.withOpacity(0.3)
                : AppTheme.cream,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reservation.tableName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  color: _statusColor.withOpacity(0.15),
                  child: Text(
                    _statusLabel,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${reservation.id.substring(0, 8).toUpperCase()}',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppTheme.cream, height: 1),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _InfoChip(
                  Icons.calendar_today_outlined,
                  df.format(reservation.date),
                ),
                _InfoChip(Icons.access_time, reservation.timeSlot),
                _InfoChip(Icons.people_outline, '${reservation.guests} guests'),
                if (reservation.occasion != 'None')
                  _InfoChip(Icons.celebration_outlined, reservation.occasion),
              ],
            ),
            if (reservation.specialRequests != null &&
                reservation.specialRequests!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.notes,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      reservation.specialRequests!,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (reservation.status == ReservationStatus.confirmed &&
                reservation.date.isAfter(DateTime.now())) ...[
              const SizedBox(height: 16),
              Divider(color: AppTheme.cream, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showCancelDialog(context),
                    child: Text(
                      'CANCEL RESERVATION',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.error,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'Cancel Reservation?',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel your reservation at ${reservation.tableName}? This action cannot be undone.',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'KEEP RESERVATION',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppTheme.gold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<ReservationBloc>().add(
                CancelReservation(reservation.id),
              );
              Navigator.pop(context);
            },
            child: Text(
              'YES, CANCEL',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppTheme.error,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.gold),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
