part of 'edit_location_bloc.dart';

enum EditLocationStatus { initial, loading, success, failure }

extension EditLocationStatusX on EditLocationStatus {
  bool get isLoadingOrSuccess => [
        EditLocationStatus.loading,
        EditLocationStatus.success,
      ].contains(this);
}

final class EditLocationState extends Equatable {
  EditLocationState({
    this.status = EditLocationStatus.initial,
    this.initialLocation,
    this.newMarkerPosition,
    this.partieNr = '',
    this.additionalInfo = '',
    this.initialQuantity = 0.0,
    this.initialOversizeQuantity = 0.0,
    this.initialPieceCount = 0,
    this.contractId = '',
    this.sawmills = const [],
    this.oversizeSawmills = const [],
    this.photos = const [],
    this.newSawmill,
    MultiSelectController<Sawmill>? sawmillController,
    MultiSelectController<Sawmill>? oversizeSawmillController,
  })  : sawmillController =
            sawmillController ?? MultiSelectController<Sawmill>(),
        oversizeSawmillController =
            oversizeSawmillController ?? MultiSelectController<Sawmill>();

  final EditLocationStatus status;
  final Location? initialLocation;
  final LatLng? newMarkerPosition;
  final String partieNr;
  final String additionalInfo;
  final double initialQuantity;
  final double initialOversizeQuantity;
  final int initialPieceCount;
  final String contractId;
  final List<Sawmill> sawmills;
  final List<Sawmill> oversizeSawmills;
  final List<Photo> photos;
  final Sawmill? newSawmill;
  final MultiSelectController<Sawmill> sawmillController;
  final MultiSelectController<Sawmill> oversizeSawmillController;

  bool get isNewLocation => initialLocation == null;

  EditLocationState copyWith({
    EditLocationStatus? status,
    Location? initialLocation,
    LatLng? newMarkerPosition,
    String? partieNr,
    String? additionalInfo,
    double? initialQuantity,
    double? initialOversizeQuantity,
    int? initialPieceCount,
    String? contractId,
    List<Sawmill>? sawmills,
    List<Sawmill>? oversizeSawmills,
    List<Photo>? photos,
    Sawmill? newSawmill,
  }) {
    return EditLocationState(
      status: status ?? this.status,
      initialLocation: initialLocation ?? this.initialLocation,
      newMarkerPosition: newMarkerPosition ?? this.newMarkerPosition,
      partieNr: partieNr ?? this.partieNr,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      initialOversizeQuantity:
          initialOversizeQuantity ?? this.initialOversizeQuantity,
      initialPieceCount: initialPieceCount ?? this.initialPieceCount,
      contractId: contractId ?? this.contractId,
      sawmills: sawmills ?? this.sawmills,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      photos: photos ?? this.photos,
      newSawmill: newSawmill,
      sawmillController: sawmillController,
      oversizeSawmillController: oversizeSawmillController,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialLocation,
        newMarkerPosition,
        partieNr,
        additionalInfo,
        initialQuantity,
        initialOversizeQuantity,
        initialPieceCount,
        contractId,
        sawmills,
        oversizeSawmills,
        photos,
        newSawmill,
        sawmillController,
        oversizeSawmillController,
      ];
}
