import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../blocs/app_bloc.dart';
import '../theme/app_theme.dart';
import '../models/booking.dart';
import '../widgets/common.dart';

class BookTableScreen extends StatefulWidget {
  const BookTableScreen({super.key});
  @override State<BookTableScreen> createState() => _BookState();
}

class _BookState extends State<BookTableScreen> {
  final _nameCtrl = TextEditingController();
  final _reqCtrl  = TextEditingController();
  int _step = 0;

  @override void dispose() { _nameCtrl.dispose(); _reqCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppBloc, AppState>(
      listenWhen: (a, b) => !a.isSubmitting && b.lastBooking != a.lastBooking,
      listener: (context, state) {
        if (state.lastBooking != null && !state.isSubmitting) {
          Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<AppBloc>(),
                child: const BookingSuccessScreen())));
        }
      },
      builder: (context, state) {
        final r = state.selectedRestaurant!;
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            backgroundColor: AppTheme.bg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => _step > 0 ? setState(() => _step--) : Navigator.pop(context)),
            title: Text('Book a Table', style: GoogleFonts.dmSans(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.text1)),
            bottom: PreferredSize(preferredSize: const Size.fromHeight(4),
              child: _StepIndicator(currentStep: _step, totalSteps: 3)),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim,
              child: SlideTransition(position: Tween<Offset>(
                  begin: const Offset(0.05, 0), end: Offset.zero).animate(anim), child: child)),
            child: _buildStep(context, state, r),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, AppState state, r) {
    switch (_step) {
      case 0: return _Step1(key: const ValueKey(0),
          state: state, onNext: () => setState(() => _step = 1));
      case 1: return _Step2(key: const ValueKey(1),
          state: state, nameCtrl: _nameCtrl, reqCtrl: _reqCtrl,
          onNext: () => setState(() => _step = 2));
      case 2: return _Step3(key: const ValueKey(2), state: state, nameCtrl: _nameCtrl, reqCtrl: _reqCtrl);
      default: return const SizedBox.shrink();
    }
  }
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep, totalSteps;
  const _StepIndicator({required this.currentStep, required this.totalSteps});
  @override
  Widget build(BuildContext context) => Row(
    children: List.generate(totalSteps, (i) => Expanded(child: Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: i <= currentStep ? AppTheme.primary : AppTheme.border,
        borderRadius: BorderRadius.circular(2))))),
  );
}

// ── Step 1: Date + Time + Guests + Table ──────────────────────────────────────
class _Step1 extends StatelessWidget {
  final AppState state;
  final VoidCallback onNext;
  const _Step1({super.key, required this.state, required this.onNext});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select Date', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
      const SizedBox(height: 12),
      // Calendar
      Container(decoration: BoxDecoration(color: AppTheme.card,
          borderRadius: BorderRadius.circular(16)),
        child: CalendarDatePicker(
          initialDate: state.selectedDate ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 90)),
          onDateChanged: (d) => context.read<AppBloc>().add(SelectDate(d)),
        )),

      const SizedBox(height: 20),
      Text('Select Time', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2),
        itemCount: timeSlots.length,
        itemBuilder: (_, i) {
          final slot = timeSlots[i];
          final sel = state.selectedTimeSlot == slot;
          final unavail = i % 7 == 3;
          return GestureDetector(
            onTap: unavail ? null : () => context.read<AppBloc>().add(SelectTimeSlot(slot)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: sel ? AppTheme.primary : unavail ? AppTheme.surface.withOpacity(0.4) : AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? AppTheme.primary : AppTheme.border)),
              alignment: Alignment.center,
              child: Text(slot, style: GoogleFonts.dmSans(fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sel ? AppTheme.white : unavail ? AppTheme.text3 : AppTheme.text1,
                decoration: unavail ? TextDecoration.lineThrough : null)),
            ),
          );
        },
      ),

      const SizedBox(height: 20),
      Text('Number of Guests', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
      const SizedBox(height: 12),
      Row(children: List.generate(8, (i) {
        final n = i + 1;
        final sel = state.selectedGuests == n;
        return Expanded(child: GestureDetector(
          onTap: () => context.read<AppBloc>().add(SelectGuests(n)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(right: 6),
            height: 44,
            decoration: BoxDecoration(
              color: sel ? AppTheme.primary : AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? AppTheme.primary : AppTheme.border)),
            alignment: Alignment.center,
            child: Text('$n', style: GoogleFonts.dmSans(fontSize: 14,
                fontWeight: FontWeight.w700,
                color: sel ? AppTheme.white : AppTheme.text1)),
          ),
        ));
      })),

      const SizedBox(height: 20),
      Text('Table Preference', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
      const SizedBox(height: 12),
      ...tableTypes.map((t) {
        final sel = state.selectedTableType == t;
        return GestureDetector(
          onTap: () => context.read<AppBloc>().add(SelectTableType(t)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? AppTheme.primary.withOpacity(0.1) : AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? AppTheme.primary : AppTheme.border, width: sel ? 1.5 : 1)),
            child: Row(children: [
              Icon(Icons.table_restaurant_outlined,
                  color: sel ? AppTheme.primary : AppTheme.text3, size: 20),
              const SizedBox(width: 12),
              Text(t, style: GoogleFonts.dmSans(fontSize: 14,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? AppTheme.primary : AppTheme.text1)),
              const Spacer(),
              if (sel) const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18),
            ]),
          ),
        );
      }),

      const SizedBox(height: 24),
      PrimaryBtn(
        label: 'Continue',
        icon: Icons.arrow_forward_rounded,
        onPressed: state.selectedDate != null && state.selectedTimeSlot.isNotEmpty ? onNext : null,
      ),
    ]),
  );
}

