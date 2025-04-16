part of 'authentication_bloc.dart';

enum AuthenticationStatus { unauthenticated, basic, privileged, admin }

/// The current authentication state includes the status and the user
///
/// The user will be null if it is unauthenticated
final class AuthenticationState extends Equatable {
  AuthenticationState._({
    this.status = AuthenticationStatus.unauthenticated,
    User? user,
  }) : user = user ?? User.empty();

  /// The user is unathenticated
  AuthenticationState.unauthenticated() : this._();

  /// The user has basic rights
  AuthenticationState.basic(User user)
      : this._(status: AuthenticationStatus.basic, user: user);

  /// The user has privileged rights
  AuthenticationState.privileged(User user)
      : this._(status: AuthenticationStatus.privileged, user: user);

  /// The user has admin rights
  AuthenticationState.admin(User user)
      : this._(status: AuthenticationStatus.admin, user: user);

  /// The current authentication status
  final AuthenticationStatus status;

  /// The current user
  ///
  /// Will be null if the user is not authenticated
  final User user;

  @override
  List<Object?> get props => [status, user];
}
