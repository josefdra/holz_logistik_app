import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            date: initialLocation?.date,
            initialQuantity: initialLocation?.initialQuantity ?? 0.0,
            initialOversizeQuantity:
                initialLocation?.initialOversizeQuantity ?? 0.0,
            initialPieceCount: initialLocation?.initialPieceCount ?? 0,
            contractId: initialLocation?.contractId ?? '',
            sawmills: initialLocation?.sawmillIds ?? const [],
            oversizeSawmills: initialLocation?.oversizeSawmillIds ?? const [],
          ),
        ) {
    on<EditLocationInit>(_onInit);
    on<EditLocationPartieNrChanged>(_onPartieNrChanged);
    on<EditLocationAdditionalInfoChanged>(_onAdditionalInfoChanged);
    on<EditLocationDateChanged>(_onDateChanged);
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
  late final StreamSubscription<Map<String, dynamic>>?
      _photoUpdatesSubscription;

  Future<void> _onInit(
    EditLocationInit event,
    Emitter<EditLocationState> emit,
  ) async {
    if (state.initialLocation != null) {
      emit(
        state.copyWith(
          sawmills: state.initialLocation!.sawmillIds,
          oversizeSawmills: state.initialLocation!.oversizeSawmillIds,
        ),
      );
    }

    _sawmillSubscription = _sawmillRepository.sawmills.listen(
      (sawmills) {
        final sawmillIds = sawmills.map((sawmill) => sawmill.id).toList();
        add(EditLocationSawmillUpdate(sawmillIds));
      },
    );

    _photoUpdatesSubscription =
        _photoRepository.photoUpdates.listen((photoUpdates) {
      final locationId = state.initialLocation?.id ?? '';
      if (photoUpdates['locationId'] == locationId) {
        add(EditLocationPhotosChanged(locationId));
      }
    });
  }

  void _onPartieNrChanged(
    EditLocationPartieNrChanged event,
    Emitter<EditLocationState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        partieNr: event.partieNr,
      ),
    );
  }

  void _onAdditionalInfoChanged(
    EditLocationAdditionalInfoChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(additionalInfo: event.additionalInfo));
  }

  void _onDateChanged(
    EditLocationDateChanged event,
    Emitter<EditLocationState> emit,
  ) {
    emit(state.copyWith(date: event.date));
  }

  void _onInitialQuantityChanged(
    EditLocationInitialQuantityChanged event,
    Emitter<EditLocationState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        initialQuantity: event.initialQuantity,
      ),
    );
  }

  void _onInitialOversizeQuantityChanged(
    EditLocationInitialOversizeQuantityChanged event,
    Emitter<EditLocationState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        initialOversizeQuantity: event.initialOversizeQuantity,
      ),
    );
  }

  void _onInitialPieceCountChanged(
    EditLocationInitialPieceCountChanged event,
    Emitter<EditLocationState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(
      state.copyWith(
        validationErrors: updatedErrors,
        initialPieceCount: event.initialPieceCount,
      ),
    );
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

  Future<void> _onPhotosChanged(
    EditLocationPhotosChanged event,
    Emitter<EditLocationState> emit,
  ) async {
    final photos = await _photoRepository.getPhotosByLocation(event.locationId);

    emit(state.copyWith(photos: photos));
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
    final sawmillItems = <DropdownItem<String>>[];

    for (final sawmillId in event.allSawmills) {
      final sawmill = await _sawmillRepository.getSawmillById(sawmillId);
      final item = DropdownItem(
        label: sawmill.name,
        value: sawmillId,
      );
      sawmillItems.add(item);
    }

    final newSawmillController = state.sawmillController
      ..setItems(sawmillItems)
      ..selectWhere(
        (item) => state.sawmills.contains(item.value),
      );

    final newOversizeSawmillController = state.oversizeSawmillController
      ..setItems(sawmillItems)
      ..selectWhere(
        (item) => state.oversizeSawmills.contains(item.value),
      );

    emit(
      state.copyWith(
        sawmillController: newSawmillController,
        oversizeSawmillController: newOversizeSawmillController,
      ),
    );
  }

  Map<String, String?> _validateFields({
    double? currentQuantity,
    double? currentOversizeQuantity,
    int? currentPieceCount,
  }) {
    final errors = <String, String?>{};

    if (state.partieNr == '') {
      errors['partieNr'] = 'Partie Nummer darf nicht leer sein';
    }

    if (state.initialQuantity == 0) {
      errors['initialQuantity'] = 'Menge darf nicht 0 sein';
    }

    if (state.initialOversizeQuantity > state.initialQuantity) {
      errors['initialOversizeQuantity'] =
          'Menge ÜS kann nicht \ngrößer als Menge sein';
    }

    if (state.initialPieceCount == 0) {
      errors['initialPieceCount'] = 'Stückzahl darf nicht 0 sein';
    }

    if (state.initialLocation != null) {
      if (currentQuantity! < 0) {
        errors['initialQuantity'] =
            'Neue Anfangsmenge \nkann nicht kleiner als \nschon '
            'abgefahrene \nMenge sein';
      }

      if (currentOversizeQuantity! < 0) {
        errors['initialOversizeQuantity'] =
            'Neue Menge ÜS \nkann nicht kleiner als \nschon '
            'abgefahrene \nMenge ÜS sein';
      }

      if (currentPieceCount! < 0) {
        errors['initialPieceCount'] =
            'Neue Anfangsstückzahl \nkann nicht kleiner als \nschon '
            'abgefahrene \nStückzahl sein';
      }
    }

    return errors;
  }

  Future<void> _onSubmitted(
    EditLocationSubmitted event,
    Emitter<EditLocationState> emit,
  ) async {
    late final Map<String, String?> validationErrors;
    late final double currentQuantity;
    late final double currentOversizeQuantity;
    late final int currentPieceCount;

    if (state.initialLocation != null) {
      currentQuantity = state.initialLocation!.currentQuantity +
          state.initialQuantity -
          state.initialLocation!.initialQuantity;
      currentOversizeQuantity = state.initialLocation!.currentOversizeQuantity +
          state.initialOversizeQuantity -
          state.initialLocation!.initialOversizeQuantity;
      currentPieceCount = state.initialLocation!.currentPieceCount +
          state.initialPieceCount -
          state.initialLocation!.initialPieceCount;

      validationErrors = _validateFields(
        currentQuantity: currentQuantity,
        currentOversizeQuantity: currentOversizeQuantity,
        currentPieceCount: currentPieceCount,
      );
    } else {
      currentQuantity = state.initialQuantity;
      currentOversizeQuantity = state.initialOversizeQuantity;
      currentPieceCount = state.initialPieceCount;
      validationErrors = _validateFields();
    }

    if (validationErrors.isNotEmpty) {
      emit(
        state.copyWith(
          validationErrors: validationErrors,
          status: EditLocationStatus.invalid,
        ),
      );
      return;
    }

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
      date: state.date,
      initialQuantity: state.initialQuantity,
      initialOversizeQuantity: state.initialOversizeQuantity,
      initialPieceCount: state.initialPieceCount,
      contractId: state.contractId,
      sawmillIds: state.sawmills,
      oversizeSawmillIds: state.oversizeSawmills,
      currentQuantity: currentQuantity,
      currentOversizeQuantity: currentOversizeQuantity,
      currentPieceCount: currentPieceCount,
    );

    try {
      await _photoRepository.savePhotos(state.photos);
      await _locationsRepository.saveLocation(location);
      emit(state.copyWith(status: EditLocationStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditLocationStatus.failure));
    }
  }

  @override
  Future<void> close() async {
    await _sawmillSubscription?.cancel();
    await _photoUpdatesSubscription?.cancel();
    state.newSawmillController.dispose();
    state.sawmillController.dispose();
    state.oversizeSawmillController.dispose();
    return super.close();
  }
}
