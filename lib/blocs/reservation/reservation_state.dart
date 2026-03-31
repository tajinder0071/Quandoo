part of 'reservation_bloc.dart';

enum ReservationStep { selectTable, selectDateTime, guestDetails, confirmation }

class ReservationState extends Equatable {
  final List<RestaurantTable> tables;
  final RestaurantTable? selectedTable;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final int guestCount;
  final String? selectedOccasion;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String specialRequests;
  final List<Reservation> reservations;
  final ReservationStep currentStep;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const ReservationState({
    this.tables = const [],
    this.selectedTable,
    this.selectedDate,
    this.selectedTimeSlot,
    this.guestCount = 2,
    this.selectedOccasion,
    this.guestName = '',
    this.guestEmail = '',
    this.guestPhone = '',
    this.specialRequests = '',
    this.reservations = const [],
    this.currentStep = ReservationStep.selectTable,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  ReservationState copyWith({
    List<RestaurantTable>? tables,
    RestaurantTable? selectedTable,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    int? guestCount,
    String? selectedOccasion,
    String? guestName,
    String? guestEmail,
    String? guestPhone,
    String? specialRequests,
    List<Reservation>? reservations,
    ReservationStep? currentStep,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    bool clearSelectedTable = false,
    bool clearSelectedDate = false,
    bool clearSelectedTimeSlot = false,
    bool clearErrorMessage = false,
    bool clearOccasion = false,
  }) {
    return ReservationState(
      tables: tables ?? this.tables,
      selectedTable: clearSelectedTable ? null : (selectedTable ?? this.selectedTable),
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedTimeSlot: clearSelectedTimeSlot ? null : (selectedTimeSlot ?? this.selectedTimeSlot),
      guestCount: guestCount ?? this.guestCount,
      selectedOccasion: clearOccasion ? null : (selectedOccasion ?? this.selectedOccasion),
      guestName: guestName ?? this.guestName,
      guestEmail: guestEmail ?? this.guestEmail,
      guestPhone: guestPhone ?? this.guestPhone,
      specialRequests: specialRequests ?? this.specialRequests,
      reservations: reservations ?? this.reservations,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  bool get canProceedToDateTime =>
      selectedTable != null;

  bool get canProceedToGuestDetails =>
      selectedDate != null && selectedTimeSlot != null;

  bool get canSubmit =>
      guestName.isNotEmpty && guestEmail.isNotEmpty && guestPhone.isNotEmpty;

  @override
  List<Object?> get props => [
    tables, selectedTable, selectedDate, selectedTimeSlot, guestCount,
    selectedOccasion, guestName, guestEmail, guestPhone, specialRequests,
    reservations, currentStep, isSubmitting, isSuccess, errorMessage,
  ];
}
