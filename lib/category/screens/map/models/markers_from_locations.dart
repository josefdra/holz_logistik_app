import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik_backend/api/api.dart';
import 'package:latlong2/latlong.dart';

List<Marker> markersFromLocations(List<Location> locations) {
  final markers = locations.map(
    (location) => Marker(
      point: LatLng(location.latitude, location.longitude),
      child: GestureDetector(),
    ),
  ).toList();

  return markers;
}
