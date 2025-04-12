import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'location_details_event.dart';
part 'location_details_state.dart';

class LocationDetailsBloc
    extends Bloc<LocationDetailsEvent, LocationDetailsState> {
  LocationDetailsBloc({
    required LocationRepository locationsRepository,
    required SawmillRepository sawmillRepository,
    required ShipmentRepository shipmentRepository,
    required Location initialLocation,
  })  : _locationsRepository = locationsRepository,
        _sawmillRepository = sawmillRepository,
        _shipmentRepository = shipmentRepository,
        super(
          LocationDetailsState(
            location: initialLocation,
          ),
        ) {
    on<LocationDetailsSubscriptionRequested>(_onSubscriptionRequested);
    on<LocationDetailsLocationUpdate>(_onLocationUpdate);
    on<LocationDetailsSawmillUpdate>(_onSawmillUpdate);
    on<LocationDetailsOversizeSawmillUpdate>(_onOversizeSawmillUpdate);
    on<LocationDetailsShipmentUpdate>(_onShipmentUpdate);
  }

  final LocationRepository _locationsRepository;
  final SawmillRepository _sawmillRepository;
  final ShipmentRepository _shipmentRepository;

  void _onSubscriptionRequested(
    LocationDetailsSubscriptionRequested event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(status: LocationDetailsStatus.loading));

    try {
      _locationsRepository.activeLocations
          .map(
            (locations) => locations
                .where((location) => location.id == state.location.id)
                .toList(),
          )
          .listen(
            (filteredLocations) =>
                add(LocationDetailsLocationUpdate(filteredLocations.first)),
          );

      _sawmillRepository.sawmills.map(
        (sawmills) {
          final sawmillIds = state.location.sawmillIds;
          if (sawmillIds == null || sawmillIds.isEmpty) {
            return <Sawmill>[];
          }
          return sawmills
              .where(
                (sawmill) => state.location.sawmillIds!.contains(sawmill.id),
              )
              .toList();
        },
      ).listen(
        (filteredSawmills) =>
            add(LocationDetailsSawmillUpdate(filteredSawmills)),
      );

      _sawmillRepository.sawmills.map(
        (sawmills) {
          final sawmillIds = state.location.sawmillIds;
          if (sawmillIds == null || sawmillIds.isEmpty) {
            return <Sawmill>[];
          }
          return sawmills
              .where(
                (sawmill) =>
                    state.location.oversizeSawmillIds!.contains(sawmill.id),
              )
              .toList();
        },
      ).listen(
        (filteredOversizeSawmills) => add(
          LocationDetailsOversizeSawmillUpdate(filteredOversizeSawmills),
        ),
      );

      _shipmentRepository.shipmentsByLocation
          .map(
            (shipmentMap) => shipmentMap.containsKey(state.location.id)
                ? shipmentMap[state.location.id]!
                : const <Shipment>[],
          )
          .listen(
            (filteredShipments) =>
                add(LocationDetailsShipmentUpdate(filteredShipments)),
          );

      emit(
        state.copyWith(
          status: LocationDetailsStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: LocationDetailsStatus.failure,
        ),
      );
    }
  }

  void _onLocationUpdate(
    LocationDetailsLocationUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(location: event.location));
  }

  void _onSawmillUpdate(
    LocationDetailsSawmillUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(sawmills: event.sawmills));
  }

  void _onOversizeSawmillUpdate(
    LocationDetailsOversizeSawmillUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(state.copyWith(oversizeSawmills: event.oversizeSawmills));
  }

  void _onShipmentUpdate(
    LocationDetailsShipmentUpdate event,
    Emitter<LocationDetailsState> emit,
  ) {
    emit(
      state.copyWith(shipments: event.shipments),
    );
  }
}
