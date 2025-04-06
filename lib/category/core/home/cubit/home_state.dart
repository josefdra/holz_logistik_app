part of 'home_cubit.dart';

enum HomeTab { locationList, map, notes, shipmentList, analytics }

final class HomeState extends Equatable {
  const HomeState({
    this.tab = HomeTab.locationList,
  });

  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}
