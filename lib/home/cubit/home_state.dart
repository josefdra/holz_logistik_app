part of 'home_cubit.dart';

enum HomeTab { users, stats }

final class HomeState extends Equatable {
  const HomeState({
    this.tab = HomeTab.users,
  });

  final HomeTab tab;

  @override
  List<Object> get props => [tab];
}
