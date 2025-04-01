import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:users_repository/users_repository.dart';

part 'edit_user_event.dart';
part 'edit_user_state.dart';

class EditUserBloc extends Bloc<EditUserEvent, EditUserState> {
  EditUserBloc({
    required UsersRepository usersRepository,
    required User? initialUser,
  })  : _usersRepository = usersRepository,
        super(
          EditUserState(
            initialUser: initialUser,
            title: initialUser?.title ?? '',
            description: initialUser?.description ?? '',
          ),
        ) {
    on<EditUserTitleChanged>(_onTitleChanged);
    on<EditUserDescriptionChanged>(_onDescriptionChanged);
    on<EditUserSubmitted>(_onSubmitted);
  }

  final UsersRepository _usersRepository;

  void _onTitleChanged(
    EditUserTitleChanged event,
    Emitter<EditUserState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onDescriptionChanged(
    EditUserDescriptionChanged event,
    Emitter<EditUserState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  Future<void> _onSubmitted(
    EditUserSubmitted event,
    Emitter<EditUserState> emit,
  ) async {
    emit(state.copyWith(status: EditUserStatus.loading));
    final user = (state.initialUser ?? User(title: '')).copyWith(
      title: state.title,
      description: state.description,
    );

    try {
      await _usersRepository.saveUser(user);
      emit(state.copyWith(status: EditUserStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditUserStatus.failure));
    }
  }
}
