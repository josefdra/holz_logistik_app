import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/services/location_service.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:holz_logistik/widgets/location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../widgets/location_details.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Location> _locations = [];
  bool _isLoading = true;
  bool _isAddingMarker = false;
  LatLng? _selectedPosition;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    try {
      final locations = await locationService.getLocations();
      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading locations: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations')),
      );
    }
  }

  void _toggleAddMarkerMode() {
    setState(() {
      _isAddingMarker = !_isAddingMarker;
      _selectedPosition = null;
    });
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    if (_isAddingMarker) {
      setState(() {
        _selectedPosition = point;
      });
    }
  }

  void _showLocationForm() {
    if (_selectedPosition != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return LocationForm(
            onSave: (Location location) async {
              final locationService =
                  Provider.of<LocationService>(context, listen: false);
              try {
                final newLocation = await locationService.addLocation(location);
                setState(() {
                  _locations.add(newLocation);
                  _isAddingMarker = false;
                  _selectedPosition = null;
                });
                Navigator.pop(context); // Close the form
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location added successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to add location: ${e.toString()}')),
                );
              }
            },
            initialPosition: _selectedPosition!,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(51.1657, 10.4515),
                  initialZoom: 6.0,
                  onTap: _handleMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      ..._locations.map((location) => LocationMarker(
                            location: location,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return LocationDetailsDialog(
                                      location: location);
                                },
                              );
                            },
                          )),
                      if (_selectedPosition != null)
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
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: _isAddingMarker
                      ? _showLocationForm
                      : _toggleAddMarkerMode,
                  child:
                      Icon(_isAddingMarker ? Icons.check : Icons.add_location),
                  tooltip: _isAddingMarker ? 'Add Location' : 'Add Marker',
                ),
              ),
            ],
          );
  }
}
