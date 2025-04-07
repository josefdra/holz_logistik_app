part of 'analytics_bloc.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

final class AnalyticsSubscriptionRequested extends AnalyticsEvent {
  const AnalyticsSubscriptionRequested();
}

final class AnalyticsContractDeleted extends AnalyticsEvent {
  const AnalyticsContractDeleted(this.contract);

  final Contract contract;

  @override
  List<Object> get props => [contract];
}

final class AnalyticsUndoDeletionRequested extends AnalyticsEvent {
  const AnalyticsUndoDeletionRequested();
}
