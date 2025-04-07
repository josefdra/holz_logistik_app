part of 'analytics_bloc.dart';

enum AnalyticsStatus { initial, loading, success, failure }

final class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.contracts = const [],
    this.lastDeletedContract,
  });

  final AnalyticsStatus status;
  final List<Contract> contracts;
  final Contract? lastDeletedContract;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<Contract>? contracts,
    Contract? lastDeletedContract,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      contracts: contracts != null ? sortByLastEdit(contracts) : this.contracts,
      lastDeletedContract: lastDeletedContract ?? this.lastDeletedContract,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contracts,
        lastDeletedContract,
      ];
}
