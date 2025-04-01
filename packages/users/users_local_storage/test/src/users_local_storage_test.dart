// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:users_local_storage/users_local_storage.dart';

void main() {
  group('UsersLocalStorage', () {
    test('can be instantiated', () {
      expect(UsersLocalStorage(), isNotNull);
    });
  });
}
