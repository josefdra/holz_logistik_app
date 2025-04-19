part of 'edit_contract_bloc.dart';

sealed class EditContractEvent extends Equatable {
  const EditContractEvent();

  @override
  List<Object> get props => [];
}

final class EditContractTitleChanged extends EditContractEvent {
  const EditContractTitleChanged(this.title, {
    this.fieldName = 'title',
  });

  final String fieldName;
  final String title;

  @override
  List<Object> get props => [title];
}

final class EditContractDateRangeChanged extends EditContractEvent {
  const EditContractDateRangeChanged(this.startDate, this.endDate);

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}

final class EditContractAvailableQuantityChanged extends EditContractEvent {
  const EditContractAvailableQuantityChanged(this.availableQuantity);

  final double availableQuantity;

  @override
  List<Object> get props => [availableQuantity];
}

final class EditContractAdditionalInfoChanged extends EditContractEvent {
  const EditContractAdditionalInfoChanged(this.additionalInfo);

  final String additionalInfo;

  @override
  List<Object> get props => [additionalInfo];
}

final class EditContractContractFinishedUpdate extends EditContractEvent {
  // ignore: avoid_positional_boolean_parameters
  const EditContractContractFinishedUpdate(this.contractFinished);

  final bool contractFinished;

  @override
  List<Object> get props => [contractFinished];
}

final class EditContractSubmitted extends EditContractEvent {
  const EditContractSubmitted();
}

final class EditContractCanceled extends EditContractEvent {
  const EditContractCanceled();
}
