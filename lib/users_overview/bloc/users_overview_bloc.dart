import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/users_overview/users_overview.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';

part 'users_overview_event.dart';
part 'users_overview_state.dart';

class UsersOverviewBloc extends Bloc<UsersOverviewEvent, UsersOverviewState> {
  UsersOverviewBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UsersOverviewState()) {
    on<UsersOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<UsersOverviewUserCompletionToggled>(_onUserCompletionToggled);
    on<UsersOverviewUserDeleted>(_onUserDeleted);
    on<UsersOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    on<UsersOverviewFilterChanged>(_onFilterChanged);
  }

  final UserRepository _userRepository;

  Future<void> _onSubscriptionRequested(
    UsersOverviewSubscriptionRequested event,
    Emitter<UsersOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => UsersOverviewStatus.loading));

    await emit.forEach<List<User>>(
      _userRepository.getUsers(),
      onData: (users) => state.copyWith(
        status: () => UsersOverviewStatus.success,
        users: () => users,
      ),
      onError: (_, __) => state.copyWith(
        status: () => UsersOverviewStatus.failure,
      ),
    );
  }

  Future<void> _onUserCompletionToggled(
    UsersOverviewUserCompletionToggled event,
    Emitter<UsersOverviewState> emit,
  ) async {
    final newRole = event.isPrivileged ? Role.privileged : Role.basic;
    final newUser =
        event.user.copyWith(role: newRole, lastEdit: DateTime.now());
    await _userRepository.saveUser(newUser);
  }

  Future<void> _onUserDeleted(
    UsersOverviewUserDeleted event,
    Emitter<UsersOverviewState> emit,
  ) async {
    emit(state.copyWith(lastDeletedUser: () => event.user));
    await _userRepository.deleteUser(event.user.id);
  }

  Future<void> _onUndoDeletionRequested(
    UsersOverviewUndoDeletionRequested event,
    Emitter<UsersOverviewState> emit,
  ) async {
    assert(
      state.lastDeletedUser != null,
      'Last deleted user can not be null.',
    );

    final user = state.lastDeletedUser!;
    emit(state.copyWith(lastDeletedUser: () => null));
    await _userRepository.saveUser(user);
  }

  void _onFilterChanged(
    UsersOverviewFilterChanged event,
    Emitter<UsersOverviewState> emit,
  ) {
    emit(state.copyWith(filter: () => event.filter));
  }
}
