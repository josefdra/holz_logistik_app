part of 'shipment_form_bloc.dart';

sealed class ShipmentFormEvent extends Equatable {
  const ShipmentFormEvent();

  @override
  List<Object> get props => [];
}

final class ShipmentFormSubscriptionRequested extends ShipmentFormEvent {
  const ShipmentFormSubscriptionRequested();
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

final class ShipmentFormRestQuantityUpdate extends ShipmentFormEvent {
  const ShipmentFormRestQuantityUpdate(this.currentQuantity);

  final double currentQuantity;

  @override
  List<Object> get props => [currentQuantity];
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

final class ShipmentFormRestOversizeQuantityUpdate extends ShipmentFormEvent {
  const ShipmentFormRestOversizeQuantityUpdate(this.currentOversizeQuantity);

  final double currentOversizeQuantity;

  @override
  List<Object> get props => [currentOversizeQuantity];
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

final class ShipmentFormRestPieceCountUpdate extends ShipmentFormEvent {
  const ShipmentFormRestPieceCountUpdate(this.currentPieceCount);

  final int currentPieceCount;

  @override
  List<Object> get props => [currentPieceCount];
}

final class ShipmentFormAdditionalInfoChanged extends ShipmentFormEvent {
  const ShipmentFormAdditionalInfoChanged(this.additionalInfo);

  final String additionalInfo;

  @override
  List<Object> get props => [additionalInfo];
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
