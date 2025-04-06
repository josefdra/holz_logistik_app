import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/api/photo_api.dart';
import 'package:holz_logistik_backend/api/src_contract/contract_models/contract.dart';
import 'package:holz_logistik_backend/api/src_sawmill/sawmill_models/sawmill.dart';
import 'package:holz_logistik_backend/repository/location_repository.dart';

part 'edit_location_event.dart';
part 'edit_location_state.dart';

class EditLocationBloc extends Bloc<EditLocationEvent, EditLocationState> {
  EditLocationBloc({
    required LocationRepository locationsRepository,
    required Location? initialLocation,
  })  : _locationsRepository = locationsRepository,
        super(
          EditLocationState(
            initialLocation: initialLocation,
            partieNr: initialLocation?.partieNr ?? '',
            additionalInfo: initialLocation?.additionalInfo ?? '',
            initialQuantity: initialLocation?.initialQuantity ?? 0.0,
            initialOversizeQuantity:
                initialLocation?.initialOversizeQuantity ?? 0.0,
            initialPieceCount: initialLocation?.initialPieceCount ?? 0,
            currentQuantity: initialLocation?.currentQuantity ?? 0.0,
            currentOversizeQuantity:
                initialLocation?.currentOversizeQuantity ?? 0.0,
            currentPieceCount: initialLocation?.currentPieceCount ?? 0,
            contract: initialLocation?.contract,
            sawmills: initialLocation?.sawmills ?? [],
            oversizeSawmills: initialLocation?.oversizeSawmills ?? [],
            photos: initialLocation?.photos ?? [],
          ),
        ) {
    on<EditLocationPartieNrChanged>(_onPartieNrChanged);
    on<EditLocationAdditionalInfoChanged>(_onAdditionalInfoChanged);
    on<EditLocationInitialQuantityChanged>(_onInitialQuantityChanged);
    on<EditLocationInitalOversizeQuantityChanged>(
      _onInitialOversizeQuantityChanged,
    );
    on<EditLocationInitialPieceCountChanged>(_onInitialPieceCountChanged);
    on<EditLocationCurrentQuantityChanged>(_onCurrentQuantityChanged);
    on<EditLocationCurrentOversizeQuantityChanged>(
      _onCurrentOversizeQuantityChanged,
    );
    on<EditLocationCurrentPieceCountChanged>(_onCurrentPieceCountChanged);
    on<EditLocationContractChanged>(_onContractChanged);
    on<EditLocationSawmillsChanged>(_onSawmillChanged);
    on<EditLocationOversizeSawmillsChanged>(_onOversizeSawmillChanged);
    on<EditLocationPhotosChanged>(_onPhotosChanged);
    on<EditLocationSubmitted>(_onSubmitted);
  }

  final LocationRepository _locationsRepository;

  void _onPartieNrChanged(
    EditLocationPartieNrChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(partieNr: event.partieNr));
  }

  void _onAdditionalInfoChanged(
    EditLocationAdditionalInfoChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(additionalInfo: event.additionalInfo));
  }

  void _onInitialQuantityChanged(
    EditLocationInitialQuantityChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(initialQuantity: event.initialQuantity));
  }

  void _onInitialOversizeQuantityChanged(
    EditLocationInitalOversizeQuantityChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(
      state.copyWith(initialOversizeQuantity: event.initialOversizeQuantity),
    );
  }

  void _onInitialPieceCountChanged(
    EditLocationInitialPieceCountChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(initialPieceCount: event.initialPieceCount));
  }

  void _onCurrentQuantityChanged(
    EditLocationCurrentQuantityChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(currentQuantity: event.currentQuantity));
  }

  void _onCurrentOversizeQuantityChanged(
    EditLocationCurrentOversizeQuantityChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(
      state.copyWith(currentOversizeQuantity: event.currentOversizeQuantity),
    );
  }

  void _onCurrentPieceCountChanged(
    EditLocationCurrentPieceCountChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(currentPieceCount: event.currentPieceCount));
  }

  void _onContractChanged(
    EditLocationContractChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(contract: event.contract));
  }

  void _onSawmillChanged(
    EditLocationSawmillsChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(sawmills: event.sawmills));
  }

  void _onOversizeSawmillChanged(
    EditLocationOversizeSawmillsChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(oversizeSawmills: event.oversizeSawmills));
  }

  void _onPhotosChanged(
    EditLocationPhotosChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(photos: event.photos));
  }

  Future<void> _onSubmitted(
    EditLocationSubmitted event,
    Emitter<EditLocationState> emit,
  ) async {
    emit(state.copyWith(status: EditLocationStatus.loading));
    final location = (state.initialLocation ?? Location.empty()).copyWith(
      lastEdit: DateTime.now(),
      partieNr: state.partieNr,
      additionalInfo: state.additionalInfo,
      initialQuantity: state.initialQuantity,
      initialOversizeQuantity: state.initialOversizeQuantity,
      initialPieceCount: state.initialPieceCount,
      currentQuantity: state.currentQuantity,
      currentOversizeQuantity: state.currentOversizeQuantity,
      currentPieceCount: state.currentPieceCount,
      contract: state.contract,
      sawmills: state.sawmills,
      oversizeSawmills: state.oversizeSawmills,
      photos: state.photos,
    );

    try {
      await _locationsRepository.saveLocation(location);
      emit(state.copyWith(status: EditLocationStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditLocationStatus.failure));
    }
  }
}