// ── Step 2: Guest Details ─────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final AppState state;
  final TextEditingController nameCtrl, reqCtrl;
  final VoidCallback onNext;
  const _Step2({super.key, required this.state, required this.nameCtrl,
    required this.reqCtrl, required this.onNext});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your Details', style: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text1)),
      const SizedBox(height: 4),
      Text('We\'ll use this to confirm your reservation.',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
      const SizedBox(height: 24),

      _label('Full Name'),
      const SizedBox(height: 6),
      TextField(controller: nameCtrl,
        onChanged: (v) => context.read<AppBloc>().add(SetGuestName(v)),
        style: GoogleFonts.dmSans(color: AppTheme.text1),
        decoration: const InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.text3))),
      const SizedBox(height: 16),

      _label('Special Requests (Optional)'),
      const SizedBox(height: 6),
      TextField(controller: reqCtrl, maxLines: 3,
        onChanged: (v) => context.read<AppBloc>().add(SetSpecialRequest(v)),
        style: GoogleFonts.dmSans(color: AppTheme.text1),
        decoration: const InputDecoration(hintText: 'Allergies, celebrations, dietary needs...')),
      const SizedBox(height: 24),

      // Policy note
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.warning.withOpacity(0.3))),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(
            'Cancellations must be made at least 24 hours in advance to avoid charges.',
            style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.warning, height: 1.5))),
        ])),

      const SizedBox(height: 24),
      PrimaryBtn(
        label: 'Review Booking',
        icon: Icons.arrow_forward_rounded,
        onPressed: nameCtrl.text.trim().isNotEmpty ? onNext : null,
      ),
    ]),
  );

  Widget _label(String t) => Text(t, style: GoogleFonts.dmSans(
      fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text2));
}

