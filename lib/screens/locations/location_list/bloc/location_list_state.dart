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
    this.photos = const {},
    this.contractNames = const {},
    this.searchQuery = const SearchQuery<Location>(),
  });

  final LocationListStatus status;
  final List<Location> locations;
  final Map<String, Photo> photos;
  final Map<String, String> contractNames;
  final SearchQuery<Location> searchQuery;

  Iterable<Location> get searchQueryedLocations =>
      searchQuery.applyAll(locations);

  LocationListState copyWith({
    LocationListStatus? status,
    List<Location>? locations,
    Map<String, Photo>? photos,
    Map<String, String>? contractNames,
    SearchQuery<Location>? searchQuery,
  }) {
    return LocationListState(
      status: status ?? this.status,
      locations:
          locations != null ? sortByDateInverse(locations) : this.locations,
      photos: photos ?? this.photos,
      contractNames: contractNames ?? this.contractNames,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
        photos,
        contractNames,
        searchQuery,
      ];
}
