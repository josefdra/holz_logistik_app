part of 'finished_locations_bloc.dart';

sealed class FinishedLocationEvent extends Equatable {
  const FinishedLocationEvent();

  @override
  List<Object> get props => [];
}

final class FinishedLocationSubscriptionRequested
    extends FinishedLocationEvent {
  const FinishedLocationSubscriptionRequested();
}
