part of 'main_bloc.dart';

enum MainStatus { initial, loading, success, error }

enum MainTab { locationList, map, notes, shipmentList, analytics }

final class MainState extends Equatable {
  const MainState({
    this.status = MainStatus.initial,
    this.selectedTab = MainTab.locationList,
    this.connectionStatus = ConnectionStatus.disconnected,
    this.isPrivileged = false,
  });

  final MainStatus status;
  final MainTab selectedTab;
  final ConnectionStatus connectionStatus;
  final bool isPrivileged;

  MainState copyWith({
    MainStatus? status,
    MainTab? selectedTab,
    ConnectionStatus? connectionStatus,
    bool? isPrivileged,
  }) {
    return MainState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isPrivileged: isPrivileged ?? this.isPrivileged,
    );
  }

  @override
  List<Object> get props =>
      [status, selectedTab, connectionStatus, isPrivileged];
}
