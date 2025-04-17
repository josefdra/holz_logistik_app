part of 'shipment_form_bloc.dart';

sealed class ShipmentFormEvent extends Equatable {
  const ShipmentFormEvent();

  @override
  List<Object> get props => [];
}

final class ShipmentFormQuantityUpdate extends ShipmentFormEvent {
  const ShipmentFormQuantityUpdate(
    this.quantity, {
    this.fieldName = 'quantity',
  });

  final String fieldName;
  final double quantity;

  @override
  List<Object> get props => [quantity];
}

final class ShipmentFormOversizeQuantityUpdate extends ShipmentFormEvent {
  const ShipmentFormOversizeQuantityUpdate(
    this.oversizeQuantity, {
    this.fieldName = 'oversizeQuantity',
  });

  final String fieldName;
  final double oversizeQuantity;

  @override
  List<Object> get props => [oversizeQuantity];
}

final class ShipmentFormPieceCountUpdate extends ShipmentFormEvent {
  const ShipmentFormPieceCountUpdate(
    this.pieceCount, {
    this.fieldName = 'pieceCount',
  });

  final String fieldName;
  final int pieceCount;

  @override
  List<Object> get props => [pieceCount];
}

final class ShipmentFormSawmillUpdate extends ShipmentFormEvent {
  const ShipmentFormSawmillUpdate(
    this.sawmill, {
    this.fieldName = 'sawmill',
  });

  final String fieldName;
  final String sawmill;

  @override
  List<Object> get props => [sawmill];
}

final class ShipmentFormLocationFinishedUpdate extends ShipmentFormEvent {
  // ignore: avoid_positional_boolean_parameters
  const ShipmentFormLocationFinishedUpdate(this.locationFinished);

  final bool locationFinished;

  @override
  List<Object> get props => [locationFinished];
}

final class ShipmentFormSubmitted extends ShipmentFormEvent {
  const ShipmentFormSubmitted();
}

final class ShipmentFormCanceled extends ShipmentFormEvent {
  const ShipmentFormCanceled();
}
