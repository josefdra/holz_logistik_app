part of 'main_bloc.dart';

enum MainStatus { initial, loading, success, error }

enum MainTab { locationList, map, notes, shipmentList, analytics }

final class MainState extends Equatable {
  const MainState({
    this.status = MainStatus.initial,
    this.selectedTab = MainTab.locationList,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.isPrivileged = false,
    this.isReconnecting = false,
  });

  final MainStatus status;
  final MainTab selectedTab;
  final ConnectionStatus connectionStatus;
  final bool isPrivileged;
  final bool isReconnecting;

  MainState copyWith({
    MainStatus? status,
    MainTab? selectedTab,
    ConnectionStatus? connectionStatus,
    bool? isPrivileged,
    bool? isReconnecting,
  }) {
    return MainState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isPrivileged: isPrivileged ?? this.isPrivileged,
      isReconnecting: isReconnecting ?? this.isReconnecting,
    );
  }

  @override
  List<Object> get props =>
      [status, selectedTab, connectionStatus, isPrivileged, isReconnecting];
}
