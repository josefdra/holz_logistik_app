import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'photo_view_event.dart';
part 'photo_view_state.dart';

class PhotoViewBloc extends Bloc<PhotoViewEvent, PhotoViewState> {
  PhotoViewBloc({
    required int initialIndex,
  })  : pageController = PageController(initialPage: initialIndex),
        super(PhotoViewState(currentIndex: initialIndex)) {
    on<PhotoViewIndexChanged>(_onIndexChanged);
  }

  final PageController pageController;

  Future<void> _onIndexChanged(
    PhotoViewIndexChanged event,
    Emitter<PhotoViewState> emit,
  ) async {
    emit(state.copyWith(currentIndex: event.currentIndex));
  }

  @override
  Future<void> close() async {
    pageController.dispose();
    return super.close();
  }
}
