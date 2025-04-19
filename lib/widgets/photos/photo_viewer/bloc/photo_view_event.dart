part of 'photo_view_bloc.dart';

sealed class PhotoViewEvent extends Equatable {
  const PhotoViewEvent();

  @override
  List<Object> get props => [];
}

final class PhotoViewIndexChanged extends PhotoViewEvent {
  const PhotoViewIndexChanged(this.currentIndex);

  final int currentIndex;

  @override
  List<Object> get props => [currentIndex];
}
