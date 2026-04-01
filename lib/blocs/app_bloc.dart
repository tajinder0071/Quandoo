import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../models/restaurant.dart';
import '../models/booking.dart';

part 'app_event.dart';
part 'app_state.dart';

const _uuid = Uuid();

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    on<ToggleFavorite>(_onToggleFavorite);
    on<SelectRestaurant>(_onSelectRestaurant);
    on<SelectDate>(_onSelectDate);
    on<SelectTimeSlot>(_onSelectTimeSlot);
    on<SelectGuests>(_onSelectGuests);
    on<SelectTableType>(_onSelectTableType);
    on<SetGuestName>(_onSetGuestName);
    on<SetSpecialRequest>(_onSetSpecialRequest);
    on<SubmitBooking>(_onSubmitBooking);
    on<CancelBooking>(_onCancelBooking);
    on<SetSearchQuery>(_onSetSearchQuery);
    on<SelectCuisine>(_onSelectCuisine);
    on<ChangeTab>(_onChangeTab);
    on<ResetBooking>(_onResetBooking);
  }

  void _onToggleFavorite(ToggleFavorite e, Emitter<AppState> emit) {
    final updated = state.restaurants.map((r) =>
      r.id == e.restaurantId ? r.copyWith(isFavorite: !r.isFavorite) : r
    ).toList();
    emit(state.copyWith(restaurants: updated));
  }

  void _onSelectRestaurant(SelectRestaurant e, Emitter<AppState> emit) {
    emit(state.copyWith(selectedRestaurant: e.restaurant));
  }

  void _onSelectDate(SelectDate e, Emitter<AppState> emit) {
    emit(state.copyWith(selectedDate: e.date, selectedTimeSlot: ''));
  }

  void _onSelectTimeSlot(SelectTimeSlot e, Emitter<AppState> emit) {
    emit(state.copyWith(selectedTimeSlot: e.slot));
  }

  void _onSelectGuests(SelectGuests e, Emitter<AppState> emit) {
    emit(state.copyWith(selectedGuests: e.count));
  }

  void _onSelectTableType(SelectTableType e, Emitter<AppState> emit) {
    emit(state.copyWith(selectedTableType: e.type));
  }

  void _onSetGuestName(SetGuestName e, Emitter<AppState> emit) {
    emit(state.copyWith(guestName: e.name));
  }

  void _onSetSpecialRequest(SetSpecialRequest e, Emitter<AppState> emit) {
    emit(state.copyWith(specialRequest: e.request));
  }

  Future<void> _onSubmitBooking(SubmitBooking e, Emitter<AppState> emit) async {
    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(seconds: 2));
    final booking = Booking(
      id: _uuid.v4(),
      restaurantId: state.selectedRestaurant!.id,
      restaurantName: state.selectedRestaurant!.name,
      restaurantImage: state.selectedRestaurant!.imageUrl,
      date: state.selectedDate!,
      timeSlot: state.selectedTimeSlot,
      guests: state.selectedGuests,
      tableType: state.selectedTableType,
      status: BookingStatus.active,
      guestName: state.guestName,
      totalAmount: state.selectedGuests * 45.0,
      specialRequest: state.specialRequest,
      bookedAt: DateTime.now(),
    );
    emit(state.copyWith(
      bookings: [...state.bookings, booking],
      isSubmitting: false,
      lastBooking: booking,
    ));
  }

  void _onCancelBooking(CancelBooking e, Emitter<AppState> emit) {
    final updated = state.bookings.map((b) =>
      b.id == e.bookingId ? b.copyWith(status: BookingStatus.cancelled) : b
    ).toList();
    emit(state.copyWith(bookings: updated));
  }

  void _onSetSearchQuery(SetSearchQuery e, Emitter<AppState> emit) {
    emit(state.copyWith(searchQuery: e.query));
  }

  void _onSelectCuisine(SelectCuisine e, Emitter<AppState> emit) {
    emit(state.copyWith(selectedCuisine: e.cuisine));
  }

  void _onChangeTab(ChangeTab e, Emitter<AppState> emit) {
    emit(state.copyWith(currentTab: e.tab));
  }

  void _onResetBooking(ResetBooking e, Emitter<AppState> emit) {
    emit(state.copyWith(
      selectedDate: null,
      selectedTimeSlot: '',
      selectedGuests: 2,
      selectedTableType: tableTypes.first,
      guestName: '',
      specialRequest: '',
    ));
  }
}
