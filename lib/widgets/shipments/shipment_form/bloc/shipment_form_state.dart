part of 'shipment_form_bloc.dart';

enum ShipmentFormStatus { initial, loading, success, invalid, failure }

extension ShipmentFormStatusX on ShipmentFormStatus {
  bool get isLoadingOrSuccess => [
        ShipmentFormStatus.loading,
        ShipmentFormStatus.success,
      ].contains(this);
}

final class ShipmentFormState extends Equatable {
  const ShipmentFormState({
    required this.initialCurrentQuantity,
    required this.initialCurrentOversizeQuantity,
    required this.initialCurrentPieceCount,
    required this.currentQuantity,
    required this.currentOversizeQuantity,
    required this.currentPieceCount,
    required this.location,
    required this.userId,
    this.status = ShipmentFormStatus.initial,
    this.quantity = 0,
    this.oversizeQuantity = 0,
    this.pieceCount = 0,
    this.additionalInfo = '',
    this.sawmillId = '',
    this.validationErrors = const {},
    this.locationFinished = false,
  });

  final double initialCurrentQuantity;
  final double initialCurrentOversizeQuantity;
  final int initialCurrentPieceCount;
  final double currentQuantity;
  final double currentOversizeQuantity;
  final int currentPieceCount;
  final Location location;
  final String userId;
  final ShipmentFormStatus status;
  final double quantity;
  final double oversizeQuantity;
  final int pieceCount;
  final String additionalInfo;
  final String sawmillId;
  final Map<String, String?> validationErrors;
  final bool locationFinished;

  ShipmentFormState copyWith({
    double? initialCurrentQuantity,
    double? initialCurrentOversizeQuantity,
    int? initialCurrentPieceCount,
    double? currentQuantity,
    double? currentOversizeQuantity,
    int? currentPieceCount,
    Location? location,
    String? userId,
    ShipmentFormStatus? status,
    double? quantity,
    double? oversizeQuantity,
    int? pieceCount,
    String? additionalInfo,
    String? sawmillId,
    Map<String, String?>? validationErrors,
    bool? locationFinished,
  }) {
    return ShipmentFormState(
      initialCurrentQuantity:
          initialCurrentQuantity ?? this.initialCurrentQuantity,
      initialCurrentOversizeQuantity:
          initialCurrentOversizeQuantity ?? this.initialCurrentOversizeQuantity,
      initialCurrentPieceCount:
          initialCurrentPieceCount ?? this.initialCurrentPieceCount,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      currentOversizeQuantity:
          currentOversizeQuantity ?? this.currentOversizeQuantity,
      currentPieceCount: currentPieceCount ?? this.currentPieceCount,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      pieceCount: pieceCount ?? this.pieceCount,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      sawmillId: sawmillId ?? this.sawmillId,
      validationErrors: validationErrors ?? this.validationErrors,
      locationFinished: locationFinished ?? this.locationFinished,
    );
  }

  @override
  List<Object> get props => [
        initialCurrentQuantity,
        initialCurrentOversizeQuantity,
        initialCurrentPieceCount,
        currentQuantity,
        currentOversizeQuantity,
        currentPieceCount,
        location,
        userId,
        status,
        quantity,
        oversizeQuantity,
        pieceCount,
        additionalInfo,
        sawmillId,
        validationErrors,
        locationFinished,
      ];
}
