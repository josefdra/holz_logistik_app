part of 'stats_bloc.dart';

enum StatsStatus { initial, loading, success, failure }

final class StatsState extends Equatable {
  const StatsState({
    this.status = StatsStatus.initial,
    this.privilegedUsers = 0,
    this.activeUsers = 0,
  });

  final StatsStatus status;
  final int privilegedUsers;
  final int activeUsers;

  @override
  List<Object> get props => [status, privilegedUsers, activeUsers];

  StatsState copyWith({
    StatsStatus? status,
    int? privilegedUsers,
    int? activeUsers,
  }) {
    return StatsState(
      status: status ?? this.status,
      privilegedUsers: privilegedUsers ?? this.privilegedUsers,
      activeUsers: activeUsers ?? this.activeUsers,
    );
  }
}
