import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../models/reservation.dart';
import '../../models/restaurant_table.dart';

part 'reservation_event.dart';
part 'reservation_state.dart';

const _uuid = Uuid();

const List<String> timeSlots = [
  '12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM',
  '2:00 PM', '2:30 PM', '6:00 PM', '6:30 PM',
  '7:00 PM', '7:30 PM', '8:00 PM', '8:30 PM',
  '9:00 PM', '9:30 PM',
];

const List<String> occasions = [
  'None', 'Birthday', 'Anniversary', 'Proposal',
  'Business Dinner', 'Date Night', 'Family Gathering', 'Celebration',
];

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  ReservationBloc() : super(ReservationState(tables: sampleTables)) {
    on<SelectTable>(_onSelectTable);
    on<SelectDate>(_onSelectDate);
    on<SelectTimeSlot>(_onSelectTimeSlot);
    on<SelectGuestCount>(_onSelectGuestCount);
    on<SelectOccasion>(_onSelectOccasion);
    on<UpdateGuestDetails>(_onUpdateGuestDetails);
    on<SubmitReservation>(_onSubmitReservation);
    on<CancelReservation>(_onCancelReservation);
    on<ResetReservation>(_onResetReservation);
    on<LoadReservations>(_onLoadReservations);
    on<ProceedToGuestDetails>(_onProceedToGuestDetails);
  }

  void _onSelectTable(SelectTable event, Emitter<ReservationState> emit) {
    emit(state.copyWith(
      selectedTable: event.table,
      guestCount: event.table.minGuests,
      currentStep: ReservationStep.selectDateTime,
      clearSelectedDate: true,
      clearSelectedTimeSlot: true,
    ));
  }

  void _onSelectDate(SelectDate event, Emitter<ReservationState> emit) {
    emit(state.copyWith(
      selectedDate: event.date,
      clearSelectedTimeSlot: true,
    ));
  }

  void _onSelectTimeSlot(SelectTimeSlot event, Emitter<ReservationState> emit) {
    emit(state.copyWith(selectedTimeSlot: event.timeSlot));
  }

  void _onSelectGuestCount(SelectGuestCount event, Emitter<ReservationState> emit) {
    emit(state.copyWith(guestCount: event.count));
  }

  void _onSelectOccasion(SelectOccasion event, Emitter<ReservationState> emit) {
    emit(state.copyWith(selectedOccasion: event.occasion));
  }

  void _onUpdateGuestDetails(UpdateGuestDetails event, Emitter<ReservationState> emit) {
    emit(state.copyWith(
      guestName: event.name,
      guestEmail: event.email,
      guestPhone: event.phone,
      specialRequests: event.specialRequests ?? '',
    ));
  }

  Future<void> _onSubmitReservation(SubmitReservation event, Emitter<ReservationState> emit) async {
    if (state.selectedTable == null || state.selectedDate == null ||
        state.selectedTimeSlot == null) return;

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final reservation = Reservation(
      id: _uuid.v4(),
      tableId: state.selectedTable!.id,
      tableName: state.selectedTable!.name,
      date: state.selectedDate!,
      timeSlot: state.selectedTimeSlot!,
      guests: state.guestCount,
      guestName: state.guestName,
      guestEmail: state.guestEmail,
      guestPhone: state.guestPhone,
      specialRequests: state.specialRequests.isNotEmpty ? state.specialRequests : null,
      occasion: state.selectedOccasion ?? 'None',
      status: ReservationStatus.confirmed,
    );

    emit(state.copyWith(
      reservations: [...state.reservations, reservation],
      isSubmitting: false,
      isSuccess: true,
      currentStep: ReservationStep.confirmation,
    ));
  }

  void _onCancelReservation(CancelReservation event, Emitter<ReservationState> emit) {
    final updated = state.reservations.map((r) {
      if (r.id == event.reservationId) {
        return r.copyWith(status: ReservationStatus.cancelled);
      }
      return r;
    }).toList();
    emit(state.copyWith(reservations: updated));
  }

  void _onResetReservation(ResetReservation event, Emitter<ReservationState> emit) {
    emit(ReservationState(
      tables: sampleTables,
      reservations: state.reservations,
    ));
  }

  void _onLoadReservations(LoadReservations event, Emitter<ReservationState> emit) {
    // In a real app, load from database
    emit(state.copyWith());
  }

  void _onProceedToGuestDetails(ProceedToGuestDetails event, Emitter<ReservationState> emit) {
    emit(state.copyWith(currentStep: ReservationStep.guestDetails));
  }
}
