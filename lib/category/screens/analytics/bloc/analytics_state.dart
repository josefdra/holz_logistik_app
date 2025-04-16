part of 'analytics_bloc.dart';

enum AnalyticsStatus { initial, loading, success, failure }

final class AnalyticsState extends Equatable {
  AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.contracts = const [],
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();

  final AnalyticsStatus status;
  final List<Contract> contracts;
  final ScrollController scrollController;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    List<Contract>? contracts,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      contracts: contracts != null ? sortByLastEdit(contracts) : this.contracts,
      scrollController: scrollController,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contracts,
      ];
}
