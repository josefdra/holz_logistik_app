import 'package:users_repository/users_repository.dart';

enum UsersViewFilter { all, activeOnly, privilegedOnly }

extension UsersViewFilterX on UsersViewFilter {
  bool apply(User user) {
    switch (this) {
      case UsersViewFilter.all:
        return true;
      case UsersViewFilter.activeOnly:
        return user.role == 0;
      case UsersViewFilter.privilegedOnly:
        return user.role == 1;
    }
  }

  Iterable<User> applyAll(Iterable<User> users) {
    return users.where(apply);
  }
}
