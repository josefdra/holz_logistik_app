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

final class EditContractAvailableQuantityChanged extends EditContractEvent {
  const EditContractAvailableQuantityChanged(this.availableQuantity);

  final double availableQuantity;

  @override
  List<Object> get props => [availableQuantity];
}

final class EditContractBookedQuantityChanged extends EditContractEvent {
  const EditContractBookedQuantityChanged(this.bookedQuantity);

  final double bookedQuantity;

  @override
  List<Object> get props => [bookedQuantity];
}

final class EditContractShippedQuantityChanged extends EditContractEvent {
  const EditContractShippedQuantityChanged(
    this.shippedQuantity,
  );

  final double shippedQuantity;

  @override
  List<Object> get props => [shippedQuantity];
}

final class EditContractSubmitted extends EditContractEvent {
  const EditContractSubmitted();
}
