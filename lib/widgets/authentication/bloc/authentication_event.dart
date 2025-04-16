part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

final class AuthenticationVerificationRequested extends AuthenticationEvent {
  const AuthenticationVerificationRequested(this.apiKey);

  final String apiKey;

  @override
  List<Object> get props => [apiKey];
}

final class AuthenticationSubscriptionRequested extends AuthenticationEvent {}
