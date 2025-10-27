part of 'finished_locations_bloc.dart';

enum FinishedLocationsStatus { initial, loading, success, failure }

final class FinishedLocationsState extends Equatable {
  FinishedLocationsState({
    this.status = FinishedLocationsStatus.initial,
    this.locations = const [],
    this.contractNames = const {},
    DateTime? endDate,
    DateTime? startDate,
    this.customDate = false,
    this.searchQuery = const SearchQuery<Location>(),
    this.sort = LocationListSort.dateDown,
  })  : endDate = endDate ??
            DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
        startDate = startDate ??
            DateTime.now()
                .copyWith(hour: 23, minute: 59, second: 59)
                .subtract(const Duration(days: 365));

  final FinishedLocationsStatus status;
  final List<Location> locations;
  final Map<String, String> contractNames;
  final DateTime endDate;
  final DateTime startDate;
  final bool customDate;
  final SearchQuery<Location> searchQuery;
  final LocationListSort sort;

  Iterable<Location> get searchQueryedLocations =>
      searchQuery.applyAll(locations);

  FinishedLocationsState copyWith({
    FinishedLocationsStatus? status,
    List<Location>? locations,
    Map<String, String>? contractNames,
    DateTime? endDate,
    DateTime? startDate,
    bool? customDate,
    SearchQuery<Location>? searchQuery,
    LocationListSort? sort,
  }) {
    return FinishedLocationsState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      contractNames: contractNames ?? this.contractNames,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      customDate: customDate ?? this.customDate,
      searchQuery: searchQuery ?? this.searchQuery,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
        contractNames,
        endDate,
        startDate,
        customDate,
        searchQuery,
        sort,
      ];
}
