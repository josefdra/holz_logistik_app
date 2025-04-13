import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/edit_location/model/get_sawmill_ids.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/edit_location/model/get_sawmills.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/edit_location/model/save_photos.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

part 'edit_location_event.dart';
part 'edit_location_state.dart';

class EditLocationBloc extends Bloc<EditLocationEvent, EditLocationState> {
  EditLocationBloc({
    required LocationRepository locationsRepository,
    required SawmillRepository sawmillRepository,
    required PhotoRepository photoRepository,
    required Location? initialLocation,
    required LatLng? newMarkerPosition,
  })  : _locationsRepository = locationsRepository,
        _sawmillRepository = sawmillRepository,
        _photoRepository = photoRepository,
        super(
          EditLocationState(
            initialLocation: initialLocation,
            newMarkerPosition: newMarkerPosition,
            partieNr: initialLocation?.partieNr ?? '',
            additionalInfo: initialLocation?.additionalInfo ?? '',
            initialQuantity: initialLocation?.initialQuantity ?? 0.0,
            initialOversizeQuantity:
                initialLocation?.initialOversizeQuantity ?? 0.0,
            initialPieceCount: initialLocation?.initialPieceCount ?? 0,
            contractId: initialLocation?.contractId ?? '',
            sawmills:
                getSawmills(sawmillRepository, initialLocation?.sawmillIds),
            oversizeSawmills: getSawmills(
              sawmillRepository,
              initialLocation?.oversizeSawmillIds,
            ),
            photos:
                photoRepository.currentPhotosByLocation[initialLocation?.id] ??
                    const [],
          ),
        ) {
    on<EditLocationInit>(_onInit);
    on<EditLocationPartieNrChanged>(_onPartieNrChanged);
    on<EditLocationAdditionalInfoChanged>(_onAdditionalInfoChanged);
    on<EditLocationInitialQuantityChanged>(_onInitialQuantityChanged);
    on<EditLocationInitialOversizeQuantityChanged>(
      _onInitialOversizeQuantityChanged,
    );
    on<EditLocationInitialPieceCountChanged>(_onInitialPieceCountChanged);
    on<EditLocationContractChanged>(_onContractChanged);
    on<EditLocationNewSawmillChanged>(_onNewSawmillChanged);
    on<EditLocationSawmillsChanged>(_onSawmillChanged);
    on<EditLocationOversizeSawmillsChanged>(_onOversizeSawmillChanged);
    on<EditLocationPhotosChanged>(_onPhotosChanged);
    on<EditLocationNewSawmillSubmitted>(_onNewSawmillSubmitted);
    on<EditLocationSawmillUpdate>(_onSawmillUpdate);
    on<EditLocationSubmitted>(_onSubmitted);
  }

  final LocationRepository _locationsRepository;
  final SawmillRepository _sawmillRepository;
  final PhotoRepository _photoRepository;

  late final StreamSubscription<List<Sawmill>>? _sawmillSubscription;

  Future<void> _onInit(
    EditLocationInit event,
    Emitter<EditLocationState> emit,
  ) async {
    if(state.initialLocation != null){
    }

    _sawmillSubscription = _sawmillRepository.sawmills.listen(
      (sawmills) => add(EditLocationSawmillUpdate(sawmills)),
    );
  }

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
    EditLocationInitialOversizeQuantityChanged event,
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

  void _onContractChanged(
    EditLocationContractChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(contractId: event.contractId));
  }

  void _onNewSawmillChanged(
    EditLocationNewSawmillChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(newSawmill: event.newSawmill));
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

  Future<void> _onNewSawmillSubmitted(
    EditLocationNewSawmillSubmitted event,
    Emitter<EditLocationState> emit,
  ) async {
    if (state.newSawmill == null) {
      return;
    }

    await _sawmillRepository.saveSawmill(state.newSawmill!);
    final newTextEditingController = state.newSawmillController..clear();

    emit(
      state.copyWith(
        newSawmillController: newTextEditingController,
      ),
    );
  }

  Future<void> _onSawmillUpdate(
    EditLocationSawmillUpdate event,
    Emitter<EditLocationState> emit,
  ) async {
    final newSawmillController = state.sawmillController
      ..setItems(
        event.allSawmills
            .map(
              (Sawmill sawmill) =>
                  DropdownItem(label: sawmill.name, value: sawmill),
            )
            .toList(),
      );
    final newOversizeSawmillController = state.oversizeSawmillController
      ..setItems(
        event.allSawmills
            .map(
              (Sawmill sawmill) =>
                  DropdownItem(label: sawmill.name, value: sawmill),
            )
            .toList(),
      );

    emit(
      state.copyWith(
        sawmillController: newSawmillController,
        oversizeSawmillController: newOversizeSawmillController,
      ),
    );
  }

  Future<void> _onSubmitted(
    EditLocationSubmitted event,
    Emitter<EditLocationState> emit,
  ) async {
    emit(state.copyWith(status: EditLocationStatus.loading));
    final location = (state.initialLocation ??
            Location.empty(
              latitude: state.newMarkerPosition!.latitude,
              longitude: state.newMarkerPosition!.longitude,
            ))
        .copyWith(
      lastEdit: DateTime.now(),
      partieNr: state.partieNr,
      additionalInfo: state.additionalInfo,
      initialQuantity: state.initialQuantity,
      initialOversizeQuantity: state.initialOversizeQuantity,
      initialPieceCount: state.initialPieceCount,
      contractId: state.contractId,
      sawmillIds: getSawmillIds(state.sawmills),
      oversizeSawmillIds: getSawmillIds(state.oversizeSawmills),
    );

    savePhotos(_photoRepository, state.photos);

    try {
      await _locationsRepository.saveLocation(location);
      emit(state.copyWith(status: EditLocationStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditLocationStatus.failure));
    }
  }

  @override
  Future<void> close() async {
    await _sawmillSubscription?.cancel();
    state.newSawmillController.dispose();
    state.sawmillController.dispose();
    state.oversizeSawmillController.dispose();
    return super.close();
  }
}
