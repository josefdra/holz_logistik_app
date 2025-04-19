import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/sort.dart';
import 'package:holz_logistik/models/users/users.dart';
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
    on<UserListFilterChanged>(_onFilterChanged);
  }

  final UserRepository _userRepository;
  final scrollController = ScrollController();

  Future<void> _onSubscriptionRequested(
    UserListSubscriptionRequested event,
    Emitter<UserListState> emit,
  ) async {
    emit(state.copyWith(status: UserListStatus.loading));

    await emit.forEach<Map<String, User>>(
      _userRepository.users,
      onData: (users) => state.copyWith(
        status: UserListStatus.success,
        users: users.values as List<User>?,
      ),
      onError: (_, __) => state.copyWith(
        status: UserListStatus.failure,
      ),
    );
  }

  Future<void> _onUserDeleted(
    UserListUserDeleted event,
    Emitter<UserListState> emit,
  ) async {
    emit(state.copyWith(lastDeletedUser: event.user));
    await _userRepository.deleteUser(event.user.id);
  }

  void _onFilterChanged(
    UserListFilterChanged event,
    Emitter<UserListState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
