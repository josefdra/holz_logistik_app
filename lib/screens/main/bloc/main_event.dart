part of 'main_bloc.dart';

sealed class MainEvent extends Equatable {
  const MainEvent();

  @override
  List<Object> get props => [];
}

final class MainSubscriptionRequested extends MainEvent {
  const MainSubscriptionRequested();
}

final class MainApiKeyChanged extends MainEvent {
  const MainApiKeyChanged();
}

final class MainTabChanged extends MainEvent {
  const MainTabChanged(this.tab);

  final MainTab tab;

  @override
  List<Object> get props => [tab];
}

final class MainConnectionChanged extends MainEvent {
  const MainConnectionChanged(this.connectionStatus);

  final ConnectionStatus connectionStatus;

  @override
  List<Object> get props => [connectionStatus];
}

final class MainConnectivityChanged extends MainEvent {
  const MainConnectivityChanged({required this.connectivity});

  final List<ConnectivityResult> connectivity;

  @override
  List<Object> get props => [connectivity];
}

final class MainConnectPressed extends MainEvent {
  const MainConnectPressed();
}
