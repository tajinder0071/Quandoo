import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../blocs/reservation/reservation_bloc.dart';
import '../models/restaurant_table.dart';
import '../theme/app_theme.dart';
import '../widgets/luxury_widgets.dart';
import 'confirmation_screen.dart';

class ReservationFlowScreen extends StatelessWidget {
  const ReservationFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReservationBloc, ReservationState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ReservationBloc>(),
                child: const ConfirmationScreen(),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.darkSurface,
          appBar: AppBar(
            backgroundColor: AppTheme.cream,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: AppTheme.gold,
              ),
              onPressed: () {
                if (state.currentStep == ReservationStep.selectTable) {
                  Navigator.pop(context);
                } else if (state.currentStep ==
                    ReservationStep.selectDateTime) {
                  context.read<ReservationBloc>().add(ResetReservation());
                } else if (state.currentStep == ReservationStep.guestDetails) {
                  context.read<ReservationBloc>().add(
                    SelectTable(state.selectedTable!),
                  );
                }
              },
            ),
            title: Text(
              'MAISON DORÉE',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                letterSpacing: 4,
                color: AppTheme.gold,
                fontWeight: FontWeight.w400,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: StepIndicator(
                  currentStep: state.currentStep.index,
                  totalSteps: 3,
                  labels: const ['Table', 'Date & Time', 'Details'],
                ),
              ),
            ),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.05, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _buildStep(context, state),
          ),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, ReservationState state) {
    switch (state.currentStep) {
      case ReservationStep.selectTable:
        return _TableSelectionStep(key: const ValueKey('table'));
      case ReservationStep.selectDateTime:
        return _DateTimeStep(key: const ValueKey('datetime'));
      case ReservationStep.guestDetails:
        return _GuestDetailsStep(key: const ValueKey('details'));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step 1: Table Selection ──────────────────────────────────────────────────
class _TableSelectionStep extends StatelessWidget {
  const _TableSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 20,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Step 1 of 3'),
              const SizedBox(height: 8),
              Text(
                'Choose Your Table',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Select the perfect setting for your evening.',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.tables.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final table = state.tables[i];
                  final isSelected = state.selectedTable?.id == table.id;
                  return _TableCard(
                    table: table,
                    isSelected: isSelected,
                    onTap: () =>
                        context.read<ReservationBloc>().add(SelectTable(table)),
                  );
                },
              ),
              if (state.selectedTable != null) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: LuxuryButton(
                    label: 'Continue',
                    onPressed: () {
                      context.read<ReservationBloc>().add(
                        SelectDate(DateTime.now().add(const Duration(days: 1))),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TableCard extends StatelessWidget {
  final RestaurantTable table;
  final bool isSelected;
  final VoidCallback onTap;

  const _TableCard({
    required this.table,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _locationIcon {
    switch (table.location) {
      case TableLocation.window:
        return Icons.window;
      case TableLocation.garden:
        return Icons.park;
      case TableLocation.private:
        return Icons.lock;
      case TableLocation.bar:
        return Icons.restaurant_menu;
      case TableLocation.main:
        return Icons.dining;
    }
  }

  Widget _buildImage() {
    return Image.network(
      table.imagePath,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: AppTheme.darkSurface,
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.gold,
                  ),
                ),
              ),
            ),
      errorBuilder: (_, __, ___) => Container(
        color: AppTheme.darkSurface,
        child: Icon(_locationIcon, color: AppTheme.gold, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.goldDark.withOpacity(0.12)
              : AppTheme.darkCard,
          border: Border.all(
            color: isSelected ? AppTheme.gold : AppTheme.darkBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: image
                  SizedBox(
                    width: 160,
                    height: 140,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(),
                        if (isSelected)
                          Container(color: AppTheme.gold.withOpacity(0.15)),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            color: AppTheme.black.withOpacity(0.75),
                            child: Text(
                              table.locationLabel.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.gold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right: info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: _cardInfo(context),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top: image
                  AspectRatio(
                    aspectRatio: 16 / 7,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildImage(),
                        if (isSelected)
                          Container(color: AppTheme.gold.withOpacity(0.12)),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            color: AppTheme.darkCard.withOpacity(0.75),
                            child: Text(
                              table.locationLabel.toUpperCase(),
                              style: GoogleFonts.montserrat(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.gold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _cardInfo(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _cardInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              table.name,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppTheme.gold : AppTheme.textPrimary,
              ),
            ),
            Row(
              children: [
                Text(
                  '€${table.pricePerPerson.toInt()}/person',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.gold,
                    size: 18,
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          table.description,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.people_outline, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              '${table.minGuests}–${table.maxGuests} guests',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Step 2: Date & Time ──────────────────────────────────────────────────────
class _DateTimeStep extends StatelessWidget {
  const _DateTimeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        // ── Guard: no table selected ──────────────────────────
        if (state.selectedTable == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.darkBorder,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.table_restaurant_outlined,
                      color: AppTheme.gold,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Table Selected',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please go back and choose a table\nbefore selecting a date and time.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),
                  LuxuryButton(
                    label: 'Back to Tables',
                    outlined: true,
                    onPressed: () =>
                        context.read<ReservationBloc>().add(ResetReservation()),
                    width: 200,
                  ),
                ],
              ),
            ),
          );
        }

        final table = state.selectedTable!;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 20,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Step 2 of 3'),
              const SizedBox(height: 8),
              Text(
                'Select Date & Time',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Reserving: ${table.name}',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(height: 32),

              // Guest count selector
              _GuestCountSelector(table: table),
              const SizedBox(height: 28),

              // Occasion picker
              const SectionLabel('Occasion'),
              const SizedBox(height: 12),
              _OccasionSelector(),
              const SizedBox(height: 28),

              // Calendar
              const SectionLabel('Select Date'),
              const SizedBox(height: 12),
              _LuxuryCalendar(),
              const SizedBox(height: 28),

              // Time slots — placeholder until date is chosen
              if (state.selectedDate == null) ...[
                _NoDataPlaceholder(
                  icon: Icons.access_time_outlined,
                  title: 'No Date Selected',
                  subtitle: 'Pick a date above to see available time slots.',
                ),
                const SizedBox(height: 32),
              ] else ...[
                const SectionLabel('Available Times'),
                const SizedBox(height: 12),
                _TimeSlotGrid(),
                const SizedBox(height: 32),
              ],

              // Continue button — placeholder until time slot is also chosen
              if (state.selectedDate != null &&
                  !state.canProceedToGuestDetails) ...[
                _NoDataPlaceholder(
                  icon: Icons.event_seat_outlined,
                  title: 'No Time Slot Selected',
                  subtitle: 'Choose a time slot above to continue.',
                ),
                const SizedBox(height: 16),
              ],

              if (state.canProceedToGuestDetails)
                SizedBox(
                  width: double.infinity,
                  child: LuxuryButton(
                    label: 'Continue to Details',
                    onPressed: () {
                      context.read<ReservationBloc>().add(
                        UpdateGuestDetails(name: '', email: '', phone: ''),
                      );
                      context.read<ReservationBloc>().add(
                        ProceedToGuestDetails(),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Dummy event to proceed
class _ProceedToGuestDetails extends ReservationEvent {}

// ─── Guest Count Selector ─────────────────────────────────────────────────────
class _GuestCountSelector extends StatelessWidget {
  final RestaurantTable table;

  const _GuestCountSelector({required this.table});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Number of Guests'),
            const SizedBox(height: 12),
            Row(
              children: List.generate(table.maxGuests - table.minGuests + 1, (
                i,
              ) {
                final count = table.minGuests + i;
                final isSelected = state.guestCount == count;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => context.read<ReservationBloc>().add(
                      SelectGuestCount(count),
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.gold : AppTheme.black,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.gold
                              : AppTheme.darkBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.black
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

// ─── Occasion Selector ────────────────────────────────────────────────────────
class _OccasionSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: occasions.map((occ) {
            final isSelected = state.selectedOccasion == occ;
            return GestureDetector(
              onTap: () =>
                  context.read<ReservationBloc>().add(SelectOccasion(occ)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.gold : AppTheme.darkSurface,
                  border: Border.all(
                    color: isSelected ? AppTheme.gold : AppTheme.darkBorder,
                  ),
                ),
                child: Text(
                  occ,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.black : AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Luxury Calendar ──────────────────────────────────────────────────────────
class _LuxuryCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.darkSurface,
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay:
                state.selectedDate ??
                DateTime.now().add(const Duration(days: 1)),
            selectedDayPredicate: (day) =>
                state.selectedDate != null &&
                isSameDay(day, state.selectedDate!),
            onDaySelected: (selected, _) {
              context.read<ReservationBloc>().add(SelectDate(selected));
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: GoogleFonts.montserrat(
                color: AppTheme.textPrimary,
                fontSize: 13,
              ),
              weekendTextStyle: GoogleFonts.montserrat(
                color: AppTheme.gold.withOpacity(0.8),
                fontSize: 13,
              ),
              todayDecoration: BoxDecoration(
                border: Border.all(color: AppTheme.gold),
                color: Colors.transparent,
              ),
              todayTextStyle: GoogleFonts.montserrat(
                color: AppTheme.gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppTheme.gold,
                shape: BoxShape.rectangle,
              ),
              selectedTextStyle: GoogleFonts.montserrat(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              disabledTextStyle: GoogleFonts.montserrat(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              leftChevronIcon: const Icon(
                Icons.chevron_left,
                color: AppTheme.gold,
              ),
              rightChevronIcon: const Icon(
                Icons.chevron_right,
                color: AppTheme.gold,
              ),
              headerPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: GoogleFonts.montserrat(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              weekendStyle: GoogleFonts.montserrat(
                color: AppTheme.gold.withOpacity(0.6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Time Slot Grid ───────────────────────────────────────────────────────────
class _TimeSlotGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (_, i) {
            final slot = timeSlots[i];
            final isSelected = state.selectedTimeSlot == slot;
            // Simulate some slots being unavailable
            final isUnavailable = i % 7 == 3;
            return GestureDetector(
              onTap: isUnavailable
                  ? null
                  : () {
                      context.read<ReservationBloc>().add(SelectTimeSlot(slot));
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isUnavailable
                      ? AppTheme.cream.withOpacity(0.4)
                      : isSelected
                      ? AppTheme.gold
                      : AppTheme.darkSurface,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.gold
                        : isUnavailable
                        ? AppTheme.textPrimary.withOpacity(0.3)
                        : AppTheme.textPrimary,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  slot,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUnavailable
                        ? AppTheme.textPrimary
                        : isSelected
                        ? AppTheme.black
                        : AppTheme.textPrimary,
                    decoration: isUnavailable
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Step 3: Guest Details ────────────────────────────────────────────────────
class _GuestDetailsStep extends StatefulWidget {
  const _GuestDetailsStep({super.key});

  @override
  State<_GuestDetailsStep> createState() => _GuestDetailsStepState();
}

class _GuestDetailsStepState extends State<_GuestDetailsStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _specialCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _specialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 80 : 20,
            vertical: 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Step 3 of 3'),
                const SizedBox(height: 8),
                Text(
                  'Your Details',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete your reservation for ${state.selectedTable?.name}',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Summary card
                _BookingSummaryCard(state: state),
                const SizedBox(height: 28),

                // Form fields
                LuxuryTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameCtrl,
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: LuxuryTextField(
                        label: 'Email Address',
                        hint: 'your@email.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline,
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Valid email required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LuxuryTextField(
                        label: 'Phone Number',
                        hint: '+1 234 567 8900',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Phone is required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LuxuryTextField(
                  label: 'Special Requests (Optional)',
                  hint:
                      'Allergies, dietary requirements, special arrangements...',
                  controller: _specialCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Terms note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.textPrimary),
                    color: AppTheme.darkSurface,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'A credit card may be required to secure your reservation. Cancellations must be made 24 hours in advance.',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: LuxuryButton(
                    label: 'Confirm Reservation',
                    isLoading: state.isSubmitting,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<ReservationBloc>().add(
                          UpdateGuestDetails(
                            name: _nameCtrl.text.trim(),
                            email: _emailCtrl.text.trim(),
                            phone: _phoneCtrl.text.trim(),
                            specialRequests: _specialCtrl.text.trim(),
                          ),
                        );
                        context.read<ReservationBloc>().add(
                          SubmitReservation(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookingSummaryCard extends StatelessWidget {
  final ReservationState state;

  const _BookingSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE, MMMM d, y');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDF8EE), Color(0xFFF5EDD8)],
        ),
        border: Border.all(color: AppTheme.goldDark.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.gold,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'BOOKING SUMMARY',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.textPrimary),
          const SizedBox(height: 12),
          _SummaryRow('Table', state.selectedTable?.name ?? '-'),
          _SummaryRow('Location', state.selectedTable?.locationLabel ?? '-'),
          _SummaryRow(
            'Date',
            state.selectedDate != null ? df.format(state.selectedDate!) : '-',
          ),
          _SummaryRow('Time', state.selectedTimeSlot ?? '-'),
          _SummaryRow('Guests', '${state.guestCount} persons'),
          if (state.selectedOccasion != null &&
              state.selectedOccasion != 'None')
            _SummaryRow('Occasion', state.selectedOccasion!),
          const SizedBox(height: 8),
          const Divider(color: AppTheme.textPrimary),
          const SizedBox(height: 8),
          _SummaryRow(
            'Estimated Total',
            '€${((state.selectedTable?.pricePerPerson ?? 0) * state.guestCount).toInt()}',
            isHighlight: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _SummaryRow(this.label, this.value, {this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppTheme.gold : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── No Data Placeholder ──────────────────────────────────────────────────────
class _NoDataPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _NoDataPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border.all(color: AppTheme.textPrimary, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.textPrimary, width: 1.5),
            ),
            child: Icon(icon, color: AppTheme.gold, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 24, height: 1, color: AppTheme.textPrimary),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_downward,
                  size: 12,
                  color: AppTheme.goldDark,
                ),
              ),
              Container(width: 24, height: 1, color: AppTheme.textPrimary),
            ],
          ),
        ],
      ),
    );
  }
}
