import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/analytics/analytics.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

part 'analytics_page_event.dart';
part 'analytics_page_state.dart';

class AnalyticsPageBloc extends Bloc<AnalyticsPageEvent, AnalyticsPageState> {
  AnalyticsPageBloc({
    required ShipmentRepository shipmentRepository,
    required SawmillRepository sawmillRepository,
    required LocationRepository locationRepository,
  })  : _shipmentRepository = shipmentRepository,
        _sawmillRepository = sawmillRepository,
        _locationRepository = locationRepository,
        super(AnalyticsPageState()) {
    on<AnalyticsPageSubscriptionRequested>(_onSubscriptionRequested);
    on<AnalyticsPageShipmentUpdate>(_onShipmentUpdate);
    on<AnalyticsPageLocationUpdate>(_onLocationUpdate);
    on<AnalyticsPageRefreshRequested>(_onRefreshRequested);
    on<AnalyticsPageDateChanged>(_onDateChanged);
    on<AnalyticsPageAutomaticDate>(_onAutomaticDate);

    _dateCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDateChange();
    });
  }

  final ShipmentRepository _shipmentRepository;
  final SawmillRepository _sawmillRepository;
  final LocationRepository _locationRepository;
  late final Timer _dateCheckTimer;
  final scrollController = ScrollController();

  late final StreamSubscription<Shipment>? _shipmentUpdateSubscription;

  void _checkDateChange() {
    final now = DateTime.now();

    if (now.isAfter(state.endDate) && !state.customDate) {
      add(const AnalyticsPageRefreshRequested());
    }
  }

  Future<void> _onSubscriptionRequested(
    AnalyticsPageSubscriptionRequested event,
    Emitter<AnalyticsPageState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsPageStatus.loading));
    add(const AnalyticsPageShipmentUpdate());

    _shipmentUpdateSubscription =
        _shipmentRepository.shipmentUpdates.listen((shipment) {
      if (state.startDate.millisecondsSinceEpoch <=
              shipment.date.millisecondsSinceEpoch &&
          shipment.date.millisecondsSinceEpoch <=
              state.endDate.millisecondsSinceEpoch) {
        add(const AnalyticsPageShipmentUpdate());
      }
    });

    await emit.forEach<List<Location>>(
      _locationRepository.activeLocations,
      onData: (locations) {
        add(AnalyticsPageLocationUpdate(locations));
        return state.copyWith(
          status: AnalyticsPageStatus.success,
        );
      },
      onError: (_, __) => state.copyWith(
        status: AnalyticsPageStatus.failure,
      ),
    );
  }

  Future<void> _onShipmentUpdate(
    AnalyticsPageShipmentUpdate event,
    Emitter<AnalyticsPageState> emit,
  ) async {
    final shipments = await _shipmentRepository.getShipmentsByDate(
      state.startDate,
      state.endDate,
    );

    final analyticsData = <String, AnalyticsDataElement>{};

    for (final shipment in shipments) {
      if (analyticsData.containsKey(shipment.sawmillId)) {
        final data = analyticsData[shipment.sawmillId]!;
        analyticsData[shipment.sawmillId] = data.copyWith(
          quantity: data.quantity + shipment.quantity,
          oversizeQuantity: data.oversizeQuantity + shipment.oversizeQuantity,
          pieceCount: data.pieceCount + shipment.pieceCount,
        );
      } else {
        final sawmills = await _sawmillRepository.sawmills.first;
        analyticsData[shipment.sawmillId] = AnalyticsDataElement(
          sawmillName: sawmills[shipment.sawmillId]!.name,
          quantity: shipment.quantity,
          oversizeQuantity: shipment.oversizeQuantity,
          pieceCount: shipment.pieceCount,
        );
      }
    }

    emit(
      state.copyWith(
        status: AnalyticsPageStatus.success,
        analyticsData: analyticsData,
      ),
    );
  }

  Future<void> _onLocationUpdate(
    AnalyticsPageLocationUpdate event,
    Emitter<AnalyticsPageState> emit,
  ) async {
    var totalQuantity = 0.0;
    var totalOversizeQuantity = 0.0;
    var totalPieceCount = 0;

    for (final location in event.locations) {
      totalQuantity += location.currentQuantity;
      totalOversizeQuantity += location.currentOversizeQuantity;
      totalPieceCount += location.currentPieceCount;
    }

    emit(
      state.copyWith(
        totalCurrentQuantity: totalQuantity,
        totalCurrentOversizeQuantity: totalOversizeQuantity,
        totalCurrentPieceCount: totalPieceCount,
      ),
    );
  }

  Future<void> _onRefreshRequested(
    AnalyticsPageRefreshRequested event,
    Emitter<AnalyticsPageState> emit,
  ) async {
    final endDate = DateTime.now().copyWith(hour: 23, minute: 59, second: 59);
    final startDate = endDate.subtract(const Duration(days: 32));

    emit(
      state.copyWith(
        startDate: startDate,
        endDate: endDate,
      ),
    );

    add(const AnalyticsPageShipmentUpdate());
  }

  Future<void> _onDateChanged(
    AnalyticsPageDateChanged event,
    Emitter<AnalyticsPageState> emit,
  ) async {
    emit(
      state.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
        customDate: true,
      ),
    );

    add(const AnalyticsPageShipmentUpdate());
  }

  Future<void> _onAutomaticDate(
    AnalyticsPageAutomaticDate event,
    Emitter<AnalyticsPageState> emit,
  ) async {
    emit(state.copyWith(customDate: false));

    add(const AnalyticsPageRefreshRequested());
  }

  @override
  Future<void> close() async {
    await _shipmentUpdateSubscription?.cancel();
    scrollController.dispose();
    _dateCheckTimer.cancel();
    return super.close();
  }
}
