part of 'authentication_bloc.dart';

enum AuthenticationStatus { unauthenticated, basic, privileged, admin }

/// The current authentication state includes the status and the user
///
/// The user will be null if it is unauthenticated
final class AuthenticationState extends Equatable {
  const AuthenticationState._({
    this.status = AuthenticationStatus.unauthenticated,
    this.user,
  });

  /// The user is unathenticated
  const AuthenticationState.unauthenticated() : this._();

  /// The user has basic rights
  const AuthenticationState.basic(User user)
      : this._(status: AuthenticationStatus.basic, user: user);

  /// The user has privileged rights
  const AuthenticationState.privileged(User user)
      : this._(status: AuthenticationStatus.privileged, user: user);

  /// The user has admin rights
  const AuthenticationState.admin(User user)
      : this._(status: AuthenticationStatus.admin, user: user);

  /// The current authentication status
  final AuthenticationStatus status;

  /// The current user
  ///
  /// Will be null if the user is not authenticated
  final User? user;

  @override
  List<Object?> get props => [status, user];
}
