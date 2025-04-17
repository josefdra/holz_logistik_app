import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'finished_locations_event.dart';
part 'finished_locations_state.dart';

class FinishedLocationBloc
    extends Bloc<FinishedLocationEvent, FinishedLocationState> {
  FinishedLocationBloc({
    required LocationRepository locationRepository,
  })  : _locationRepository = locationRepository,
        super(const FinishedLocationState()) {
    on<FinishedLocationSubscriptionRequested>(_onSubscriptionRequested);
  }

  final LocationRepository _locationRepository;
  final scrollController = ScrollController();

  Future<void> _onSubscriptionRequested(
    FinishedLocationSubscriptionRequested event,
    Emitter<FinishedLocationState> emit,
  ) async {
    emit(state.copyWith(status: FinishedLocationStatus.loading));
    emit(state.copyWith(status: FinishedLocationStatus.success));
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
