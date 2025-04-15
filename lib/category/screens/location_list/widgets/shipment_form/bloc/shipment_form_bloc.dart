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
  })  : _shipmentRepository = shipmentRepository,
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

  void _onQuantityUpdate(
    ShipmentFormQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(state.copyWith(quantity: event.quantity));
  }

  void _onOversizeQuantityUpdate(
    ShipmentFormOversizeQuantityUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(state.copyWith(oversizeQuantity: event.oversizeQuantity));
  }

  void _onPieceCountUpdate(
    ShipmentFormPieceCountUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(state.copyWith(pieceCount: event.pieceCount));
  }

  void _onSawmillUpdate(
    ShipmentFormSawmillUpdate event,
    Emitter<ShipmentFormState> emit,
  ) {
    emit(state.copyWith(sawmillId: event.sawmill));
  }

  void _onSubmitted(
    ShipmentFormSubmitted event,
    Emitter<ShipmentFormState> emit,
  ) {
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
