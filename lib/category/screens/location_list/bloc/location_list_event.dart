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

final class LocationListLocationDeleted extends LocationListEvent {
  const LocationListLocationDeleted(this.location);

  final Location location;

  @override
  List<Object> get props => [location];
}

final class LocationListUndoDeletionRequested extends LocationListEvent {
  const LocationListUndoDeletionRequested();
}

class LocationListSearchQueryChanged extends LocationListEvent {
  const LocationListSearchQueryChanged(this.searchQuery);

  final String searchQuery;

  @override
  List<Object> get props => [searchQuery];
}
