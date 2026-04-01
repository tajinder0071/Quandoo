import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/app_bloc.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 3, child: Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        automaticallyImplyLeading: false,
        title: Text('My Bookings', style: GoogleFonts.playfairDisplay(
            fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text1)),
        bottom: TabBar(
          labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 13),
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.text3,
          indicator: UnderlineTabIndicator(
              borderSide: const BorderSide(color: AppTheme.primary, width: 2.5),
              insets: const EdgeInsets.symmetric(horizontal: 12)),
          dividerColor: AppTheme.border,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
        ),
      ),
      body: BlocBuilder<AppBloc, AppState>(builder: (context, state) =>
        TabBarView(children: [
          _BookingList(bookings: state.activeBookings, status: BookingStatus.active),
          _BookingList(bookings: state.completedBookings, status: BookingStatus.completed),
          _BookingList(bookings: state.cancelledBookings, status: BookingStatus.cancelled),
        ]),
      ),
    ));
  }
}

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final BookingStatus status;
  const _BookingList({required this.bookings, required this.status});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(status == BookingStatus.active ? Icons.event_seat_outlined
          : status == BookingStatus.completed ? Icons.check_circle_outline_rounded
          : Icons.cancel_outlined, size: 52, color: AppTheme.text3),
      const SizedBox(height: 14),
      Text('No ${status.name} bookings', style: GoogleFonts.dmSans(
          fontSize: 16, color: AppTheme.text2)),
      const SizedBox(height: 6),
      Text('Your reservations will appear here.', style: GoogleFonts.dmSans(
          fontSize: 13, color: AppTheme.text3)),
    ]));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: bookings.length,
      itemBuilder: (context, i) => _BookingCard(booking: bookings[i]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  Color get _statusColor => booking.status == BookingStatus.active
      ? AppTheme.success
      : booking.status == BookingStatus.completed
          ? AppTheme.primary
          : AppTheme.error;

  String get _statusLabel => booking.status.name[0].toUpperCase() + booking.status.name.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        // Top: image + info
        Stack(children: [
          SizedBox(height: 130, width: double.infinity, child: NetImg(booking.restaurantImage)),
          Container(height: 130, decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
          Positioned(top: 10, right: 10,
            child: StatusBadge(label: _statusLabel, color: _statusColor)),
          Positioned(bottom: 12, left: 14, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.restaurantName, style: GoogleFonts.playfairDisplay(
                  fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.white)),
              Text(booking.tableType, style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppTheme.text2)),
            ])),
        ]),
        // Details
        Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _detail(Icons.calendar_today_rounded,
                DateFormat('EEE, MMM d').format(booking.date)),
            _vline(),
            _detail(Icons.access_time_rounded, booking.timeSlot),
            _vline(),
            _detail(Icons.people_rounded, '${booking.guests} guests'),
          ]),
          if (booking.status == BookingStatus.active) ...[
            const SizedBox(height: 14),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: const BorderSide(color: AppTheme.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10)),
                child: Text('Cancel', style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600)))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Get Direction', style: GoogleFonts.dmSans(
                    fontSize: 13, fontWeight: FontWeight.w600)))),
            ]),
          ],
        ])),
      ]),
    );
  }

  Widget _detail(IconData icon, String label) => Column(children: [
    Icon(icon, color: AppTheme.primary, size: 16),
    const SizedBox(height: 4),
    Text(label, style: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text1)),
  ]);

  Widget _vline() => Container(width: 1, height: 32, color: AppTheme.border);

  void _showCancelDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Cancel Reservation?', style: GoogleFonts.playfairDisplay(
          fontSize: 20, color: AppTheme.text1)),
      content: Text('Are you sure you want to cancel your reservation at ${booking.restaurantName}?',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2, height: 1.6)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Keep', style: GoogleFonts.dmSans(
              color: AppTheme.primary, fontWeight: FontWeight.w600))),
        TextButton(
          onPressed: () {
            context.read<AppBloc>().add(CancelBooking(booking.id));
            Navigator.pop(context);
          },
          child: Text('Cancel Booking', style: GoogleFonts.dmSans(
              color: AppTheme.error, fontWeight: FontWeight.w600))),
      ],
    ),
  );
}
