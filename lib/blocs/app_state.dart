part of 'app_bloc.dart';

class AppState extends Equatable {
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;
  final DateTime? selectedDate;
  final String selectedTimeSlot;
  final int selectedGuests;
  final String selectedTableType;
  final String guestName;
  final String specialRequest;
  final List<Booking> bookings;
  final bool isSubmitting;
  final Booking? lastBooking;
  final String searchQuery;
  final String selectedCuisine;
  final int currentTab;

  const AppState({
    required this.restaurants,
    this.selectedRestaurant,
    this.selectedDate,
    required this.selectedTimeSlot,
    required this.selectedGuests,
    required this.selectedTableType,
    required this.guestName,
    required this.specialRequest,
    required this.bookings,
    required this.isSubmitting,
    this.lastBooking,
    required this.searchQuery,
    required this.selectedCuisine,
    required this.currentTab,
  });

  factory AppState.initial() => AppState(
    restaurants: sampleRestaurants,
    selectedTimeSlot: '',
    selectedGuests: 2,
    selectedTableType: tableTypes.first,
    guestName: '',
    specialRequest: '',
    bookings: [],
    isSubmitting: false,
    searchQuery: '',
    selectedCuisine: 'All',
    currentTab: 0,
  );

  AppState copyWith({
    List<Restaurant>? restaurants,
    Restaurant? selectedRestaurant,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    int? selectedGuests,
    String? selectedTableType,
    String? guestName,
    String? specialRequest,
    List<Booking>? bookings,
    bool? isSubmitting,
    Booking? lastBooking,
    String? searchQuery,
    String? selectedCuisine,
    int? currentTab,
    bool clearDate = false,
  }) => AppState(
    restaurants: restaurants ?? this.restaurants,
    selectedRestaurant: selectedRestaurant ?? this.selectedRestaurant,
    selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
    selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
    selectedGuests: selectedGuests ?? this.selectedGuests,
    selectedTableType: selectedTableType ?? this.selectedTableType,
    guestName: guestName ?? this.guestName,
    specialRequest: specialRequest ?? this.specialRequest,
    bookings: bookings ?? this.bookings,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    lastBooking: lastBooking ?? this.lastBooking,
    searchQuery: searchQuery ?? this.searchQuery,
    selectedCuisine: selectedCuisine ?? this.selectedCuisine,
    currentTab: currentTab ?? this.currentTab,
  );

  List<Restaurant> get favorites => restaurants.where((r) => r.isFavorite).toList();

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

  @override
  List<Object?> get props => [
    restaurants, selectedRestaurant, selectedDate, selectedTimeSlot,
    selectedGuests, selectedTableType, guestName, specialRequest,
    bookings, isSubmitting, lastBooking, searchQuery, selectedCuisine, currentTab,
  ];
}
