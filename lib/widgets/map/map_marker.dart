import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';

class MapMarker {
  const MapMarker({
    required this.location,
    required this.sawmills,
    required this.contractName,
    required this.onTap,
    required this.infoMode,
  });

  final Location location;
  final Map<String, Sawmill> sawmills;
  final String contractName;
  final VoidCallback onTap;
  final bool infoMode;

  List<Marker> build() {
    final markerPoint = LatLng(location.latitude, location.longitude);
    final markerIcon = Stack(
      children: [
        Positioned(
          left: 0,
          top: 30,
          child: Icon(
            !location.started ? Icons.location_pin : Icons.location_off,
            color: Colors.black,
            size: 60,
          ),
        ),
        Positioned(
          left: 15,
          top: 42,
          child: Icon(
            !location.started ? Icons.location_pin : Icons.location_off,
            color: Colors.black,
            size: 30,
          ),
        ),
        Positioned(
          left: 5,
          top: 34,
          child: Icon(
            !location.started ? Icons.location_pin : Icons.location_off,
            color: colorFromString(contractName),
            size: 50,
          ),
        ),
      ],
    );

    final baseMarker = Marker(
      width: 60,
      height: 90,
      point: markerPoint,
      child: GestureDetector(
        onTap: onTap,
        child: markerIcon,
      ),
    );

    if (!infoMode) {
      return [baseMarker];
    } else {
      final sawmillNames = location.sawmillIds
          .map((id) => sawmills[id]?.name ?? 'Unbekannt')
          .join(', ');

      final oversizeSawmillNames = location.oversizeSawmillIds
          .map((id) => sawmills[id]?.name ?? 'Unbekannt')
          .join(', ');

      final showRegularSawmills = sawmillNames.isNotEmpty;
      final showOversizeSawmills = oversizeSawmillNames.isNotEmpty;

      const infoBoxWidth = 300.0;

      final infoBoxMarker = Marker(
        alignment: const Alignment(0, -2.2),
        width: infoBoxWidth,
        height: showRegularSawmills
            ? showOversizeSawmills
                ? 75
                : 58
            : 40,
        point: markerPoint,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorFromString(contractName),
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
                  Center(
                    child: Text(
                      'Menge: ${location.currentQuantity} fm, davon ÜS: '
                      '${location.currentOversizeQuantity} fm',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (showRegularSawmills)
                    Tooltip(
                      message: 'Sägewerke: $sawmillNames',
                      child: Center(
                        child: Text(
                          'Sägewerke: $sawmillNames',
                          style: const TextStyle(fontSize: 12),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (showOversizeSawmills)
                    Tooltip(
                      message: 'ÜS Sägewerke: $oversizeSawmillNames',
                      child: Center(
                        child: Text(
                          'ÜS Sägewerke: $oversizeSawmillNames',
                          style: const TextStyle(fontSize: 12),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      return [baseMarker, infoBoxMarker];
    }
  }
}
