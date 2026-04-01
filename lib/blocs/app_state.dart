part of 'app_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AppState extends Equatable {
  // ── Auth ──────────────────────────────────────────────────────────
  final AuthStatus authStatus;
  final UserModel? currentUser;
  final String authError;

  // ── Data ──────────────────────────────────────────────────────────
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final List<Booking> bookings;
  final bool isLoadingData;

  // ── Booking form ──────────────────────────────────────────────────
  final DateTime? selectedDate;
  final String selectedTimeSlot;
  final int selectedGuests;
  final String selectedTableType;
  final String guestName;
  final String specialRequest;
  final bool isSubmitting;
  final Booking? lastBooking;

  // ── UI ────────────────────────────────────────────────────────────
  final String searchQuery;
  final String selectedCuisine;
  final int currentTab;

  const AppState({
    required this.authStatus,
    this.currentUser,
    required this.authError,
    required this.restaurants,
    this.selectedRestaurant,
    required this.bookings,
    required this.isLoadingData,
    this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedGuests,
    required this.selectedTableType,
    required this.guestName,
    required this.specialRequest,
    required this.isSubmitting,
    this.lastBooking,
    required this.searchQuery,
    required this.selectedCuisine,
    required this.currentTab,
  });

  factory AppState.initial() => AppState(
    authStatus: AuthStatus.initial,
    authError: '',
    restaurants: sampleRestaurants,
    bookings: [],
    isLoadingData: false,
    selectedTimeSlot: '',
    selectedGuests: 2,
    selectedTableType: tableTypes.first,
    guestName: '',
    specialRequest: '',
    isSubmitting: false,
    searchQuery: '',
    selectedCuisine: 'All',
    currentTab: 0,
  );

  AppState copyWith({
    AuthStatus? authStatus,
    UserModel? currentUser,
    String? authError,
    List<Restaurant>? restaurants,
    Restaurant? selectedRestaurant,
    List<Booking>? bookings,
    bool? isLoadingData,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    int? selectedGuests,
    String? selectedTableType,
    String? guestName,
    String? specialRequest,
    bool? isSubmitting,
    Booking? lastBooking,
    String? searchQuery,
    String? selectedCuisine,
    int? currentTab,
    bool clearDate = false,
    bool clearUser = false,
    bool clearLastBooking = false,
  }) => AppState(
    authStatus       : authStatus   ?? this.authStatus,
    currentUser      : clearUser    ? null : (currentUser ?? this.currentUser),
    authError        : authError    ?? this.authError,
    restaurants      : restaurants  ?? this.restaurants,
    selectedRestaurant: selectedRestaurant ?? this.selectedRestaurant,
    bookings         : bookings     ?? this.bookings,
    isLoadingData    : isLoadingData ?? this.isLoadingData,
    selectedDate     : clearDate    ? null : (selectedDate ?? this.selectedDate),
    selectedTimeSlot : selectedTimeSlot ?? this.selectedTimeSlot,
    selectedGuests   : selectedGuests ?? this.selectedGuests,
    selectedTableType: selectedTableType ?? this.selectedTableType,
    guestName        : guestName    ?? this.guestName,
    specialRequest   : specialRequest ?? this.specialRequest,
    isSubmitting     : isSubmitting ?? this.isSubmitting,
    lastBooking      : clearLastBooking ? null : (lastBooking ?? this.lastBooking),
    searchQuery      : searchQuery  ?? this.searchQuery,
    selectedCuisine  : selectedCuisine ?? this.selectedCuisine,
    currentTab       : currentTab   ?? this.currentTab,
  );

  // ── Derived getters ───────────────────────────────────────────────
  List<Restaurant> get favorites =>
      restaurants.where((r) => r.isFavorite).toList();

  List<Restaurant> get filteredRestaurants {
    var list = restaurants;
    if (selectedCuisine != 'All') {
      list = list.where((r) => r.cuisine.contains(selectedCuisine)).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((r) =>
        r.name.toLowerCase().contains(q) ||
        r.cuisine.toLowerCase().contains(q) ||
        r.location.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  List<Booking> get activeBookings =>
      bookings.where((b) => b.status == BookingStatus.active).toList();
  List<Booking> get completedBookings =>
      bookings.where((b) => b.status == BookingStatus.completed).toList();
  List<Booking> get cancelledBookings =>
      bookings.where((b) => b.status == BookingStatus.cancelled).toList();

  bool get isAuthenticated => authStatus == AuthStatus.authenticated;

  @override
  List<Object?> get props => [
    authStatus, currentUser, authError,
    restaurants, selectedRestaurant, bookings, isLoadingData,
    selectedDate, selectedTimeSlot, selectedGuests, selectedTableType,
    guestName, specialRequest, isSubmitting, lastBooking,
    searchQuery, selectedCuisine, currentTab,
  ];
}
