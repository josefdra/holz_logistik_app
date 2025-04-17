part of 'finished_locations_bloc.dart';

enum FinishedLocationStatus { initial, loading, success, failure }

final class FinishedLocationState extends Equatable {
  const FinishedLocationState({
    this.status = FinishedLocationStatus.initial,
    this.locations = const [],
  });

  final FinishedLocationStatus status;
  final List<Location> locations;

  FinishedLocationState copyWith({
    FinishedLocationStatus? status,
    List<Location>? locations,
  }) {
    return FinishedLocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
      ];
}
