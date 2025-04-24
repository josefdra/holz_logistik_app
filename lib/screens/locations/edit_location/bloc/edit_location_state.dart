part of 'edit_location_bloc.dart';

enum EditLocationStatus { initial, loading, success, invalid, failure }

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
    this.contracts = const [],
    this.oversizeSawmills = const [],
    this.photos = const [],
    this.newSawmill,
    this.date,
    this.validationErrors = const {},
    TextEditingController? newSawmillController,
    MultiSelectController<String>? sawmillController,
    MultiSelectController<String>? oversizeSawmillController,
  })  : newSawmillController = newSawmillController ?? TextEditingController(),
        sawmillController =
            sawmillController ?? MultiSelectController<String>(),
        oversizeSawmillController =
            oversizeSawmillController ?? MultiSelectController<String>();

  final EditLocationStatus status;
  final Location? initialLocation;
  final LatLng? newMarkerPosition;
  final String partieNr;
  final String additionalInfo;
  final double initialQuantity;
  final double initialOversizeQuantity;
  final int initialPieceCount;
  final String contractId;
  final List<String> allSawmills;
  final List<String> sawmills;
  final List<Contract> contracts;
  final List<String> oversizeSawmills;
  final List<Photo> photos;
  final Sawmill? newSawmill;
  final DateTime? date;
  final Map<String, String?> validationErrors;
  final TextEditingController newSawmillController;
  final MultiSelectController<String> sawmillController;
  final MultiSelectController<String> oversizeSawmillController;

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
    List<String>? allSawmills,
    List<String>? sawmills,
    List<Contract>? contracts,
    List<String>? oversizeSawmills,
    List<Photo>? photos,
    Sawmill? newSawmill,
    DateTime? date,
    Map<String, String?>? validationErrors,
    TextEditingController? newSawmillController,
    MultiSelectController<String>? sawmillController,
    MultiSelectController<String>? oversizeSawmillController,
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
      allSawmills:
          allSawmills ?? this.allSawmills,
      sawmills: sawmills ?? this.sawmills,
      contracts: contracts != null ? sortByDate(contracts) : this.contracts,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      photos: photos != null ? sortByDate(photos) : this.photos,
      newSawmill: newSawmill ?? this.newSawmill,
      date: date ?? this.date,
      validationErrors: validationErrors ?? this.validationErrors,
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
        contracts,
        oversizeSawmills,
        photos,
        newSawmill,
        date,
        validationErrors,
        newSawmillController,
        sawmillController,
        oversizeSawmillController,
      ];
}
