import 'dart:math';
import 'package:holz_logistik_backend/repository/user_repository.dart';
import 'package:uuid/uuid.dart';

/// Class that generates random user data
class RandomUserGenerator {
  static final _random = Random();
  static final _firstNames = [
    'Anna',
    'Max',
    'Emma',
    'Paul',
    'Sophie',
    'Felix',
    'Mia',
    'Leon',
    'Hannah',
    'Lukas',
    'Lena',
    'Finn',
    'Lea',
    'Jonas',
    'Julia',
    'Tim',
    'Laura',
    'David',
    'Sarah',
    'Jan',
  ];
  static final _lastNames = [
    'Müller',
    'Schmidt',
    'Schneider',
    'Fischer',
    'Weber',
    'Meyer',
    'Wagner',
    'Becker',
    'Schulz',
    'Hoffmann',
    'Schäfer',
    'Koch',
    'Bauer',
    'Richter',
    'Klein',
    'Wolf',
    'Schröder',
    'Neumann',
    'Schwarz',
    'Zimmermann',
  ];

  /// Function that creates one random user
  static User generateRandomUser() {
    final firstName = _firstNames[_random.nextInt(_firstNames.length)];
    final lastName = _lastNames[_random.nextInt(_lastNames.length)];

    return User(
      id: const Uuid().v4(),
      role: Role.values[_random.nextInt(Role.values.length)],
      lastEdit: DateTime.now(),
      name: '$firstName $lastName',
    );
  }

  /// Function that creates a number of random users
  static List<User> generateRandomUsers(int count) {
    return List.generate(count, (_) => generateRandomUser());
  }
}
