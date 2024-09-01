import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:latlong2/latlong.dart';

class AddLocation extends StatefulWidget {
  final Function(Location) onLocationAdded;
  final VoidCallback onCancel;

  const AddLocation({
    Key? key,
    required this.onLocationAdded,
    required this.onCancel,
  }) : super(key: key);

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  LatLng? _selectedPosition;

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedPosition = point;
    });
  }

  void _showLocationForm() {
    if (_selectedPosition != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return LocationForm(
            onSave: widget.onLocationAdded,
            initialPosition: _selectedPosition!,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(51.1657, 10.4515),
            initialZoom: 6.0,
            onTap: _handleMapTap,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            if (_selectedPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40.0,
                    height: 40.0,
                    point: _selectedPosition!,
                    child: Icon(Icons.location_on, color: Colors.red),
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          child: FloatingActionButton(
            onPressed: widget.onCancel,
            child: Icon(Icons.close),
            tooltip: 'Cancel',
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _selectedPosition != null ? _showLocationForm : null,
            child: Icon(Icons.check),
            tooltip: 'Add Location',
          ),
        ),
      ],
    );
  }
}
