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
  })  : _shipmentRepository = shipmentRepository,
        _locationRepository = locationRepository,
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
    on<ShipmentFormSubmitted>(_onSubmitted);
    on<ShipmentFormCanceled>(_onCanceled);
  }

  final ShipmentRepository _shipmentRepository;
  final LocationRepository _locationRepository;

  void _onQuantityUpdate(
    ShipmentFormQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        quantity: event.quantity,
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

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        pieceCount: event.pieceCount,
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

  void _onSubmitted(
    ShipmentFormSubmitted event,
    Emitter<ShipmentFormState> emit,
  ) {
    final validationErrors = _validateFields();

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
      final shipment = Shipment.empty().copyWith(
        quantity: state.quantity,
        oversizeQuantity: state.oversizeQuantity,
        pieceCount: state.pieceCount,
        userId: state.userId,
        contractId: state.location.contractId,
        sawmillId: state.sawmillId,
        locationId: state.location.id,
      );

      _shipmentRepository.saveShipment(shipment);

      if (!state.location.started) {
        _locationRepository.setStarted(state.location.id);
      }

      emit(
        state.copyWith(
          status: ShipmentFormStatus.success,
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
