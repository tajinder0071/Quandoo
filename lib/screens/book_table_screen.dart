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
      // ✅ Fire when: was submitting → now done AND a booking exists
      listenWhen: (a, b) => a.isSubmitting && !b.isSubmitting && b.lastBooking != null,
      listener: (context, state) {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => BlocProvider.value(
                value: context.read<AppBloc>(),
                child:  BookingSuccessScreen())));
      },
      builder: (context, state) {
        final r = state.selectedRestaurant!;
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(
            backgroundColor: AppTheme.bg,
            leading: IconButton(
                icon:  Icon(Icons.arrow_back_rounded),
                onPressed: () => _step > 0 ? setState(() => _step--) : Navigator.pop(context)),
            title: Text('Book a Table', style: GoogleFonts.dmSans(
                fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.text1)),
            bottom: PreferredSize(preferredSize:  Size.fromHeight(4),
                child: _StepIndicator(currentStep: _step, totalSteps: 3)),
          ),
          body: AnimatedSwitcher(
            duration:  Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim,
                child: SlideTransition(position: Tween<Offset>(
                    begin:  Offset(0.05, 0), end: Offset.zero).animate(anim), child: child)),
            child: _buildStep(context, state, r),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, AppState state, r) {
    switch (_step) {
      case 0: return _Step1(key:  ValueKey(0),
          state: state, onNext: () => setState(() => _step = 1));
      case 1: return _Step2(key:  ValueKey(1),
          state: state, nameCtrl: _nameCtrl, reqCtrl: _reqCtrl,
          onNext: () => setState(() => _step = 2));
      case 2: return _Step3(key:  ValueKey(2), state: state, nameCtrl: _nameCtrl, reqCtrl: _reqCtrl);
      default: return  SizedBox.shrink();
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
        margin:  EdgeInsets.symmetric(horizontal: 2),
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
    padding:  EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Select Date', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
       SizedBox(height: 12),

      // ── Custom BLoC-driven calendar ────────────────────────
      _LuxCalendar(selectedDate: state.selectedDate),

       SizedBox(height: 20),
      Text('Select Time', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
       SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true, physics:  NeverScrollableScrollPhysics(),
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2),
        itemCount: timeSlots.length,
        itemBuilder: (_, i) {
          final slot = timeSlots[i];
          final sel = state.selectedTimeSlot == slot;
          final unavail = i % 7 == 3;
          return GestureDetector(
            onTap: unavail ? null : () => context.read<AppBloc>().add(SelectTimeSlot(slot)),
            child: AnimatedContainer(
              duration:  Duration(milliseconds: 150),
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

       SizedBox(height: 20),
      Text('Number of Guests', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
       SizedBox(height: 12),
      Row(children: List.generate(8, (i) {
        final n = i + 1;
        final sel = state.selectedGuests == n;
        return Expanded(child: GestureDetector(
          onTap: () => context.read<AppBloc>().add(SelectGuests(n)),
          child: AnimatedContainer(
            duration:  Duration(milliseconds: 150),
            margin:  EdgeInsets.only(right: 6),
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

       SizedBox(height: 20),
      Text('Table Preference', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
       SizedBox(height: 12),
      ...tableTypes.map((t) {
        final sel = state.selectedTableType == t;
        return GestureDetector(
          onTap: () => context.read<AppBloc>().add(SelectTableType(t)),
          child: AnimatedContainer(
            duration:  Duration(milliseconds: 150),
            margin:  EdgeInsets.only(bottom: 8),
            padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
                color: sel ? AppTheme.primary.withOpacity(0.1) : AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? AppTheme.primary : AppTheme.border, width: sel ? 1.5 : 1)),
            child: Row(children: [
              Icon(Icons.table_restaurant_outlined,
                  color: sel ? AppTheme.primary : AppTheme.text3, size: 20),
               SizedBox(width: 12),
              Text(t, style: GoogleFonts.dmSans(fontSize: 14,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? AppTheme.primary : AppTheme.text1)),
               Spacer(),
              if (sel)  Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18),
            ]),
          ),
        );
      }),

       SizedBox(height: 24),
      PrimaryBtn(
        label: 'Continue',
        icon: Icons.arrow_forward_rounded,
        onPressed: state.selectedDate != null && state.selectedTimeSlot.isNotEmpty ? onNext : null,
      ),
    ]),
  );
}

// ── Custom luxury calendar (BLoC-driven, no CalendarDatePicker) ───────────────
class _LuxCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  const _LuxCalendar({required this.selectedDate});
  @override
  State<_LuxCalendar> createState() => _LuxCalendarState();
}

class _LuxCalendarState extends State<_LuxCalendar> {
  late DateTime _focusedMonth;
  final _today = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    // Open on the selected month, or today
    final sel = widget.selectedDate;
    _focusedMonth = sel != null
        ? DateTime(sel.year, sel.month)
        : DateTime(_today.year, _today.month);
  }

  void _prevMonth() {
    setState(() => _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month - 1));
  }

  void _nextMonth() {
    setState(() => _focusedMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1));
  }

  bool _isBefore(DateTime d) => d.isBefore(_today);
  bool _isAfter(DateTime d) =>
      d.isAfter(_today.add( Duration(days: 90)));
  bool _isDisabled(DateTime d) => _isBefore(d) || _isAfter(d);

  bool _isSelected(DateTime d) {
    final sel = widget.selectedDate;
    if (sel == null) return false;
    return d.year == sel.year && d.month == sel.month && d.day == sel.day;
  }

  bool _isToday(DateTime d) =>
      d.year == _today.year && d.month == _today.month && d.day == _today.day;

  @override
  void didUpdateWidget(_LuxCalendar old) {
    super.didUpdateWidget(old);
    // If the selected date is in a different month, follow it
    final sel = widget.selectedDate;
    if (sel != null) {
      final m = DateTime(sel.year, sel.month);
      if (m.year != _focusedMonth.year || m.month != _focusedMonth.month) {
        setState(() => _focusedMonth = m);
      }
    }
  }

  List<DateTime?> _buildCells() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
    DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    // weekday: Mon=1 … Sun=7 → offset Mon-aligned
    final startOffset = (firstDay.weekday - 1) % 7;
    final cells = <DateTime?>[];
    for (int i = 0; i < startOffset; i++) cells.add(null);
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCells();
    final canGoPrev = DateTime(_focusedMonth.year, _focusedMonth.month)
        .isAfter(DateTime(_today.year, _today.month - 1));
    final canGoNext = DateTime(_focusedMonth.year, _focusedMonth.month)
        .isBefore(DateTime(_today.year, _today.month + 3));

    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [

        // ── Month navigation ──────────────────────────────────
        Row(children: [
          // Prev
          GestureDetector(
            onTap: canGoPrev ? _prevMonth : null,
            child: Container(
              padding:  EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: canGoPrev ? AppTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.chevron_left_rounded,
                  color: canGoPrev ? AppTheme.text1 : AppTheme.text3,
                  size: 20),
            ),
          ),
           Spacer(),
          // Month + Year
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.text1),
          ),
           Spacer(),
          // Next
          GestureDetector(
            onTap: canGoNext ? _nextMonth : null,
            child: Container(
              padding:  EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: canGoNext ? AppTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.chevron_right_rounded,
                  color: canGoNext ? AppTheme.text1 : AppTheme.text3,
                  size: 20),
            ),
          ),
        ]),

         SizedBox(height: 14),

        // ── Weekday headers ───────────────────────────────────
        Row(
          children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
              .map((d) => Expanded(
            child: Center(
              child: Text(d,
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: d == 'Sa' || d == 'Su'
                          ? AppTheme.primary.withOpacity(0.7)
                          : AppTheme.text3)),
            ),
          ))
              .toList(),
        ),

         SizedBox(height: 8),

        // ── Day grid ──────────────────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics:  NeverScrollableScrollPhysics(),
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1.1,
              mainAxisSpacing: 4, crossAxisSpacing: 2),
          itemCount: cells.length,
          itemBuilder: (_, i) {
            final date = cells[i];
            if (date == null) return  SizedBox.shrink();

            final selected = _isSelected(date);
            final today    = _isToday(date);
            final disabled = _isDisabled(date);

            return GestureDetector(
              onTap: disabled
                  ? null
                  : () => context
                  .read<AppBloc>()
                  .add(SelectDate(date)),
              child: AnimatedContainer(
                duration:  Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary
                      : today
                      ? AppTheme.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: today && !selected
                      ? Border.all(
                      color: AppTheme.primary.withOpacity(0.5),
                      width: 1.5)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: selected || today
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: selected
                        ? AppTheme.white
                        : disabled
                        ? AppTheme.text3.withOpacity(0.4)
                        : today
                        ? AppTheme.primary
                        : AppTheme.text1,
                  ),
                ),
              ),
            );
          },
        ),

        // ── Selected date summary ─────────────────────────────
        if (widget.selectedDate != null) ...[
           SizedBox(height: 12),
          Container(
            padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppTheme.primary, size: 14),
                   SizedBox(width: 6),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(widget.selectedDate!),
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary),
                  ),
                ]),
          ),
        ],
      ]),
    );
  }
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
    padding:  EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your Details', style: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text1)),
       SizedBox(height: 4),
      Text('We\'ll use this to confirm your reservation.',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
       SizedBox(height: 24),

      _label('Full Name'),
       SizedBox(height: 6),
      TextField(controller: nameCtrl,
          onChanged: (v) => context.read<AppBloc>().add(SetGuestName(v)),
          style: GoogleFonts.dmSans(color: AppTheme.text1),
          decoration:  InputDecoration(
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: AppTheme.text3))),
       SizedBox(height: 16),

      _label('Special Requests (Optional)'),
       SizedBox(height: 6),
      TextField(controller: reqCtrl, maxLines: 3,
          onChanged: (v) => context.read<AppBloc>().add(SetSpecialRequest(v)),
          style: GoogleFonts.dmSans(color: AppTheme.text1),
          decoration:  InputDecoration(hintText: 'Allergies, celebrations, dietary needs...')),
       SizedBox(height: 24),

      // Policy note
      Container(padding:  EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.warning.withOpacity(0.3))),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 18),
             SizedBox(width: 10),
            Expanded(child: Text(
                'Cancellations must be made at least 24 hours in advance to avoid charges.',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.warning, height: 1.5))),
          ])),

       SizedBox(height: 24),
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
    padding:  EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Review Summary', style: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.text1)),
       SizedBox(height: 20),

      // Restaurant card
      Container(padding:  EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 70, height: 70,
                    child: NetImg(state.selectedRestaurant!.imageUrl))),
             SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(state.selectedRestaurant!.name, style: GoogleFonts.playfairDisplay(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
              Text(state.selectedRestaurant!.location, style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppTheme.text2)),
               SizedBox(height: 4),
              StarRating(state.selectedRestaurant!.rating, size: 12),
            ])),
          ])),

       SizedBox(height: 16),

      // Booking details
      Container(padding:  EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            _row(Icons.calendar_today_rounded, 'Date',
                DateFormat('EEEE, MMMM d, y').format(state.selectedDate!)),
             Divider(color: AppTheme.border, height: 20),
            _row(Icons.access_time_rounded, 'Time', state.selectedTimeSlot),
             Divider(color: AppTheme.border, height: 20),
            _row(Icons.people_rounded, 'Guests', '${state.selectedGuests} persons'),
             Divider(color: AppTheme.border, height: 20),
            _row(Icons.table_restaurant_outlined, 'Table', state.selectedTableType),
             Divider(color: AppTheme.border, height: 20),
            _row(Icons.person_outline_rounded, 'Name', nameCtrl.text.trim()),
            if (reqCtrl.text.trim().isNotEmpty) ...[
               Divider(color: AppTheme.border, height: 20),
              _row(Icons.notes_rounded, 'Requests', reqCtrl.text.trim()),
            ],
          ])),

       SizedBox(height: 16),

      // Price breakdown
      Container(padding:  EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            _row(Icons.receipt_outlined, 'Per person', '\$45.00'),
             Divider(color: AppTheme.border, height: 20),
            _row(Icons.people_rounded, '× ${state.selectedGuests} guests',
                '\$${(state.selectedGuests * 45).toStringAsFixed(2)}'),
             Divider(color: AppTheme.border, height: 20),
            Row(children: [
              Text('Total', style: GoogleFonts.dmSans(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.text1)),
               Spacer(),
              Text('\$${(state.selectedGuests * 45).toStringAsFixed(2)}',
                  style: GoogleFonts.dmSans(
                      fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary)),
            ]),
          ])),

       SizedBox(height: 24),
      PrimaryBtn(
        label: 'Confirm Reservation',
        isLoading: state.isSubmitting,
        onPressed: () => context.read<AppBloc>().add(SubmitBooking()),
      ),
    ]),
  );

  Widget _row(IconData icon, String label, String value) => Row(children: [
    Icon(icon, color: AppTheme.primary, size: 16),
     SizedBox(width: 10),
    Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
     Spacer(),
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
          padding:  EdgeInsets.all(24),
          child: Column(children: [
             Spacer(),
            // Success animation
            Container(width: 110, height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient:  LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [AppTheme.primary, AppTheme.primaryDk]),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 32, spreadRadius: 4)],
                ),
                child:  Icon(Icons.check_rounded, color: AppTheme.white, size: 56)),
             SizedBox(height: 28),
            Text('Table Reserved! 🎉', style: GoogleFonts.playfairDisplay(
                fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.text1)),
             SizedBox(height: 8),
            Text('Your reservation is confirmed. We look forward to welcoming you.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text2, height: 1.6)),
             SizedBox(height: 32),

            // E-Ticket
            Container(
              padding:  EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border)),
              child: Column(children: [
                Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(10),
                      child: SizedBox(width: 60, height: 60,
                          child: NetImg(b.restaurantImage))),
                   SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.restaurantName, style: GoogleFonts.dmSans(
                        fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.text1)),
                    Text(b.tableType, style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
                  ])),
                  Container(padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('CONFIRMED', style: GoogleFonts.dmSans(
                          fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.success))),
                ]),
                 SizedBox(height: 16),
                 Divider(color: AppTheme.border),
                 SizedBox(height: 12),
                // Dashed separator
                Row(children: [
                  Text('BOOKING #${b.id.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3,
                          letterSpacing: 1)),
                   Spacer(),
                  Text(DateFormat('MMM d, y').format(b.bookedAt),
                      style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3)),
                ]),
                 SizedBox(height: 12),
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
             Spacer(),
            PrimaryBtn(
              label: 'Back to Home',
              onPressed: () {
                context.read<AppBloc>().add( ChangeTab(0));
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
             SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.read<AppBloc>().add( ChangeTab(2));
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              style: OutlinedButton.styleFrom(
                  minimumSize:  Size(double.infinity, 50),
                  foregroundColor: AppTheme.primary,
                  side:  BorderSide(color: AppTheme.primary),
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
     SizedBox(height: 4),
    Text(value, style: GoogleFonts.dmSans(
        fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text1)),
    Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text3)),
  ]);

  Widget _vline() => Container(width: 1, height: 40, color: AppTheme.border);
}