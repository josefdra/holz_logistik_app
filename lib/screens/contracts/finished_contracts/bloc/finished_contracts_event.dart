part of 'finished_contracts_bloc.dart';

sealed class FinishedContractsEvent extends Equatable {
  const FinishedContractsEvent();

  @override
  List<Object> get props => [];
}

final class FinishedContractsSubscriptionRequested
    extends FinishedContractsEvent {
  const FinishedContractsSubscriptionRequested();
}

final class FinishedContractsContractUpdate extends FinishedContractsEvent {
  const FinishedContractsContractUpdate();
}

final class FinishedContractsRefreshRequested extends FinishedContractsEvent {
  const FinishedContractsRefreshRequested();
}

final class FinishedContractsDateChanged extends FinishedContractsEvent {
  const FinishedContractsDateChanged(this.startDate, this.endDate);

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}

final class FinishedContractsAutomaticDate extends FinishedContractsEvent {
  const FinishedContractsAutomaticDate();
}

final class FinishedContractsReactivateContract extends FinishedContractsEvent {
  const FinishedContractsReactivateContract(this.contract);

  final Contract contract;

  @override
  List<Object> get props => [contract];
}
