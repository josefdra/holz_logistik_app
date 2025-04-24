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
  })  : endDate = endDate ??
            DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
        startDate = startDate ??
            DateTime.now()
                .copyWith(hour: 23, minute: 59, second: 59)
                .subtract(const Duration(days: 32));

  final FinishedLocationsStatus status;
  final List<Location> locations;
  final Map<String, String> contractNames;
  final DateTime endDate;
  final DateTime startDate;
  final bool customDate;

  FinishedLocationsState copyWith({
    FinishedLocationsStatus? status,
    List<Location>? locations,
    Map<String, String>? contractNames,
    DateTime? endDate,
    DateTime? startDate,
    bool? customDate,
  }) {
    return FinishedLocationsState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      contractNames: contractNames ?? this.contractNames,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      customDate: customDate ?? this.customDate,
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
      ];
}
