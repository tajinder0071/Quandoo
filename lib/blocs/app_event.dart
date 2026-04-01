part of 'app_bloc.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
  @override List<Object?> get props => [];
}

class ToggleFavorite extends AppEvent {
  final String restaurantId;
  const ToggleFavorite(this.restaurantId);
  @override List<Object?> get props => [restaurantId];
}

class SelectRestaurant extends AppEvent {
  final Restaurant restaurant;
  const SelectRestaurant(this.restaurant);
  @override List<Object?> get props => [restaurant];
}

class SelectDate extends AppEvent {
  final DateTime date;
  const SelectDate(this.date);
  @override List<Object?> get props => [date];
}

class SelectTimeSlot extends AppEvent {
  final String slot;
  const SelectTimeSlot(this.slot);
  @override List<Object?> get props => [slot];
}

class SelectGuests extends AppEvent {
  final int count;
  const SelectGuests(this.count);
  @override List<Object?> get props => [count];
}

class SelectTableType extends AppEvent {
  final String type;
  const SelectTableType(this.type);
  @override List<Object?> get props => [type];
}

class SetGuestName extends AppEvent {
  final String name;
  const SetGuestName(this.name);
  @override List<Object?> get props => [name];
}

class SetSpecialRequest extends AppEvent {
  final String request;
  const SetSpecialRequest(this.request);
  @override List<Object?> get props => [request];
}

class SubmitBooking extends AppEvent {}

class CancelBooking extends AppEvent {
  final String bookingId;
  const CancelBooking(this.bookingId);
  @override List<Object?> get props => [bookingId];
}

class SetSearchQuery extends AppEvent {
  final String query;
  const SetSearchQuery(this.query);
  @override List<Object?> get props => [query];
}

class SelectCuisine extends AppEvent {
  final String cuisine;
  const SelectCuisine(this.cuisine);
  @override List<Object?> get props => [cuisine];
}

class ChangeTab extends AppEvent {
  final int tab;
  const ChangeTab(this.tab);
  @override List<Object?> get props => [tab];
}

class ResetBooking extends AppEvent {}