// ── Step 3: Review & Confirm ──────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final AppState state;
  final TextEditingController nameCtrl, reqCtrl;
  const _Step3({super.key, required this.state, required this.nameCtrl, required this.reqCtrl});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Review Summary', style: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text1)),
      const SizedBox(height: 20),

      // Restaurant card
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          ClipRRect(borderRadius: BorderRadius.circular(10),
            child: SizedBox(width: 70, height: 70,
              child: NetImg(state.selectedRestaurant!.imageUrl))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(state.selectedRestaurant!.name, style: GoogleFonts.playfairDisplay(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
            Text(state.selectedRestaurant!.location, style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.text2)),
            const SizedBox(height: 4),
            StarRating(state.selectedRestaurant!.rating, size: 12),
          ])),
        ])),

      const SizedBox(height: 16),

      // Booking details
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          _row(Icons.calendar_today_rounded, 'Date',
              DateFormat('EEEE, MMMM d, y').format(state.selectedDate!)),
          const Divider(color: AppTheme.border, height: 20),
          _row(Icons.access_time_rounded, 'Time', state.selectedTimeSlot),
          const Divider(color: AppTheme.border, height: 20),
          _row(Icons.people_rounded, 'Guests', '${state.selectedGuests} persons'),
          const Divider(color: AppTheme.border, height: 20),
          _row(Icons.table_restaurant_outlined, 'Table', state.selectedTableType),
          const Divider(color: AppTheme.border, height: 20),
          _row(Icons.person_outline_rounded, 'Name', nameCtrl.text.trim()),
          if (reqCtrl.text.trim().isNotEmpty) ...[
            const Divider(color: AppTheme.border, height: 20),
            _row(Icons.notes_rounded, 'Requests', reqCtrl.text.trim()),
          ],
        ])),

      const SizedBox(height: 16),

      // Price breakdown
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
        child: Column(children: [
          _row(Icons.receipt_outlined, 'Per person', '\$45.00'),
          const Divider(color: AppTheme.border, height: 20),
          _row(Icons.people_rounded, '× ${state.selectedGuests} guests',
              '\$${(state.selectedGuests * 45).toStringAsFixed(2)}'),
          const Divider(color: AppTheme.border, height: 20),
          Row(children: [
            Text('Total', style: GoogleFonts.dmSans(
                fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
            const Spacer(),
            Text('\$${(state.selectedGuests * 45).toStringAsFixed(2)}',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ]),
        ])),

      const SizedBox(height: 24),
      PrimaryBtn(
        label: 'Confirm Reservation',
        isLoading: state.isSubmitting,
        onPressed: () => context.read<AppBloc>().add(SubmitBooking()),
      ),
    ]),
  );

  Widget _row(IconData icon, String label, String value) => Row(children: [
    Icon(icon, color: AppTheme.primary, size: 16),
    const SizedBox(width: 10),
    Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
    const Spacer(),
    Flexible(child: Text(value, style: GoogleFonts.dmSans(
        fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text1),
      textAlign: TextAlign.right)),
  ]);
}

// ── Booking Success ───────────────────────────────────────────────────────────
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final b = state.lastBooking!;
      return Scaffold(
        backgroundColor: AppTheme.bg,
        body: SafeArea(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            // Success animation
            Container(width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryDk]),
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 32, spreadRadius: 4)],
              ),
              child: const Icon(Icons.check_rounded, color: AppTheme.white, size: 56)),
            const SizedBox(height: 28),
            Text('Table Reserved! 🎉', style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.text1)),
            const SizedBox(height: 8),
            Text('Your reservation is confirmed. We look forward to welcoming you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text2, height: 1.6)),
            const SizedBox(height: 32),

            // E-Ticket
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border)),
              child: Column(children: [
                Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 60, height: 60,
                      child: NetImg(b.restaurantImage))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.restaurantName, style: GoogleFonts.dmSans(
                        fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                    Text(b.tableType, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
                  ])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('CONFIRMED', style: GoogleFonts.dmSans(
                        fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.success))),
                ]),
                const SizedBox(height: 16),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 12),
                // Dashed separator
                Row(children: [
                  Text('BOOKING #${b.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3,
                        letterSpacing: 1)),
                  const Spacer(),
                  Text(DateFormat('MMM d, y').format(b.bookedAt),
                    style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3)),
                ]),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _ticket(Icons.calendar_today_rounded,
                    DateFormat('EEE, MMM d').format(b.date), 'Date'),
                  _vline(),
                  _ticket(Icons.access_time_rounded, b.timeSlot, 'Time'),
                  _vline(),
                  _ticket(Icons.people_rounded, '${b.guests} guests', 'Party'),
                ]),
              ]),
            ),
            const Spacer(),
            PrimaryBtn(
              label: 'Back to Home',
              onPressed: () {
                context.read<AppBloc>().add(const ChangeTab(0));
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.read<AppBloc>().add(const ChangeTab(2));
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('View My Bookings', style: GoogleFonts.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ]),
        )),
      );
    });
  }

  Widget _ticket(IconData icon, String value, String label) => Column(children: [
    Icon(icon, color: AppTheme.primary, size: 18),
    const SizedBox(height: 4),
    Text(value, style: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text1)),
    Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3)),
  ]);

  Widget _vline() => Container(width: 1, height: 40, color: AppTheme.border);
}
