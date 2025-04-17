import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'analytics_page_event.dart';
part 'analytics_page_state.dart';

class AnalyticsPageBloc
    extends Bloc<AnalyticsPageEvent, AnalyticsPageState> {
  AnalyticsPageBloc() : super(const AnalyticsPageState()) {
    on<AnalyticsPageSubscriptionRequested>(_onSubscriptionRequested);
  }

  final scrollController = ScrollController();

  Future<void> _onSubscriptionRequested(
    AnalyticsPageSubscriptionRequested event,
    Emitter<AnalyticsPageState> emit,
  ) async {
    emit(state.copyWith(status: AnalyticsPageStatus.success));
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
