part of 'finished_locations_bloc.dart';

enum FinishedLocationStatus { initial, loading, success, failure }

final class FinishedLocationState extends Equatable {
  FinishedLocationState({
    this.status = FinishedLocationStatus.initial,
    this.locations = const [],
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();

  final FinishedLocationStatus status;
  final List<Location> locations;
  final ScrollController scrollController;

  FinishedLocationState copyWith({
    FinishedLocationStatus? status,
    List<Location>? locations,
  }) {
    return FinishedLocationState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      scrollController: scrollController,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
      ];
}
