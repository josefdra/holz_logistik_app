part of 'edit_user_bloc.dart';

sealed class EditUserEvent extends Equatable {
  const EditUserEvent();

  @override
  List<Object> get props => [];
}

final class EditUserTitleChanged extends EditUserEvent {
  const EditUserTitleChanged(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

final class EditUserDescriptionChanged extends EditUserEvent {
  const EditUserDescriptionChanged(this.description);

  final String description;

  @override
  List<Object> get props => [description];
}

final class EditUserSubmitted extends EditUserEvent {
  const EditUserSubmitted();
}
