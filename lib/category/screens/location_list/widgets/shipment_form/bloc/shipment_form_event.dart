part of 'shipment_form_bloc.dart';

sealed class ShipmentFormEvent extends Equatable {
  const ShipmentFormEvent();

  @override
  List<Object> get props => [];
}

final class ShipmentFormQuantityUpdate extends ShipmentFormEvent {
  const ShipmentFormQuantityUpdate(this.quantity);

  final double quantity;

  @override
  List<Object> get props => [quantity];
}

final class ShipmentFormOversizeQuantityUpdate extends ShipmentFormEvent {
  const ShipmentFormOversizeQuantityUpdate(this.oversizeQuantity);

  final double oversizeQuantity;

  @override
  List<Object> get props => [oversizeQuantity];
}

final class ShipmentFormPieceCountUpdate extends ShipmentFormEvent {
  const ShipmentFormPieceCountUpdate(this.pieceCount);

  final int pieceCount;

  @override
  List<Object> get props => [pieceCount];
}

final class ShipmentFormSawmillUpdate extends ShipmentFormEvent {
  const ShipmentFormSawmillUpdate(this.sawmill);

  final String sawmill;

  @override
  List<Object> get props => [sawmill];
}

final class ShipmentFormSubmitted extends ShipmentFormEvent {
  const ShipmentFormSubmitted();
}

final class ShipmentFormCanceled extends ShipmentFormEvent {
  const ShipmentFormCanceled();
}
