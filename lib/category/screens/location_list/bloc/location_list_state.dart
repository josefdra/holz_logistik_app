part of 'location_list_bloc.dart';

enum LocationListStatus { initial, loading, success, failure }

final class LocationListState extends Equatable {
  LocationListState({
    this.status = LocationListStatus.initial,
    this.locations = const [],
    this.searchQuery = const LocationListSearchQuery(),
    this.lastDeletedLocation,
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();

  final LocationListStatus status;
  final List<Location> locations;
  final LocationListSearchQuery searchQuery;
  final Location? lastDeletedLocation;
  final ScrollController scrollController;

  Iterable<Location> get searchQueryedLocations =>
      searchQuery.applyAll(locations);

  LocationListState copyWith({
    LocationListStatus? status,
    List<Location>? locations,
    LocationListSearchQuery? searchQuery,
    Location? lastDeletedLocation,
  }) {
    return LocationListState(
      status: status ?? this.status,
      locations: locations != null ? sortByLastEdit(locations) : this.locations,
      searchQuery: searchQuery ?? this.searchQuery,
      lastDeletedLocation: lastDeletedLocation ?? this.lastDeletedLocation,
      scrollController: scrollController,
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
