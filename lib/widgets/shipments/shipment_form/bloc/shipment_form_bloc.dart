import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
            initialCurrentQuantity: currentQuantity,
            initialCurrentOversizeQuantity: currentOversizeQuantity,
            initialCurrentPieceCount: currentPieceCount,
            currentQuantity: currentQuantity,
            currentOversizeQuantity: currentOversizeQuantity,
            currentPieceCount: currentPieceCount,
            location: location,
            userId: userId,
          ),
        ) {
    on<ShipmentFormSubscriptionRequested>(_onSubscriptionRequested);
    on<ShipmentFormQuantityUpdate>(_onQuantityUpdate);
    on<ShipmentFormRestQuantityUpdate>(_onRestQuantityUpdate);
    on<ShipmentFormOversizeQuantityUpdate>(_onOversizeQuantityUpdate);
    on<ShipmentFormRestOversizeQuantityUpdate>(_onRestOversizeQuantityUpdate);
    on<ShipmentFormPieceCountUpdate>(_onPieceCountUpdate);
    on<ShipmentFormRestPieceCountUpdate>(_onRestPieceCountUpdate);
    on<ShipmentFormAdditionalInfoChanged>(_onAdditionalInfoChanged);
    on<ShipmentFormSawmillUpdate>(_onSawmillUpdate);
    on<ShipmentFormLocationFinishedUpdate>(_onLocationFinishedUpdate);
    on<ShipmentFormSubmitted>(_onSubmitted);
    on<ShipmentFormCanceled>(_onCanceled);
  }

  final ShipmentRepository _shipmentRepository;
  final LocationRepository _locationRepository;
  final ContractRepository _contractRepository;

  final restQuantityController = TextEditingController();
  final restOversizeQuantityController = TextEditingController();
  final restPieceCountController = TextEditingController();

  void _onSubscriptionRequested(
    ShipmentFormSubscriptionRequested event,
    Emitter<ShipmentFormState> emit,
  ) {
    restQuantityController.value =
        TextEditingValue(text: state.currentQuantity.toString());
    restOversizeQuantityController.value =
        TextEditingValue(text: state.currentOversizeQuantity.toString());
    restPieceCountController.value =
        TextEditingValue(text: state.currentPieceCount.toString());
  }

  void _onQuantityUpdate(
    ShipmentFormQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    final double updatedCurrentQuantity =
        max(state.initialCurrentQuantity - event.quantity, 0);

    restQuantityController.value =
        TextEditingValue(text: updatedCurrentQuantity.toString());

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        quantity: event.quantity,
        currentQuantity: updatedCurrentQuantity,
      ),
    );
  }

  void _onRestQuantityUpdate(
    ShipmentFormRestQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(
      state.copyWith(
        currentQuantity: event.currentQuantity,
      ),
    );
  }

  void _onOversizeQuantityUpdate(
    ShipmentFormOversizeQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    final double updatedCurrentOversizeQuantity =
        max(state.initialCurrentOversizeQuantity - event.oversizeQuantity, 0);

    restOversizeQuantityController.value =
        TextEditingValue(text: updatedCurrentOversizeQuantity.toString());

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        oversizeQuantity: event.oversizeQuantity,
        currentOversizeQuantity: updatedCurrentOversizeQuantity,
      ),
    );
  }

  void _onRestOversizeQuantityUpdate(
    ShipmentFormRestOversizeQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(
      state.copyWith(
        currentOversizeQuantity: event.currentOversizeQuantity,
      ),
    );
  }

  void _onPieceCountUpdate(
    ShipmentFormPieceCountUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    final updatedCurrentPieceCount =
        max(state.initialCurrentPieceCount - event.pieceCount, 0);

    restPieceCountController.value =
        TextEditingValue(text: updatedCurrentPieceCount.toString());

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        pieceCount: event.pieceCount,
        currentPieceCount: updatedCurrentPieceCount,
      ),
    );
  }

  void _onRestPieceCountUpdate(
    ShipmentFormRestPieceCountUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(
      state.copyWith(
        currentPieceCount: event.currentPieceCount,
      ),
    );
  }

  void _onAdditionalInfoChanged(
    ShipmentFormAdditionalInfoChanged event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(state.copyWith(additionalInfo: event.additionalInfo));
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
      state.copyWith(
        locationFinished: event.locationFinished,
        currentQuantity: 0,
        currentOversizeQuantity: 0,
        currentPieceCount: 0,
      ),
    );
  }

  Map<String, String?> _validateFields() {
    final errors = <String, String?>{};

    if (state.quantity == 0) {
      errors['quantity'] = 'Menge darf nicht 0 sein';
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
        additionalInfo: state.additionalInfo,
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
        state.currentQuantity,
        state.currentOversizeQuantity,
        state.currentPieceCount,
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

  @override
  Future<void> close() async {
    restQuantityController.dispose();
    restOversizeQuantityController.dispose();
    restPieceCountController.dispose();
    return super.close();
  }
}
