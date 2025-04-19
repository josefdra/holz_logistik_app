part of 'edit_contract_bloc.dart';

enum EditContractStatus { initial, loading, success, invalid, failure }

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
    DateTime? lastEdit,
    this.title = '',
    this.additionalInfo = '',
    this.validationErrors = const {},
    this.contractFinished = false,
    DateTime? endDate,
    DateTime? startDate,
    this.availableQuantity = 0,
  })  : lastEdit = lastEdit ?? DateTime.now(),
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now();

  final EditContractStatus status;
  final Contract? initialContract;
  final DateTime lastEdit;
  final String title;
  final String additionalInfo;
  final Map<String, String?> validationErrors;
  final bool contractFinished;
  final DateTime endDate;
  final DateTime startDate;
  final double availableQuantity;

  bool get isNewContract => initialContract == null;

  EditContractState copyWith({
    EditContractStatus? status,
    Contract? initialContract,
    DateTime? lastEdit,
    String? title,
    String? additionalInfo,
    Map<String, String?>? validationErrors,
    bool? contractFinished,
    DateTime? endDate,
    DateTime? startDate,
    double? availableQuantity,
  }) {
    return EditContractState(
      status: status ?? this.status,
      initialContract: initialContract ?? this.initialContract,
      lastEdit: lastEdit ?? this.lastEdit,
      title: title ?? this.title,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      validationErrors: validationErrors ?? this.validationErrors,
      contractFinished: contractFinished ?? this.contractFinished,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
      availableQuantity: availableQuantity ?? this.availableQuantity,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialContract,
        lastEdit,
        title,
        additionalInfo,
        validationErrors,
        contractFinished,
        endDate,
        startDate,
        availableQuantity,
      ];
}
