part of 'edit_contract_bloc.dart';

enum EditContractStatus { initial, loading, success, failure }

extension EditContractStatusX on EditContractStatus {
  bool get isLoadingOrSuccess => [
        EditContractStatus.loading,
        EditContractStatus.success,
      ].contains(this);
}

final class EditContractState extends Equatable {
  EditContractState({
    this.status = EditContractStatus.initial,
    this.initialContract,
    this.done = false,
    DateTime? lastEdit,
    this.title = '',
    this.additionalInfo = '',
    this.availableQuantity = 0.0,
    this.bookedQuantity = 0.0,
    this.shippedQuantity = 0.0,
  }) : lastEdit = lastEdit ?? DateTime.now();

  final EditContractStatus status;
  final Contract? initialContract;
  final bool done;
  final DateTime lastEdit;
  final String title;
  final String additionalInfo;
  final double availableQuantity;
  final double bookedQuantity;
  final double shippedQuantity;

  bool get isNewContract => initialContract == null;

  EditContractState copyWith({
    EditContractStatus? status,
    Contract? initialContract,
    bool? done,
    DateTime? lastEdit,
    String? title,
    String? additionalInfo,
    double? availableQuantity,
    double? bookedQuantity,
    double? shippedQuantity,
  }) {
    return EditContractState(
      status: status ?? this.status,
      initialContract: initialContract ?? this.initialContract,
      done: done ?? this.done,
      lastEdit: lastEdit ?? this.lastEdit,
      title: title ?? this.title,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      bookedQuantity: bookedQuantity ?? this.bookedQuantity,
      shippedQuantity: shippedQuantity ?? this.shippedQuantity,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialContract,
        done,
        lastEdit,
        title,
        additionalInfo,
        availableQuantity,
        bookedQuantity,
        shippedQuantity,
      ];
}
