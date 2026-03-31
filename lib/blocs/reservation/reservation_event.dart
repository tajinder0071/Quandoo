part of 'reservation_bloc.dart';

abstract class ReservationEvent extends Equatable {
  const ReservationEvent();
  @override
  List<Object?> get props => [];
}

class SelectTable extends ReservationEvent {
  final RestaurantTable table;
  const SelectTable(this.table);
  @override
  List<Object?> get props => [table];
}

class SelectDate extends ReservationEvent {
  final DateTime date;
  const SelectDate(this.date);
  @override
  List<Object?> get props => [date];
}

class SelectTimeSlot extends ReservationEvent {
  final String timeSlot;
  const SelectTimeSlot(this.timeSlot);
  @override
  List<Object?> get props => [timeSlot];
}

class SelectGuestCount extends ReservationEvent {
  final int count;
  const SelectGuestCount(this.count);
  @override
  List<Object?> get props => [count];
}

class SelectOccasion extends ReservationEvent {
  final String occasion;
  const SelectOccasion(this.occasion);
  @override
  List<Object?> get props => [occasion];
}

class UpdateGuestDetails extends ReservationEvent {
  final String name;
  final String email;
  final String phone;
  final String? specialRequests;
  const UpdateGuestDetails({
    required this.name,
    required this.email,
    required this.phone,
    this.specialRequests,
  });
  @override
  List<Object?> get props => [name, email, phone, specialRequests];
}

class SubmitReservation extends ReservationEvent {}

class CancelReservation extends ReservationEvent {
  final String reservationId;
  const CancelReservation(this.reservationId);
  @override
  List<Object?> get props => [reservationId];
}

class ResetReservation extends ReservationEvent {}

class LoadReservations extends ReservationEvent {}

class ProceedToGuestDetails extends ReservationEvent {}
