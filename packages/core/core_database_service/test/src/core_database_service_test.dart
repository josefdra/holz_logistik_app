// ignore_for_file: prefer_const_constructors

import 'package:core_database_service/core_database_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoreDatabaseSerivce', () {
    test('can be instantiated', () {
      expect(CoreDatabase(), isNotNull);
    });
  });
}
