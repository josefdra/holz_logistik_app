part of 'location_list_bloc.dart';

enum LocationListStatus { initial, loading, success, showDetails, failure }

extension LocationListStatusX on LocationListStatus {
  bool get isShowDetailsOrSuccess => [
        LocationListStatus.success,
        LocationListStatus.showDetails,
      ].contains(this);
}

final class LocationListState extends Equatable {
  const LocationListState({
    this.status = LocationListStatus.initial,
    this.locations = const [],
    this.searchQuery = const SearchQuery<Location>(),
  });

  final LocationListStatus status;
  final List<Location> locations;
  final SearchQuery<Location> searchQuery;

  Iterable<Location> get searchQueryedLocations =>
      searchQuery.applyAll(locations);

  LocationListState copyWith({
    LocationListStatus? status,
    List<Location>? locations,
    SearchQuery<Location>? searchQuery,
  }) {
    return LocationListState(
      status: status ?? this.status,
      locations: locations != null ? sortByDate(locations) : this.locations,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
        searchQuery,
      ];
}
