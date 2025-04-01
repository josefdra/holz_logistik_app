import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:users_repository/users_repository.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required UsersRepository usersRepository,
  })  : _usersRepository = usersRepository,
        super(const StatsState()) {
    on<StatsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final UsersRepository _usersRepository;

  Future<void> _onSubscriptionRequested(
    StatsSubscriptionRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatsStatus.loading));

    await emit.forEach<List<User>>(
      _usersRepository.getUsers(),
      onData: (users) => state.copyWith(
        status: StatsStatus.success,
        privilegedUsers: users.where((user) => user.role == 1).length,
        activeUsers: users.where((user) => user.role == 0).length,
      ),
      onError: (_, __) => state.copyWith(status: StatsStatus.failure),
    );
  }
}
