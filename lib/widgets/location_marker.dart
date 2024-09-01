import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:latlong2/latlong.dart';

class LocationMarker extends Marker {
  LocationMarker({
    required Location location,
    required VoidCallback onTap,
  }) : super(
          width: 40.0,
          height: 40.0,
          point: LatLng(location.latitude, location.longitude),
          child: GestureDetector(
            onTap: onTap,
            child: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
          ),
        );
}
