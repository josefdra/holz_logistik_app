part of 'finished_contracts_bloc.dart';

enum FinishedContractStatus { initial, loading, success, failure }

final class FinishedContractState extends Equatable {
  const FinishedContractState({
    this.status = FinishedContractStatus.initial,
    this.contracts = const [],
  });

  final FinishedContractStatus status;
  final List<Contract> contracts;

  FinishedContractState copyWith({
    FinishedContractStatus? status,
    List<Contract>? contracts,
  }) {
    return FinishedContractState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contracts,
      ];
}
