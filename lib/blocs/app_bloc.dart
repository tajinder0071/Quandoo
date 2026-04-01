import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/restaurant.dart';
import '../models/booking.dart';
import '../models/user.dart';

part 'app_event.dart';
part 'app_state.dart';

const _uuid = Uuid();

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState.initial()) {
    // Auth
    on<LoginUser>(_onLoginUser);
    on<RegisterUser>(_onRegisterUser);
    on<LogoutUser>(_onLogoutUser);
    on<RestoreSession>(_onRestoreSession);
    on<LoadUserData>(_onLoadUserData);
    // Restaurants
    on<ToggleFavorite>(_onToggleFavorite);
    on<SelectRestaurant>(_onSelectRestaurant);
    // Booking form
    on<SelectDate>(_onSelectDate);
    on<SelectTimeSlot>(_onSelectTimeSlot);
    on<SelectGuests>(_onSelectGuests);
    on<SelectTableType>(_onSelectTableType);
    on<SetGuestName>(_onSetGuestName);
    on<SetSpecialRequest>(_onSetSpecialRequest);
    on<SubmitBooking>(_onSubmitBooking);
    on<CancelBooking>(_onCancelBooking);
    on<ResetBooking>(_onResetBooking);
    // UI
    on<SetSearchQuery>(_onSetSearchQuery);
    on<SelectCuisine>(_onSelectCuisine);
    on<ChangeTab>(_onChangeTab);
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<void> _onRestoreSession(RestoreSession e, Emitter<AppState> emit) async {
    emit(state.copyWith(authStatus: AuthStatus.loading));
    try {
      final user = await DatabaseHelper.getActiveSession();
      if (user != null) {
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          currentUser: user,
          authError: '',
        ));
        add(LoadUserData(user.id!));
      } else {
        emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
      }
    } catch (_) {
      emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginUser(LoginUser e, Emitter<AppState> emit) async {
    emit(state.copyWith(authStatus: AuthStatus.loading, authError: ''));
    try {
      final user = await DatabaseHelper.login(
          email: e.email, password: e.password);
      if (user == null) {
        emit(state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          authError: 'Invalid email or password.',
        ));
      } else {
        await DatabaseHelper.saveSession(user.id!);
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          currentUser: user,
          authError: '',
        ));
        add(LoadUserData(user.id!));
      }
    } catch (_) {
      emit(state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        authError: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onRegisterUser(RegisterUser e, Emitter<AppState> emit) async {
    emit(state.copyWith(authStatus: AuthStatus.loading, authError: ''));
    try {
      final user = await DatabaseHelper.register(
          name: e.name, email: e.email, password: e.password);
      if (user == null) {
        emit(state.copyWith(
          authStatus: AuthStatus.unauthenticated,
          authError: 'An account with this email already exists.',
        ));
      } else {
        await DatabaseHelper.saveSession(user.id!);
        emit(state.copyWith(
          authStatus: AuthStatus.authenticated,
          currentUser: user,
          authError: '',
          bookings: [],
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        authError: 'Registration failed. Please try again.',
      ));
    }
  }

  Future<void> _onLogoutUser(LogoutUser e, Emitter<AppState> emit) async {
    await DatabaseHelper.clearSession();
    emit(AppState.initial().copyWith(
      authStatus: AuthStatus.unauthenticated,
      restaurants: _resetFavourites(state.restaurants),
    ));
  }

  // ── Load user data from DB ─────────────────────────────────────────────────

  Future<void> _onLoadUserData(LoadUserData e, Emitter<AppState> emit) async {
    emit(state.copyWith(isLoadingData: true));
    try {
      // Load bookings + favourites in parallel
      final results = await Future.wait([
        DatabaseHelper.getBookingsForUser(e.userId),
        DatabaseHelper.getFavouriteIds(e.userId),
      ]);

      final bookings   = results[0] as List<Booking>;
      final favIds     = results[1] as Set<String>;

      // Apply favourite flags to restaurant list
      final updated = state.restaurants.map((r) =>
          r.copyWith(isFavorite: favIds.contains(r.id))).toList();

      emit(state.copyWith(
        bookings: bookings,
        restaurants: updated,
        isLoadingData: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingData: false));
    }
  }

  // ── Favourites ─────────────────────────────────────────────────────────────

  Future<void> _onToggleFavorite(ToggleFavorite e, Emitter<AppState> emit) async {
    final restaurant = state.restaurants.firstWhere((r) => r.id == e.restaurantId);
    final nowFav     = !restaurant.isFavorite;

    // Optimistic UI update
    final updated = state.restaurants.map((r) =>
    r.id == e.restaurantId ? r.copyWith(isFavorite: nowFav) : r
    ).toList();
    emit(state.copyWith(restaurants: updated));

    // Persist to DB (if user is logged in)
    if (state.currentUser?.id != null) {
      if (nowFav) {
        await DatabaseHelper.addFavourite(state.currentUser!.id!, e.restaurantId);
      } else {
        await DatabaseHelper.removeFavourite(state.currentUser!.id!, e.restaurantId);
      }
    }
  }

  // ── Booking submission ─────────────────────────────────────────────────────

  Future<void> _onSubmitBooking(SubmitBooking e, Emitter<AppState> emit) async {
    if (state.selectedRestaurant == null ||
        state.selectedDate == null ||
        state.selectedTimeSlot.isEmpty) return;

    emit(state.copyWith(isSubmitting: true));
    await Future.delayed(const Duration(seconds: 2));

    final booking = Booking(
      id              : _uuid.v4(),
      restaurantId    : state.selectedRestaurant!.id,
      restaurantName  : state.selectedRestaurant!.name,
      restaurantImage : state.selectedRestaurant!.imageUrl,
      date            : state.selectedDate!,
      timeSlot        : state.selectedTimeSlot,
      guests          : state.selectedGuests,
      tableType       : state.selectedTableType,
      status          : BookingStatus.active,
      guestName       : state.guestName,
      totalAmount     : state.selectedGuests * 45.0,
      specialRequest  : state.specialRequest.isNotEmpty
          ? state.specialRequest : null,
      bookedAt        : DateTime.now(),
    );

    // Persist to DB
    if (state.currentUser?.id != null) {
      await DatabaseHelper.insertBooking(booking, state.currentUser!.id!);
    }

    emit(state.copyWith(
      bookings    : [...state.bookings, booking],
      isSubmitting: false,
      lastBooking : booking,
    ));
  }

  Future<void> _onCancelBooking(CancelBooking e, Emitter<AppState> emit) async {
    final updated = state.bookings.map((b) =>
    b.id == e.bookingId ? b.copyWith(status: BookingStatus.cancelled) : b
    ).toList();
    emit(state.copyWith(bookings: updated));

    // Persist status change
    await DatabaseHelper.updateBookingStatus(e.bookingId, BookingStatus.cancelled);
  }

  // ── Booking form events ───────────────────────────────────────────────────

  void _onSelectRestaurant(SelectRestaurant e, Emitter<AppState> emit) =>
      emit(state.copyWith(selectedRestaurant: e.restaurant));

  void _onSelectDate(SelectDate e, Emitter<AppState> emit) =>
      emit(state.copyWith(selectedDate: e.date, selectedTimeSlot: ''));

  void _onSelectTimeSlot(SelectTimeSlot e, Emitter<AppState> emit) =>
      emit(state.copyWith(selectedTimeSlot: e.slot));

  void _onSelectGuests(SelectGuests e, Emitter<AppState> emit) =>
      emit(state.copyWith(selectedGuests: e.count));

  void _onSelectTableType(SelectTableType e, Emitter<AppState> emit) =>
      emit(state.copyWith(selectedTableType: e.type));

  void _onSetGuestName(SetGuestName e, Emitter<AppState> emit) =>
      emit(state.copyWith(guestName: e.name));

  void _onSetSpecialRequest(SetSpecialRequest e, Emitter<AppState> emit) =>
      emit(state.copyWith(specialRequest: e.request));

  void _onResetBooking(ResetBooking e, Emitter<AppState> emit) =>
      emit(state.copyWith(
        clearDate       : true,
        selectedTimeSlot: '',
        selectedGuests  : 2,
        selectedTableType: tableTypes.first,
        guestName       : '',
        specialRequest  : '',
      ));

  // ── UI events ─────────────────────────────────────────────────────────────

  void _onSetSearchQuery(SetSearchQuery e, Emitter<AppState> emit) =>
      emit(state.copyWith(searchQuery: e.query));

  void _onSelectCuisine(SelectCuisine e, Emitter<AppState> emit) =>
      emit(state.copyWith(selectedCuisine: e.cuisine));

  void _onChangeTab(ChangeTab e, Emitter<AppState> emit) =>
      emit(state.copyWith(currentTab: e.tab));

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<Restaurant> _resetFavourites(List<Restaurant> list) =>
      list.map((r) => r.copyWith(isFavorite: false)).toList();
}