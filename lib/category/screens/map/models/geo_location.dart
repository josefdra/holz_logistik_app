import 'dart:async';
import 'package:location/location.dart' as geo;

typedef LocationUpdateCallback = void Function(
  double latitude,
  double longitude,
);

class LocationService {
  final geo.Location _locationService = geo.Location();
  StreamSubscription<geo.LocationData>? _locationSubscription;

  Future<bool> initLocationService(
    LocationUpdateCallback onLocationUpdate,
  ) async {
    bool serviceEnabled;
    geo.PermissionStatus permissionGranted;

    serviceEnabled = await _locationService.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationService.requestService();
      if (!serviceEnabled) {
        // User denied enabling the service
        return false;
      }
    }

    permissionGranted = await _locationService.hasPermission();
    if (permissionGranted == geo.PermissionStatus.denied) {
      permissionGranted = await _locationService.requestPermission();
      if (permissionGranted != geo.PermissionStatus.granted) {
        // User denied permission
        return false;
      }
    }

    _locationSubscription = _locationService.onLocationChanged.listen(
      (geo.LocationData locationData) {
        if (locationData.latitude != null && locationData.longitude != null) {
          onLocationUpdate(locationData.latitude!, locationData.longitude!);
        }
      },
    );

    return true;
  }

  void dispose() {
    _locationSubscription?.cancel();
  }
}
