part of 'location_list_bloc.dart';

enum LocationListStatus { initial, loading, success, failure }

final class LocationListState extends Equatable {
  const LocationListState({
    this.status = LocationListStatus.initial,
    this.locations = const [],
    this.searchQuery = const SearchQuery<Location>(),
    this.lastDeletedLocation,
  });

  final LocationListStatus status;
  final List<Location> locations;
  final SearchQuery<Location> searchQuery;
  final Location? lastDeletedLocation;

  Iterable<Location> get searchQueryedLocations =>
      searchQuery.applyAll(locations);

  LocationListState copyWith({
    LocationListStatus? status,
    List<Location>? locations,
    SearchQuery<Location>? searchQuery,
    Location? lastDeletedLocation,
  }) {
    return LocationListState(
      status: status ?? this.status,
      locations: locations != null ? sortByDate(locations) : this.locations,
      searchQuery: searchQuery ?? this.searchQuery,
      lastDeletedLocation: lastDeletedLocation ?? this.lastDeletedLocation,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
        searchQuery,
        lastDeletedLocation,
      ];
}
