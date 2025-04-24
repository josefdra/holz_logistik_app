part of 'finished_locations_bloc.dart';

sealed class FinishedLocationsEvent extends Equatable {
  const FinishedLocationsEvent();

  @override
  List<Object> get props => [];
}

final class FinishedLocationsSubscriptionRequested
    extends FinishedLocationsEvent {
  const FinishedLocationsSubscriptionRequested();
}

final class FinishedLocationsLocationUpdate extends FinishedLocationsEvent {
  const FinishedLocationsLocationUpdate();
}

final class FinishedLocationsRefreshRequested extends FinishedLocationsEvent {
  const FinishedLocationsRefreshRequested();
}

final class FinishedLocationsDateChanged extends FinishedLocationsEvent {
  const FinishedLocationsDateChanged(this.startDate, this.endDate);

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}

final class FinishedLocationsAutomaticDate extends FinishedLocationsEvent {
  const FinishedLocationsAutomaticDate();
}

final class FinishedLocationsLocationDeleted extends FinishedLocationsEvent {
  const FinishedLocationsLocationDeleted(this.location);

  final Location location;

  @override
  List<Object> get props => [location];
}
