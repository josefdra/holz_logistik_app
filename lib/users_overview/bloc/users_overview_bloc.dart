import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:holz_logistik/users_overview/users_overview.dart';
import 'package:users_repository/users_repository.dart';

part 'users_overview_event.dart';
part 'users_overview_state.dart';

class UsersOverviewBloc extends Bloc<UsersOverviewEvent, UsersOverviewState> {
  UsersOverviewBloc({
    required UsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(const UsersOverviewState()) {
    on<UsersOverviewSubscriptionRequested>(_onSubscriptionRequested);
    on<UsersOverviewUserCompletionToggled>(_onUserCompletionToggled);
    on<UsersOverviewUserDeleted>(_onUserDeleted);
    on<UsersOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    on<UsersOverviewFilterChanged>(_onFilterChanged);
  }

  final UsersRepository _usersRepository;

  Future<void> _onSubscriptionRequested(
    UsersOverviewSubscriptionRequested event,
    Emitter<UsersOverviewState> emit,
  ) async {
    emit(state.copyWith(status: () => UsersOverviewStatus.loading));

    await emit.forEach<List<User>>(
      _usersRepository.getUsers(),
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
    final newUser = event.user.copyWith(role: event.role);
    await _usersRepository.saveUser(newUser);
  }

  Future<void> _onUserDeleted(
    UsersOverviewUserDeleted event,
    Emitter<UsersOverviewState> emit,
  ) async {
    emit(state.copyWith(lastDeletedUser: () => event.user));
    await _usersRepository.deleteUser(event.user.id);
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
    await _usersRepository.saveUser(user);
  }

  void _onFilterChanged(
    UsersOverviewFilterChanged event,
    Emitter<UsersOverviewState> emit,
  ) {
    emit(state.copyWith(filter: () => event.filter));
  }
}
