import 'package:users_repository/users_repository.dart';

enum UsersViewFilter { all, activeOnly, completedOnly }

extension UsersViewFilterX on UsersViewFilter {
  bool apply(User user) {
    switch (this) {
      case UsersViewFilter.all:
        return true;
      case UsersViewFilter.activeOnly:
        return !user.isCompleted;
      case UsersViewFilter.completedOnly:
        return user.isCompleted;
    }
  }

  Iterable<User> applyAll(Iterable<User> users) {
    return users.where(apply);
  }
}
