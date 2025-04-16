part of 'contract_bloc.dart';

enum ContractStatus { initial, loading, success, failure }

final class ContractState extends Equatable {
  ContractState({
    this.status = ContractStatus.initial,
    this.contracts = const [],
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController();

  final ContractStatus status;
  final List<Contract> contracts;
  final ScrollController scrollController;

  ContractState copyWith({
    ContractStatus? status,
    List<Contract>? contracts,
  }) {
    return ContractState(
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
