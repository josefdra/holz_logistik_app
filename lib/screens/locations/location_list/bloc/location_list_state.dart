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
    this.sort = LocationListSort.dateUp,
  });

  final LocationListStatus status;
  final List<Location> locations;
  final Map<String, Photo> photos;
  final Map<String, String> contractNames;
  final SearchQuery<Location> searchQuery;
  final LocationListSort sort;

  Iterable<Location> get searchQueryedLocations =>
      searchQuery.applyAll(locations);

  LocationListState copyWith({
    LocationListStatus? status,
    List<Location>? locations,
    Map<String, Photo>? photos,
    Map<String, String>? contractNames,
    SearchQuery<Location>? searchQuery,
    LocationListSort? sort,
  }) {
    return LocationListState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      photos: photos ?? this.photos,
      contractNames: contractNames ?? this.contractNames,
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
        photos,
        contractNames,
        searchQuery,
        sort,
      ];
}
