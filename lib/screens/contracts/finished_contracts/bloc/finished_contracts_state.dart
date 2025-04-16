part of 'finished_contracts_bloc.dart';

enum FinishedContractStatus { initial, loading, success, failure }

final class FinishedContractState extends Equatable {
  FinishedContractState({
    this.status = FinishedContractStatus.initial,
    this.contracts = const [],
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();

  final FinishedContractStatus status;
  final List<Contract> contracts;
  final ScrollController scrollController;

  FinishedContractState copyWith({
    FinishedContractStatus? status,
    List<Contract>? contracts,
  }) {
    return FinishedContractState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      scrollController: scrollController,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contracts,
      ];
}
