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
    this.partieNr = '',
    this.additionalInfo = '',
    this.initialQuantity = 0.0,
    this.initialOversizeQuantity = 0.0,
    this.initialPieceCount = 0,
    this.currentQuantity = 0.0,
    this.currentOversizeQuantity = 0.0,
    this.currentPieceCount = 0,
    Contract? contract,
    this.sawmills = const [],
    this.oversizeSawmills = const [],
    this.photos = const [],
  }) : contract = contract ?? Contract.empty();

  final EditLocationStatus status;
  final Location? initialLocation;
  final String partieNr;
  final String additionalInfo;
  final double initialQuantity;
  final double initialOversizeQuantity;
  final int initialPieceCount;
  final double currentQuantity;
  final double currentOversizeQuantity;
  final int currentPieceCount;
  final Contract contract;
  final List<Sawmill> sawmills;
  final List<Sawmill> oversizeSawmills;
  final List<Photo> photos;

  bool get isNewLocation => initialLocation == null;

  EditLocationState copyWith({
    EditLocationStatus? status,
    Location? initialLocation,
    String? partieNr,
    String? additionalInfo,
    double? initialQuantity,
    double? initialOversizeQuantity,
    int? initialPieceCount,
    double? currentQuantity,
    double? currentOversizeQuantity,
    int? currentPieceCount,
    Contract? contract,
    List<Sawmill>? sawmills,
    List<Sawmill>? oversizeSawmills,
    List<Photo>? photos,
  }) {
    return EditLocationState(
      status: status ?? this.status,
      initialLocation: initialLocation ?? this.initialLocation,
      partieNr: partieNr ?? this.partieNr,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      initialOversizeQuantity:
          initialOversizeQuantity ?? this.initialOversizeQuantity,
      initialPieceCount: initialPieceCount ?? this.initialPieceCount,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      currentOversizeQuantity:
          currentOversizeQuantity ?? this.currentOversizeQuantity,
      currentPieceCount: currentPieceCount ?? this.currentPieceCount,
      contract: contract ?? this.contract,
      sawmills: sawmills ?? this.sawmills,
      oversizeSawmills: oversizeSawmills ?? this.oversizeSawmills,
      photos: photos ?? this.photos,
    );
  }

  @override
  List<Object?> get props => [
        status,
        initialLocation,
        partieNr,
        additionalInfo,
        initialQuantity,
        initialOversizeQuantity,
        initialPieceCount,
        currentQuantity,
        currentOversizeQuantity,
        currentPieceCount,
        contract,
        sawmills,
        oversizeSawmills,
        photos,
      ];
}
