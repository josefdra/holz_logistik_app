part of 'edit_location_bloc.dart';

sealed class EditLocationEvent extends Equatable {
  const EditLocationEvent();

  @override
  List<Object> get props => [];
}

final class EditLocationPartieNrChanged extends EditLocationEvent {
  const EditLocationPartieNrChanged(this.partieNr);

  final String partieNr;

  @override
  List<Object> get props => [partieNr];
}

final class EditLocationAdditionalInfoChanged extends EditLocationEvent {
  const EditLocationAdditionalInfoChanged(this.additionalInfo);

  final String additionalInfo;

  @override
  List<Object> get props => [additionalInfo];
}

final class EditLocationInitialQuantityChanged extends EditLocationEvent {
  const EditLocationInitialQuantityChanged(this.initialQuantity);

  final double initialQuantity;

  @override
  List<Object> get props => [initialQuantity];
}

final class EditLocationInitalOversizeQuantityChanged
    extends EditLocationEvent {
  const EditLocationInitalOversizeQuantityChanged(this.initialOversizeQuantity);

  final double initialOversizeQuantity;

  @override
  List<Object> get props => [initialOversizeQuantity];
}

final class EditLocationInitialPieceCountChanged extends EditLocationEvent {
  const EditLocationInitialPieceCountChanged(this.initialPieceCount);

  final int initialPieceCount;

  @override
  List<Object> get props => [initialPieceCount];
}

final class EditLocationCurrentQuantityChanged extends EditLocationEvent {
  const EditLocationCurrentQuantityChanged(this.currentQuantity);

  final double currentQuantity;

  @override
  List<Object> get props => [currentQuantity];
}

final class EditLocationCurrentOversizeQuantityChanged
    extends EditLocationEvent {
  const EditLocationCurrentOversizeQuantityChanged(
    this.currentOversizeQuantity,
  );

  final double currentOversizeQuantity;

  @override
  List<Object> get props => [currentOversizeQuantity];
}

final class EditLocationCurrentPieceCountChanged extends EditLocationEvent {
  const EditLocationCurrentPieceCountChanged(this.currentPieceCount);

  final int currentPieceCount;

  @override
  List<Object> get props => [currentPieceCount];
}

final class EditLocationContractChanged extends EditLocationEvent {
  const EditLocationContractChanged(this.contract);

  final Contract contract;

  @override
  List<Object> get props => [contract];
}

final class EditLocationSawmillsChanged extends EditLocationEvent {
  const EditLocationSawmillsChanged(this.sawmills);

  final List<Sawmill> sawmills;

  @override
  List<Object> get props => [sawmills];
}

final class EditLocationOversizeSawmillsChanged extends EditLocationEvent {
  const EditLocationOversizeSawmillsChanged(this.oversizeSawmills);

  final List<Sawmill> oversizeSawmills;

  @override
  List<Object> get props => [oversizeSawmills];
}

final class EditLocationPhotosChanged extends EditLocationEvent {
  const EditLocationPhotosChanged(this.photos);

  final List<Photo> photos;

  @override
  List<Object> get props => [photos];
}

final class EditLocationSubmitted extends EditLocationEvent {
  const EditLocationSubmitted();
}
