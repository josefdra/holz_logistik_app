part of 'location_list_bloc.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

sealed class LocationListEvent extends Equatable {
  const LocationListEvent();

  @override
  List<Object> get props => [];
}

final class LocationListSubscriptionRequested extends LocationListEvent {
  const LocationListSubscriptionRequested();
}

class LocationListLocationsUpdate extends LocationListEvent {
  const LocationListLocationsUpdate({required this.locations});

  final List<Location> locations;

  @override
  List<Object> get props => [locations];
}

final class LocationListLocationDeleted extends LocationListEvent {
  const LocationListLocationDeleted(this.location);

  final Location location;

  @override
  List<Object> get props => [location];
}

final class LocationListContractUpdate extends LocationListEvent {
  const LocationListContractUpdate();
}

class LocationListSearchQueryChanged extends LocationListEvent {
  const LocationListSearchQueryChanged(this.searchQuery);

  final String searchQuery;

  @override
  List<Object> get props => [searchQuery];
}
