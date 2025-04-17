part of 'contract_list_bloc.dart';

enum ContractListStatus { initial, loading, success, failure }

final class ContractListState extends Equatable {
  const ContractListState({
    this.status = ContractListStatus.initial,
    this.contracts = const [],
  });

  final ContractListStatus status;
  final List<Contract> contracts;

  ContractListState copyWith({
    ContractListStatus? status,
    List<Contract>? contracts,
  }) {
    return ContractListState(
      status: status ?? this.status,
      contracts: contracts != null ? sortByDate(contracts) : this.contracts,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contracts,
      ];
}
