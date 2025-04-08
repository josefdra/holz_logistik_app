import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/admin/user/user_list/user_list.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';

part 'user_list_event.dart';
part 'user_list_state.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  UserListBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserListState()) {
    on<UserListSubscriptionRequested>(_onSubscriptionRequested);
    on<UserListUserDeleted>(_onUserDeleted);
    on<UserListUndoDeletionRequested>(_onUndoDeletionRequested);
    on<UserListFilterChanged>(_onFilterChanged);
  }

  final UserRepository _userRepository;

  Future<void> _onSubscriptionRequested(
    UserListSubscriptionRequested event,
    Emitter<UserListState> emit,
  ) async {
    emit(state.copyWith(status: () => UserListStatus.loading));

    await emit.forEach<Map<String, User>>(
      _userRepository.users,
      onData: (users) => state.copyWith(
        status: () => UserListStatus.success,
        users: () => users.values.toList(),
      ),
      onError: (_, __) => state.copyWith(
        status: () => UserListStatus.failure,
      ),
    );
  }

  Future<void> _onUserDeleted(
    UserListUserDeleted event,
    Emitter<UserListState> emit,
  ) async {
    emit(state.copyWith(lastDeletedUser: () => event.user));
    await _userRepository.deleteUser(event.user.id);
  }

  Future<void> _onUndoDeletionRequested(
    UserListUndoDeletionRequested event,
    Emitter<UserListState> emit,
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
    UserListFilterChanged event,
    Emitter<UserListState> emit,
  ) {
    emit(state.copyWith(filter: () => event.filter));
  }
}
