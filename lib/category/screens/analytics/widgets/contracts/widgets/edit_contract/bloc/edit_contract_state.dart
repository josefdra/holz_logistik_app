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
    this.done = false,
    DateTime? lastEdit,
    this.title = '',
    this.additionalInfo = '',
    this.validationErrors = const {},
  }) : lastEdit = lastEdit ?? DateTime.now();

  final EditContractStatus status;
  final Contract? initialContract;
  final bool done;
  final DateTime lastEdit;
  final String title;
  final String additionalInfo;
  final Map<String, String?> validationErrors;

  bool get isNewContract => initialContract == null;

  EditContractState copyWith({
    EditContractStatus? status,
    Contract? initialContract,
    bool? done,
    DateTime? lastEdit,
    String? title,
    String? additionalInfo,
    Map<String, String?>? validationErrors,
  }) {
    return EditContractState(
      status: status ?? this.status,
      initialContract: initialContract ?? this.initialContract,
      done: done ?? this.done,
      lastEdit: lastEdit ?? this.lastEdit,
      title: title ?? this.title,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      validationErrors: validationErrors ?? this.validationErrors,
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
        validationErrors,
      ];
}
