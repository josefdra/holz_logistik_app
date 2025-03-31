// ignore_for_file: prefer_const_constructors
import 'package:test/test.dart';
import 'package:users_repository/users_repository.dart';

void main() {
  group('UsersRepository', () {
    test('can be instantiated', () {
      expect(UsersRepository(), isNotNull);
    });
  });
}
