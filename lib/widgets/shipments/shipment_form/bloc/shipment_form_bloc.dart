import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'shipment_form_event.dart';
part 'shipment_form_state.dart';

class ShipmentFormBloc extends Bloc<ShipmentFormEvent, ShipmentFormState> {
  ShipmentFormBloc({
    required double currentQuantity,
    required double currentOversizeQuantity,
    required int currentPieceCount,
    required Location location,
    required String userId,
    required ShipmentRepository shipmentRepository,
    required LocationRepository locationRepository,
    required ContractRepository contractRepository,
  })  : _shipmentRepository = shipmentRepository,
        _locationRepository = locationRepository,
        _contractRepository = contractRepository,
        super(
          ShipmentFormState(
            currentQuantity: currentQuantity,
            currentOversizeQuantity: currentOversizeQuantity,
            currentPieceCount: currentPieceCount,
            location: location,
            userId: userId,
          ),
        ) {
    on<ShipmentFormQuantityUpdate>(_onQuantityUpdate);
    on<ShipmentFormOversizeQuantityUpdate>(_onOversizeQuantityUpdate);
    on<ShipmentFormPieceCountUpdate>(_onPieceCountUpdate);
    on<ShipmentFormSawmillUpdate>(_onSawmillUpdate);
    on<ShipmentFormLocationFinishedUpdate>(_onLocationFinishedUpdate);
    on<ShipmentFormSubmitted>(_onSubmitted);
    on<ShipmentFormCanceled>(_onCanceled);
  }

  final ShipmentRepository _shipmentRepository;
  final LocationRepository _locationRepository;
  final ContractRepository _contractRepository;

  void _onQuantityUpdate(
    ShipmentFormQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    final locationFinished = (state.currentQuantity == event.quantity) &&
        (state.currentPieceCount == state.pieceCount);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        quantity: event.quantity,
        locationFinished: locationFinished,
      ),
    );
  }

  void _onOversizeQuantityUpdate(
    ShipmentFormOversizeQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        oversizeQuantity: event.oversizeQuantity,
      ),
    );
  }

  void _onPieceCountUpdate(
    ShipmentFormPieceCountUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    final locationFinished = (state.currentQuantity == state.quantity) &&
        (state.currentPieceCount == event.pieceCount);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        pieceCount: event.pieceCount,
        locationFinished: locationFinished,
      ),
    );
  }

  void _onSawmillUpdate(
    ShipmentFormSawmillUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(
      state.copyWith(validationErrors: updatedErrors, sawmillId: event.sawmill),
    );
  }

  void _onLocationFinishedUpdate(
    ShipmentFormLocationFinishedUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(
      state.copyWith(locationFinished: event.locationFinished),
    );
  }

  Map<String, String?> _validateFields() {
    final errors = <String, String?>{};

    if (state.quantity == 0 || state.quantity > state.currentQuantity) {
      errors['quantity'] =
          'Menge darf nicht 0 oder größer als \ndie verfügbare Menge sein';
    }

    if (state.oversizeQuantity > state.currentOversizeQuantity) {
      errors['oversizeQuantity'] =
          'Menge ÜS darf nicht größer als die \nverfügbare Menge ÜS sein';
    }

    if (state.oversizeQuantity > state.quantity) {
      errors['oversizeQuantity'] =
          'Menge ÜS kann nicht größer als \nMenge sein';
    }

    if (state.pieceCount == 0 || state.pieceCount > state.currentPieceCount) {
      errors['pieceCount'] = 'Stückzahl darf nicht 0 oder größer als '
          '\ndie verfügbare Stückzahl sein';
    }

    if (state.sawmillId.isEmpty || state.sawmillId == '') {
      errors['sawmill'] = 'Sägewerk darf nicht leer sein';
    }

    return errors;
  }

  Future<void> _onSubmitted(
    ShipmentFormSubmitted event,
    Emitter<ShipmentFormState> emit,
  ) async {
    final validationErrors =
        !state.locationFinished ? _validateFields() : <String, String?>{};

    if (validationErrors.isNotEmpty) {
      emit(
        state.copyWith(
          validationErrors: validationErrors,
          status: ShipmentFormStatus.invalid,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ShipmentFormStatus.loading));

    try {
      final shipment = Shipment().copyWith(
        quantity: state.quantity,
        oversizeQuantity: state.oversizeQuantity,
        pieceCount: state.pieceCount,
        userId: state.userId,
        contractId: state.location.contractId,
        sawmillId: state.sawmillId,
        locationId: state.location.id,
      );

      await _shipmentRepository.saveShipment(shipment);

      emit(
        state.copyWith(
          status: ShipmentFormStatus.success,
        ),
      );

      await _locationRepository.addShipment(
        shipment.locationId,
        shipment.quantity,
        shipment.oversizeQuantity,
        shipment.pieceCount,
        locationFinished: state.locationFinished,
      );

      final contract =
          await _contractRepository.getContractById(shipment.contractId);

      await _contractRepository.saveContract(
        contract.copyWith(
          shippedQuantity: contract.shippedQuantity + shipment.quantity,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ShipmentFormStatus.failure,
        ),
      );
    }
  }

  void _onCanceled(
    ShipmentFormCanceled event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(
      state.copyWith(
        status: ShipmentFormStatus.success,
      ),
    );
  }
}
