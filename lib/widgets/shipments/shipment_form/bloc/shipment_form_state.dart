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
    required this.currentQuantity,
    required this.currentOversizeQuantity,
    required this.currentPieceCount,
    required this.location,
    required this.userId,
    this.status = ShipmentFormStatus.initial,
    this.quantity = 0,
    this.oversizeQuantity = 0,
    this.pieceCount = 0,
    this.sawmillId = '',
    this.validationErrors = const {},
    this.locationFinished = false,
  });

  final double currentQuantity;
  final double currentOversizeQuantity;
  final int currentPieceCount;
  final Location location;
  final String userId;
  final ShipmentFormStatus status;
  final double quantity;
  final double oversizeQuantity;
  final int pieceCount;
  final String sawmillId;
  final Map<String, String?> validationErrors;
  final bool locationFinished;

  ShipmentFormState copyWith({
    double? currentQuantity,
    double? currentOversizeQuantity,
    int? currentPieceCount,
    Location? location,
    String? userId,
    ShipmentFormStatus? status,
    double? quantity,
    double? oversizeQuantity,
    int? pieceCount,
    String? sawmillId,
    Map<String, String?>? validationErrors,
    bool? locationFinished,
  }) {
    return ShipmentFormState(
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
      sawmillId: sawmillId ?? this.sawmillId,
      validationErrors: validationErrors ?? this.validationErrors,
      locationFinished: locationFinished ?? this.locationFinished,
    );
  }

  @override
  List<Object> get props => [
        currentQuantity,
        currentOversizeQuantity,
        currentPieceCount,
        location,
        userId,
        status,
        quantity,
        oversizeQuantity,
        pieceCount,
        sawmillId,
        validationErrors,
        locationFinished,
      ];
}
