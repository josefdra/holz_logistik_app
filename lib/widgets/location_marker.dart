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
      child: Stack(
        children: [
          const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
          if (location.quantity != null || location.oversizeQuantity != null)
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${location.quantity ?? 0}',  // Only show quantity, not the sum
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