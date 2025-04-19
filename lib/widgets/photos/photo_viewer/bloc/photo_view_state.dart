part of 'photo_view_bloc.dart';

final class PhotoViewState extends Equatable {
  const PhotoViewState({
    this.currentIndex = 0,
  });

  final int currentIndex;

  PhotoViewState copyWith({
    int? currentIndex,
  }) {
    return PhotoViewState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object> get props => [currentIndex];
}
