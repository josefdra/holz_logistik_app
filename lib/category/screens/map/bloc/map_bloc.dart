import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/map/map.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required LocationRepository locationRepository,
  })  : _locationRepository = locationRepository,
        super(const MapState()) {
    on<MapSubscriptionRequested>(_onSubscriptionRequested);
  }

  final LocationRepository _locationRepository;

  Future<void> _onSubscriptionRequested(
    MapSubscriptionRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(status: MapStatus.success));
  }
}
