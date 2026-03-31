import 'package:equatable/equatable.dart';

enum ReservationStatus { pending, confirmed, cancelled }

class Reservation extends Equatable {
  final String id;
  final String tableId;
  final String tableName;
  final DateTime date;
  final String timeSlot;
  final int guests;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String? specialRequests;
  final ReservationStatus status;
  final String occasion;

  const Reservation({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.date,
    required this.timeSlot,
    required this.guests,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    this.specialRequests,
    this.status = ReservationStatus.confirmed,
    this.occasion = 'None',
  });

  Reservation copyWith({
    String? id,
    String? tableId,
    String? tableName,
    DateTime? date,
    String? timeSlot,
    int? guests,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? specialRequests,
    ReservationStatus? status,
    String? occasion,
  }) {
    return Reservation(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      guests: guests ?? this.guests,
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      specialRequests: specialRequests ?? this.specialRequests,
      status: status ?? this.status,
      occasion: occasion ?? this.occasion,
    );
  }

  @override
  List<Object?> get props => [
        id, tableId, tableName, date, timeSlot, guests,
        guestName, guestEmail, guestPhone, specialRequests, status, occasion
      ];
}
