import 'package:holz_logistik_backend/api/user_api.dart';

enum UserListFilter {
  all,
  basicOnly,
  privilegedOnly,
  adminOnly,
  elevatedAccess
}

extension UserListFilterX on UserListFilter {
  bool apply(User user) {
    switch (this) {
      case UserListFilter.all:
        return true;
      case UserListFilter.basicOnly:
        return user.role == Role.basic;
      case UserListFilter.privilegedOnly:
        return user.role == Role.privileged;
      case UserListFilter.adminOnly:
        return user.role == Role.admin;
      case UserListFilter.elevatedAccess:
        return user.role == Role.privileged || user.role == Role.admin;
    }
  }

  Iterable<User> applyAll(Iterable<User> users) {
    return users.where(apply);
  }
}
