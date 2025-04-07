import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/repository/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(AuthenticationState.unauthenticated()) {
    on<AuthenticationSubscriptionRequested>(_onSubscriptionRequested);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onSubscriptionRequested(
    AuthenticationSubscriptionRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    return emit.onEach(
      _authenticationRepository.authenticatedUser,
      onData: (user) async {
        if (user.name == '') {
          emit(AuthenticationState.unauthenticated());
        } else {
          switch (user.role) {
            case Role.basic:
              emit(AuthenticationState.basic(user));
            case Role.privileged:
              emit(AuthenticationState.privileged(user));
            case Role.admin:
              emit(AuthenticationState.admin(user));
          }
        }
      },
      onError: addError,
    );
  }
}
