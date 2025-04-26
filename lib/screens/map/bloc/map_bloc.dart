import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/models.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required LocationRepository locationRepository,
    required AuthenticationRepository authenticationRepository,
    required SawmillRepository sawmillRepository,
    required ContractRepository contractRepository,
  })  : _locationRepository = locationRepository,
        _authenticationRepository = authenticationRepository,
        _sawmillRepository = sawmillRepository,
        _contractRepository = contractRepository,
        _locationService = LocationService(),
        super(MapState()) {
    on<MapSubscriptionRequested>(_onSubscriptionRequested);
    on<MapLocationsUpdate>(_onLocationsUpdate);
    on<MapSawmillsUpdate>(_onSawmillsUpdate);
    on<MapResetMapRotation>(_onResetMapRotation);
    on<MapAuthenticationUpdate>(_onAuthenticationUpdate);
    on<MapCenterToPosition>(_onCenterToPosition);
    on<MapToggleAddMarkerMode>(_onToggleAddMarkerMode);
    on<MapToggleMarkerInfoMode>(_onToggleMarkerInfoMode);
    on<MapLocationUpdated>(_onLocationUpdated);
    on<MapDisableTrackingMode>(_onDisableTrackingMode);
    on<MapMapTap>(_onMapTap);
    on<MapConnectivityChanged>(_onConnectivityChanged);
    on<MapMapReady>(_onMapReady);

    _initLocationTracking();
  }

  final LocationRepository _locationRepository;
  final AuthenticationRepository _authenticationRepository;
  final SawmillRepository _sawmillRepository;
  final ContractRepository _contractRepository;
  final MapController mapController = MapController();
  final LocationService _locationService;

  late final StreamSubscription<List<Location>>? _locationSubscription;
  late final StreamSubscription<User>? _authenticationSubscription;
  late final StreamSubscription<Map<String, Sawmill>>? _sawmillSubscription;
  late final StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  Future<void> _initLocationTracking() async {
    await _locationService.initLocationService((latitude, longitude) {
      add(
        MapLocationUpdated(
          latitude: latitude,
          longitude: longitude,
        ),
      );
    });
  }

  Future<void> _onSubscriptionRequested(
    MapSubscriptionRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(status: MapStatus.loading));

    _authenticationSubscription =
        _authenticationRepository.authenticatedUser.listen(
      (user) => add(MapAuthenticationUpdate(user)),
    );

    _sawmillSubscription = _sawmillRepository.sawmills.listen(
      (sawmills) => add(MapSawmillsUpdate(sawmills)),
    );

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
          (connectivity) =>
              add(MapConnectivityChanged(connectivity: connectivity)),
        );

    _locationSubscription = _locationRepository.activeLocations
        .listen((locations) => add(MapLocationsUpdate(locations: locations)));
  }

  Future<void> _onLocationsUpdate(
    MapLocationsUpdate event,
    Emitter<MapState> emit,
  ) async {
    final contractNames = <String, String>{};

    for (final location in event.locations) {
      final contract =
          await _contractRepository.getContractById(location.contractId);
      contractNames[location.contractId] = contract.name;
    }

    emit(
      state.copyWith(
        status: MapStatus.success,
        locations: event.locations,
        contractNames: contractNames,
      ),
    );
  }

  Future<void> _onResetMapRotation(
    MapResetMapRotation event,
    Emitter<MapState> emit,
  ) async {
    if (state.mapReady) {
      mapController.rotate(0);
    }
  }

  void _onAuthenticationUpdate(
    MapAuthenticationUpdate event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(user: event.user));
  }

  void _onSawmillsUpdate(
    MapSawmillsUpdate event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(sawmills: event.sawmills));
  }

  Future<void> _onCenterToPosition(
    MapCenterToPosition event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(trackingMode: true));
    if (state.mapReady) {
      mapController.rotate(0);

      if (state.trackingMode && state.userLocation != null) {
        mapController.move(state.userLocation!, 14);
      }
    }
  }

  Future<void> _onToggleAddMarkerMode(
    MapToggleAddMarkerMode event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(addMarkerMode: !state.addMarkerMode));
  }

  Future<void> _onToggleMarkerInfoMode(
    MapToggleMarkerInfoMode event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(showInfoMode: !state.showInfoMode));
  }

  Future<void> _onLocationUpdated(
    MapLocationUpdated event,
    Emitter<MapState> emit,
  ) async {
    final newLocation = LatLng(event.latitude, event.longitude);

    emit(
      state.copyWith(
        userLocation: newLocation,
      ),
    );

    if (state.trackingMode && state.mapReady) {
      mapController.move(newLocation, mapController.camera.zoom);
    }
  }

  Future<void> _onDisableTrackingMode(
    MapDisableTrackingMode event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(trackingMode: false));
  }

  Future<void> _onMapTap(
    MapMapTap event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(trackingMode: false, newMarkerPosition: event.position),
    );
  }

  Future<void> _onConnectivityChanged(
    MapConnectivityChanged event,
    Emitter<MapState> emit,
  ) async {
    final result = event.connectivity[0];
    if ((result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet) &&
        state.mapReady) {
      mapController.move(
        mapController.camera.center,
        mapController.camera.zoom,
      );
    }
  }

  void _onMapReady(
    MapMapReady event,
    Emitter<MapState> emit,
  ) {
    emit(state.copyWith(mapReady: true));
  }

  @override
  Future<void> close() {
    _locationService.dispose();
    _authenticationSubscription?.cancel();
    _sawmillSubscription?.cancel();
    _locationSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
