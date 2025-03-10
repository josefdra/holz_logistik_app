import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/location.dart';
import '../models/shipment.dart';

class User {
  String name = 'Test Nutzer';
  String username = 'TestN';
  int apiKey = 0;
  bool hasCredentials = false;

  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('apiKey')) {
      return;
    }

    name = prefs.getString('name')!;
    username = prefs.getString('id')!;
    apiKey = prefs.getInt('apiKey')!;
    hasCredentials = true;
  }
}

class DataProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final User _user = User();
  List<Location> _locations = [];
  List<Location> _archivedLocations = [];
  bool _isLoading = false;
  Map<int, List<Shipment>> _shipmentsByLocation = {};

  void printTables() {
    _db.printAllLocations();
    _db.printAllShipments();
  }

  void init() {
    _user.initializeUser();
  }

  List<Location> get locations => _locations;

  List<Location> get archivedLocations => _archivedLocations;

  bool get isLoading => _isLoading;

  User get user => _user;

  Future<void> loadArchivedLocations() async {
    try {
      final allShipments = await _db.getAllShipments();

      _shipmentsByLocation = {};
      for (var shipment in allShipments) {
        _shipmentsByLocation
            .putIfAbsent(shipment.locationId, () => [])
            .add(shipment);
      }

      await loadLocations();
      _updateArchivedStatus();
    } catch (e) {
      debugPrint('Error loading archived locations: $e');
    }
    notifyListeners();
  }

  List<Location> get locationsWithShipments {
    final Set<int> locationIdsWithShipments = {};

    for (var entry in _shipmentsByLocation.entries) {
      locationIdsWithShipments.add(entry.key);
    }

    return _locations
        .where((location) => locationIdsWithShipments.contains(location.id))
        .toList();
  }

  Map<String, dynamic> getShippedTotals(int locationId) {
    if (!_shipmentsByLocation.containsKey(locationId)) {
      return {'normalQuantity': 0.0, 'oversizeQuantity': 0.0, 'pieceCount': 0};
    }

    final shipments = _shipmentsByLocation[locationId]!.toList();

    double totalNormalQuantity = 0.0;
    double totalOversizeQuantity = 0.0;
    int totalPieceCount = 0;

    for (var shipment in shipments) {
      if (shipment.normalQuantity != null) {
        totalNormalQuantity += shipment.normalQuantity!;
      }
      if (shipment.oversizeQuantity != null) {
        totalOversizeQuantity += shipment.oversizeQuantity!;
      }

      totalPieceCount += shipment.pieceCount;
    }

    return {
      'normalQuantity': totalNormalQuantity,
      'oversizeQuantity': totalOversizeQuantity,
      'pieceCount': totalPieceCount,
    };
  }

  void _updateArchivedStatus() {
    _archivedLocations = [];
    for (var locationId in _shipmentsByLocation.keys) {
      var location =
      _locations.firstWhere((location) => location.id == locationId);
      if (location.id != -1 && _isLocationFullyShipped(location)) {
        _archivedLocations.add(location);
        _locations.removeWhere((location) => location.id == locationId);
      }
    }
  }

  bool _isLocationFullyShipped(Location location) {
    if (!_shipmentsByLocation.containsKey(location.id)) return false;

    final shipments = _shipmentsByLocation[location.id]!.toList();

    double totalNormalQuantityShipped = 0;
    int totalPieceCountShipped = 0;
    double totalOversizeShipped = 0;

    for (var shipment in shipments) {
      if (shipment.normalQuantity != null) {
        totalNormalQuantityShipped += shipment.normalQuantity!;
      }

      if (shipment.oversizeQuantity != null) {
        totalOversizeShipped += shipment.oversizeQuantity!;
      }

      totalPieceCountShipped += shipment.pieceCount;
    }

    return totalNormalQuantityShipped >= (location.normalQuantity ?? 0) &&
        (totalPieceCountShipped >= location.pieceCount) &&
        (location.oversizeQuantity == null ||
            totalOversizeShipped >= location.oversizeQuantity!);
  }

  Future<List<Shipment>> getShipmentHistory(int locationId) async {
    return await _db.getShipmentsByLocation(locationId);
  }

  Future<void> addShipment(Shipment shipment) async {
    try {
      await _db.insertShipment(shipment);

      final location = _locations
          .firstWhere((location) => location.id == shipment.locationId);

      double? newNormalQuantity = ((location.normalQuantity! -
          shipment.normalQuantity!) * 10).round() / 10;
      double? newOversizeQuantity = ((location.oversizeQuantity! -
          shipment.oversizeQuantity!) * 10).round() / 10;
      final newPieceCount = location.pieceCount - shipment.pieceCount;

      final updatedLocation = location.copyWith(
        normalQuantity: newNormalQuantity,
        oversizeQuantity: newOversizeQuantity,
        pieceCount: newPieceCount,
      );

      await updateLocation(updatedLocation);
      await loadArchivedLocations();
    } catch (e) {
      debugPrint('Error adding shipment: $e');
      rethrow;
    }
  }

  Future<void> undoShipment(Shipment shipment) async {
    try {
      await _db.deleteShipment(shipment.id);

      var location = _locations.firstWhere(
            (location) => location.id == shipment.locationId,
        orElse: () =>
            _archivedLocations.firstWhere(
                  (location) => location.id == shipment.locationId,
            ),
      );

      final updatedLocation = location.copyWith(
        normalQuantity:
        (location.normalQuantity ?? 0) + (shipment.normalQuantity ?? 0),
        pieceCount: location.pieceCount + shipment.pieceCount,
        oversizeQuantity: location.oversizeQuantity != null &&
            shipment.oversizeQuantity != null
            ? location.oversizeQuantity! + shipment.oversizeQuantity!
            : location.oversizeQuantity,
      );

      await updateLocation(updatedLocation);
      await loadArchivedLocations();
    } catch (e) {
      debugPrint('Error undoing shipment: $e');
      rethrow;
    }
  }

  Future<void> loadLocations() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _locations = await _db.getAllLocations();
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Location?> addLocation(Location location) async {
    try {
      final id = await _db.insertLocation(location);
      final savedLocation = await _db.getLocation(id);

      if (savedLocation != null) {
        savedLocation.id = id;
        _locations.add(savedLocation);
        notifyListeners();
      }

      return savedLocation;
    } catch (e) {
      debugPrint('Error adding location: $e');
      return null;
    }
  }

  Future<bool> updateLocation(Location location) async {
    try {
      await _db.updateLocation(location);

      if (location.id > 0) {
        final index = _locations.indexWhere((loc) => loc.id == location.id);
        if (index >= 0) {
          _locations[index] = location;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating location: $e');
      return false;
    }
  }

  Future<bool> deleteLocation(int id) async {
    try {
      final result = await _db.deleteLocation(id);
      if (result > 0) {
        _locations.removeWhere((location) => location.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting location: $e');
      return false;
    }
  }
}