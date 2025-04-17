part of 'analytics_page_bloc.dart';

enum AnalyticsPageStatus { initial, loading, success, failure }

final class AnalyticsPageState extends Equatable {
  const AnalyticsPageState({
    this.status = AnalyticsPageStatus.initial,
  });

  final AnalyticsPageStatus status;

  AnalyticsPageState copyWith({
    AnalyticsPageStatus? status,
  }) {
    return AnalyticsPageState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status];
}
