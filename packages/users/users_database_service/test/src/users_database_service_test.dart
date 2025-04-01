// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:users_database_service/users_database_service.dart';

void main() {
  group('UsersDatabaseService', () {
    test('can be instantiated', () {
      expect(UsersDatabaseService(), isNotNull);
    });
  });
}
