part of 'analytics_page_bloc.dart';

sealed class AnalyticsPageEvent extends Equatable {
  const AnalyticsPageEvent();

  @override
  List<Object> get props => [];
}

final class AnalyticsPageSubscriptionRequested extends AnalyticsPageEvent {
  const AnalyticsPageSubscriptionRequested();
}

final class AnalyticsPageShipmentUpdate extends AnalyticsPageEvent {
  const AnalyticsPageShipmentUpdate();
}

final class AnalyticsPageLocationUpdate extends AnalyticsPageEvent {
  const AnalyticsPageLocationUpdate(this.locations);

  final List<Location> locations;

  @override
  List<Object> get props => [locations];
}

final class AnalyticsPageRefreshRequested extends AnalyticsPageEvent {
  const AnalyticsPageRefreshRequested();
}

final class AnalyticsPageDateChanged extends AnalyticsPageEvent {
  const AnalyticsPageDateChanged(this.startDate, this.endDate);

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}

final class AnalyticsPageAutomaticDate extends AnalyticsPageEvent {
  const AnalyticsPageAutomaticDate();
}
