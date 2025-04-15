part of 'edit_contract_bloc.dart';

sealed class EditContractEvent extends Equatable {
  const EditContractEvent();

  @override
  List<Object> get props => [];
}

final class EditContractTitleChanged extends EditContractEvent {
  const EditContractTitleChanged(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

final class EditContractAdditionalInfoChanged extends EditContractEvent {
  const EditContractAdditionalInfoChanged(this.additionalInfo);

  final String additionalInfo;

  @override
  List<Object> get props => [additionalInfo];
}

final class EditContractSubmitted extends EditContractEvent {
  const EditContractSubmitted();
}
