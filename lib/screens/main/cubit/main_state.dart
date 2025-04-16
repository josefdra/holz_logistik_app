part of 'main_cubit.dart';

enum MainTab { locationList, map, notes, shipmentList, analytics }

final class MainState extends Equatable {
  const MainState({
    this.tab = MainTab.locationList,
  });

  final MainTab tab;

  @override
  List<Object> get props => [tab];
}
