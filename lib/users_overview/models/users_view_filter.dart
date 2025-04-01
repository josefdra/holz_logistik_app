import 'package:users_repository/users_repository.dart';

enum UsersViewFilter { all, activeOnly, privilegedOnly }

extension UsersViewFilterX on UsersViewFilter {
  bool apply(User user) {
    switch (this) {
      case UsersViewFilter.all:
        return true;
      case UsersViewFilter.activeOnly:
        return !user.isPrivileged;
      case UsersViewFilter.privilegedOnly:
        return user.isPrivileged;
    }
  }

  Iterable<User> applyAll(Iterable<User> users) {
    return users.where(apply);
  }
}
