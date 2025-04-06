part of 'location_list_bloc.dart';

enum LocationListStatus { initial, loading, success, failure }

final class LocationListState extends Equatable {
  const LocationListState({
    this.status = LocationListStatus.initial,
    this.locations = const [],
    this.searchQuery = const LocationListSearchQuery(),
    this.lastDeletedLocation,
  });

  final LocationListStatus status;
  final List<Location> locations;
  final LocationListSearchQuery searchQuery;
  final Location? lastDeletedLocation;

  Iterable<Location> get searchQueryedLocations =>
      searchQuery.applyAll(locations);

  LocationListState copyWith({
    LocationListStatus Function()? status,
    List<Location> Function()? locations,
    LocationListSearchQuery Function()? searchQuery,
    Location? Function()? lastDeletedLocation,
  }) {
    return LocationListState(
      status: status != null ? status() : this.status,
      locations:
          locations != null ? sortByLastEdit(locations()) : this.locations,
      searchQuery: searchQuery != null ? searchQuery() : this.searchQuery,
      lastDeletedLocation: lastDeletedLocation != null
          ? lastDeletedLocation()
          : this.lastDeletedLocation,
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
