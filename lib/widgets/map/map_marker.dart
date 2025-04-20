import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';

class MapMarker {
  const MapMarker({
    required this.location,
    required this.sawmills,
    required this.onTap,
    required this.infoMode,
  });

  final Location location;
  final Map<String, Sawmill> sawmills;
  final VoidCallback onTap;
  final bool infoMode;

  Marker buildMarker() {
    final markerIcon = Icon(
      !location.started ? Icons.location_pin : Icons.location_off,
      color: colorFromString(location.contractId),
      size: 50,
    );

    if (!infoMode) {
      return Marker(
        width: 50,
        height: 50,
        point: LatLng(location.latitude, location.longitude),
        child: GestureDetector(
          onTap: onTap,
          child: markerIcon,
        ),
      );
    } else {
      final sawmillNames = location.sawmillIds != null
          ? location.sawmillIds!
              .map((id) => sawmills[id]?.name ?? 'Unbekannt')
              .join(', ')
          : '';

      final oversizeSawmillNames = location.oversizeSawmillIds != null
          ? location.oversizeSawmillIds!
              .map((id) => sawmills[id]?.name ?? 'Unbekannt')
              .join(', ')
          : '';

      final showRegularSawmills = sawmillNames.isNotEmpty;
      final showOversizeSawmills = oversizeSawmillNames.isNotEmpty;

      const infoBoxWidth = 300.0;

      return Marker(
        width: infoBoxWidth,
        height: 200,
        point: LatLng(location.latitude, location.longitude),
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              child: GestureDetector(
                onTap: onTap,
                child: markerIcon,
              ),
            ),
            Positioned(
              bottom: 50,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorFromString(location.contractId),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    constraints: const BoxConstraints(
                      maxWidth: infoBoxWidth,
                      minWidth: 120,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Menge: ${location.currentQuantity} fm, davon ÜS: '
                          '${location.currentOversizeQuantity} fm',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        if (showRegularSawmills)
                          Tooltip(
                            message: 'Sägewerke: $sawmillNames',
                            child: Text(
                              '\nSägewerke: $sawmillNames',
                              style: const TextStyle(fontSize: 12),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                            ),
                          ),
                        if (showOversizeSawmills)
                          Tooltip(
                            message: 'ÜS Sägewerke: $oversizeSawmillNames',
                            child: Text(
                              '\nÜS Sägewerke: $oversizeSawmillNames',
                              style: const TextStyle(fontSize: 12),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
