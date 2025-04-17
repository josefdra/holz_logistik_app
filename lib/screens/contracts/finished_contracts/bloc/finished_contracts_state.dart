part of 'finished_contracts_bloc.dart';

enum FinishedContractsStatus { initial, loading, success, failure }

final class FinishedContractsState extends Equatable {
  FinishedContractsState({
    this.status = FinishedContractsStatus.initial,
    this.contracts = const [],
    DateTime? endDate,
    DateTime? startDate,
    this.customDate = false,
  })  : endDate = endDate ??
            DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
        startDate = startDate ??
            DateTime.now()
                .copyWith(hour: 23, minute: 59, second: 59)
                .subtract(const Duration(days: 32));

  final FinishedContractsStatus status;
  final List<Contract> contracts;
  final DateTime endDate;
  final DateTime startDate;
  final bool customDate;

  FinishedContractsState copyWith({
    FinishedContractsStatus? status,
    List<Contract>? contracts,
    DateTime? endDate,
    DateTime? startDate,
    bool? customDate,
  }) {
    return FinishedContractsState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      customDate: customDate ?? this.customDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contracts,
        endDate,
        startDate,
        customDate,
      ];
}
