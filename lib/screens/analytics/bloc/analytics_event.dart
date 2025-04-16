part of 'analytics_bloc.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

final class AnalyticsSubscriptionRequested extends AnalyticsEvent {
  const AnalyticsSubscriptionRequested();
}
