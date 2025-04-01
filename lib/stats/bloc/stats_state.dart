part of 'stats_bloc.dart';

enum StatsStatus { initial, loading, success, failure }

final class StatsState extends Equatable {
  const StatsState({
    this.status = StatsStatus.initial,
    this.completedUsers = 0,
    this.activeUsers = 0,
  });

  final StatsStatus status;
  final int completedUsers;
  final int activeUsers;

  @override
  List<Object> get props => [status, completedUsers, activeUsers];

  StatsState copyWith({
    StatsStatus? status,
    int? completedUsers,
    int? activeUsers,
  }) {
    return StatsState(
      status: status ?? this.status,
      completedUsers: completedUsers ?? this.completedUsers,
      activeUsers: activeUsers ?? this.activeUsers,
    );
  }
}
