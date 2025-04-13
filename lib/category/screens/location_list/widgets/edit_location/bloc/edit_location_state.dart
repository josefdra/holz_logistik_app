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
    this.allSawmills = const [],
    this.sawmills = const [],
    this.oversizeSawmills = const [],
    this.photos = const [],
    this.newSawmill,
    TextEditingController? newSawmillController,
    MultiSelectController<Sawmill>? sawmillController,
    MultiSelectController<Sawmill>? oversizeSawmillController,
  })  : newSawmillController = newSawmillController ?? TextEditingController(),
        sawmillController =
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
  final List<Sawmill> allSawmills;
  final List<Sawmill> sawmills;
  final List<Sawmill> oversizeSawmills;
  final List<Photo> photos;
  final Sawmill? newSawmill;
  final TextEditingController newSawmillController;
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
    List<Sawmill>? allSawmills,
    List<Sawmill>? sawmills,
    List<Sawmill>? oversizeSawmills,
    List<Photo>? photos,
    Sawmill? newSawmill,
    TextEditingController? newSawmillController,
    MultiSelectController<Sawmill>? sawmillController,
    MultiSelectController<Sawmill>? oversizeSawmillController,
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
      allSawmills: allSawmills ?? this.allSawmills,
      sawmills: sawmills ?? this.sawmills,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      photos: photos ?? this.photos,
      newSawmill: newSawmill ?? this.newSawmill,
      newSawmillController: newSawmillController ?? this.newSawmillController,
      sawmillController: sawmillController ?? this.sawmillController,
      oversizeSawmillController:
          oversizeSawmillController ?? this.oversizeSawmillController,
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
        allSawmills,
        sawmills,
        oversizeSawmills,
        photos,
        newSawmill,
        newSawmillController,
        sawmillController,
        oversizeSawmillController,
      ];
}
