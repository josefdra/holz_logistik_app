import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  LatLng? _currentPosition;
  double _currentAccuracy = 0;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _initializeGeolocator();
  }

  Future<void> _initializeGeolocator() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    await _getCurrentLocation();
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _currentAccuracy = position.accuracy;
      });
      _mapController.move(_currentPosition!, 15);
    } catch (e) {
      print('Error getting current location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get current location')),
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
                Navigator.pop(context);
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

  void _cancelAddMarkerMode() {
    setState(() {
      _isAddingMarker = false;
      _selectedPosition = null;
    });
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
                  initialCenter: _currentPosition ?? LatLng(47.9831, 11.9050),
                  initialZoom: 10.0,
                  onTap: _handleMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  CircleLayer(
                    circles: [
                      if (_currentPosition != null)
                        CircleMarker(
                          point: _currentPosition!,
                          radius: _currentAccuracy,
                          useRadiusInMeter: true,
                          color: Colors.blue.withOpacity(0.2),
                          borderColor: Colors.blue,
                          borderStrokeWidth: 2,
                        ),
                    ],
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
                      if (_currentPosition != null)
                        Marker(
                          width: 20.0,
                          height: 20.0,
                          point: _currentPosition!,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _getCurrentLocation,
                      child: Icon(Icons.my_location),
                      heroTag: 'locationButton',
                    ),
                    SizedBox(height: 10),
                    if (_isAddingMarker)
                      FloatingActionButton(
                        onPressed: _cancelAddMarkerMode,
                        child: Icon(Icons.close),
                        tooltip: 'Cancel Add Marker',
                        heroTag: 'cancelAddMarkerButton',
                      ),
                    if (_isAddingMarker) SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: _isAddingMarker
                          ? _showLocationForm
                          : _toggleAddMarkerMode,
                      child: Icon(
                          _isAddingMarker ? Icons.check : Icons.add_location),
                      tooltip: _isAddingMarker ? 'Add Location' : 'Add Marker',
                      heroTag: 'addMarkerButton',
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
