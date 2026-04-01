import 'package:equatable/equatable.dart';

enum BookingStatus { active, completed, cancelled }

class Booking extends Equatable {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final DateTime date;
  final String timeSlot;
  final int guests;
  final String tableType;
  final BookingStatus status;
  final String guestName;
  final double totalAmount;
  final String? specialRequest;
  final DateTime bookedAt;

  const Booking({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImage,
    required this.date,
    required this.timeSlot,
    required this.guests,
    required this.tableType,
    required this.status,
    required this.guestName,
    required this.totalAmount,
    this.specialRequest,
    required this.bookedAt,
  });

  Booking copyWith({BookingStatus? status}) => Booking(
    id: id, restaurantId: restaurantId, restaurantName: restaurantName,
    restaurantImage: restaurantImage, date: date, timeSlot: timeSlot,
    guests: guests, tableType: tableType,
    status: status ?? this.status,
    guestName: guestName, totalAmount: totalAmount,
    specialRequest: specialRequest, bookedAt: bookedAt,
  );

  @override
  List<Object?> get props => [id, status];
}

const List<String> timeSlots = [
  '12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM', '2:00 PM',
  '6:00 PM', '6:30 PM', '7:00 PM', '7:30 PM', '8:00 PM',
  '8:30 PM', '9:00 PM', '9:30 PM', '10:00 PM',
];

const List<String> tableTypes = [
  'Standard Table', 'Window Seat', 'Private Booth',
  'Garden Terrace', 'Chef\'s Counter', 'Private Room',
];
