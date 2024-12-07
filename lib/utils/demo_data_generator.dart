// Create a new file called lib/utils/demo_data_generator.dart

import 'dart:math';
import '../models/location.dart';

class DemoDataGenerator {
  static final Random _random = Random();
  static const List<String> _sawmills = [
    'Ilim Timber',
    'Vögele',
    'Pfeifer',
    'Hechenblaickner',
  ];

  // Define region boundaries (roughly Tegernsee to Raubling area)
  static const double minLat = 47.6500;
  static const double maxLat = 47.8800;
  static const double minLng = 11.7000;
  static const double maxLng = 12.1200;

  static String _generatePartNumber() {
    return '${_random.nextInt(900) + 100}-${_random.nextInt(900) + 100}';
  }

  static String _generateAccess() {
    final List<String> accessDescriptions = [
      'Zufahrt über Forstweg, ganzjährig befahrbar',
      'Nur bei trockenem Wetter befahrbar',
      'Zufahrt über befestigten Waldweg',
      'LKW-Wendeplatz vorhanden',
      'Schwieriger Zugang bei Nässe',
      'Gute Zufahrt, ausgebauter Weg',
      'Bergab, bei Nässe schwierig',
      'Zufahrt über private Straße, Anmeldung erforderlich',
    ];
    return accessDescriptions[_random.nextInt(accessDescriptions.length)];
  }

  static String _generateAdditionalInfo() {
    final List<String> infoOptions = [
      'Polter am Wegrand',
      'Stapel an mehreren Stellen',
      'Holz bereits vermessen',
      'Naturverjüngung beachten',
      'Mehrere Sortimente',
      'Sägequalität',
      'Stapel durchnummeriert',
      'Teilweise Käferholz',
    ];
    return infoOptions[_random.nextInt(infoOptions.length)];
  }

  static Location generateLocation() {
    // Generate random coordinates within the defined region
    final latitude = minLat + _random.nextDouble() * (maxLat - minLat);
    final longitude = minLng + _random.nextDouble() * (maxLng - minLng);

    // Generate realistic quantities
    final quantity = _random.nextInt(800) + 200; // 200-1000 fm
    final oversizeQuantity = _random.nextInt(50); // 0-50 fm
    final pieceCount = (quantity * (1.5 + _random.nextDouble())).round(); // roughly 1.5-2.5 pieces per fm

    return Location(
      name: 'Polter ${_generatePartNumber()}',
      latitude: latitude,
      longitude: longitude,
      additionalInfo: _generateAdditionalInfo(),
      access: _generateAccess(),
      partNumber: _generatePartNumber(),
      sawmill: _sawmills[_random.nextInt(_sawmills.length)],
      oversizeQuantity: oversizeQuantity,
      quantity: quantity,
      pieceCount: pieceCount,
      photoUrls: [],
    );
  }

  static List<Location> generateLocations(int count) {
    return List.generate(count, (index) => generateLocation());
  }
}