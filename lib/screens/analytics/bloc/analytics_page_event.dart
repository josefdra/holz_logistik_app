part of 'analytics_page_bloc.dart';

sealed class AnalyticsPageEvent extends Equatable {
  const AnalyticsPageEvent();

  @override
  List<Object> get props => [];
}

final class AnalyticsPageSubscriptionRequested extends AnalyticsPageEvent {
  const AnalyticsPageSubscriptionRequested();
}
