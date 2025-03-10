import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:latlong2/latlong.dart';

class LocationMarker {
  final Location location;
  final VoidCallback onTap;

  LocationMarker({
    required this.location,
    required this.onTap,
  });

  Marker build() {
    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 40.0,
      height: 40.0,
      builder: (context) => GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40.0,
            ),
            if (location.normalQuantity != null || location.oversizeQuantity != null)
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Text(
                    '${location.normalQuantity! + location.oversizeQuantity!}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}