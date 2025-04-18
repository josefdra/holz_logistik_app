part of 'edit_location_bloc.dart';

sealed class EditLocationEvent extends Equatable {
  const EditLocationEvent();

  @override
  List<Object> get props => [];
}

final class EditLocationInit extends EditLocationEvent {
  const EditLocationInit();
}

final class EditLocationPartieNrChanged extends EditLocationEvent {
  const EditLocationPartieNrChanged(this.partieNr, {
    this.fieldName = 'partieNr',
  });

  final String fieldName;
  final String partieNr;

  @override
  List<Object> get props => [partieNr];
}

final class EditLocationDateChanged extends EditLocationEvent {
  const EditLocationDateChanged(this.date);

  final DateTime date;

  @override
  List<Object> get props => [date];
}

final class EditLocationAdditionalInfoChanged extends EditLocationEvent {
  const EditLocationAdditionalInfoChanged(this.additionalInfo);

  final String additionalInfo;

  @override
  List<Object> get props => [additionalInfo];
}

final class EditLocationInitialQuantityChanged extends EditLocationEvent {
  const EditLocationInitialQuantityChanged(this.initialQuantity, {
    this.fieldName = 'initialQuantity',
  });

  final String fieldName;
  final double initialQuantity;

  @override
  List<Object> get props => [initialQuantity];
}

final class EditLocationInitialOversizeQuantityChanged
    extends EditLocationEvent {
  const EditLocationInitialOversizeQuantityChanged(
    this.initialOversizeQuantity, {
    this.fieldName = 'initialOversizeQuantity',
  });

  final String fieldName;
  final double initialOversizeQuantity;

  @override
  List<Object> get props => [initialOversizeQuantity];
}

final class EditLocationInitialPieceCountChanged extends EditLocationEvent {
  const EditLocationInitialPieceCountChanged(this.initialPieceCount, {
    this.fieldName = 'initialPieceCount',
  });

  final String fieldName;
  final int initialPieceCount;

  @override
  List<Object> get props => [initialPieceCount];
}

final class EditLocationContractChanged extends EditLocationEvent {
  const EditLocationContractChanged(this.contractId);
  
  final String contractId;

  @override
  List<Object> get props => [contractId];
}

final class EditLocationNewSawmillChanged extends EditLocationEvent {
  const EditLocationNewSawmillChanged(this.newSawmill);

  final Sawmill newSawmill;

  @override
  List<Object> get props => [newSawmill];
}

final class EditLocationSawmillsChanged extends EditLocationEvent {
  const EditLocationSawmillsChanged(this.sawmills);

  final List<String> sawmills;

  @override
  List<Object> get props => [sawmills];
}

final class EditLocationOversizeSawmillsChanged extends EditLocationEvent {
  const EditLocationOversizeSawmillsChanged(this.oversizeSawmills);

  final List<String> oversizeSawmills;

  @override
  List<Object> get props => [oversizeSawmills];
}

final class EditLocationPhotosChanged extends EditLocationEvent {
  const EditLocationPhotosChanged(this.locationId);

  final String locationId;

  @override
  List<Object> get props => [locationId];
}

final class EditLocationNewSawmillSubmitted extends EditLocationEvent {
  const EditLocationNewSawmillSubmitted();
}

final class EditLocationSawmillUpdate extends EditLocationEvent {
  const EditLocationSawmillUpdate(this.allSawmills);

  final List<String> allSawmills;

  @override
  List<Object> get props => [allSawmills];
}

final class EditLocationContractUpdate extends EditLocationEvent {
  const EditLocationContractUpdate(this.contracts);

  final List<Contract> contracts;

  @override
  List<Object> get props => [contracts];
}

final class EditLocationSubmitted extends EditLocationEvent {
  const EditLocationSubmitted();
}
