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
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Location> _locations = [];
  bool _isLoading = true;
  bool _isAddingMarker = false;
  bool _showMarkerInfo = false;
  LatLng? _selectedPosition;
  LatLng? _currentPosition;
  double _currentAccuracy = 0;

  @override
  void initState() {
    super.initState();
    _loadLocations();
    _initializeGeolocator();
  }

  Future<void> _loadLocations() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    try {
      final locations = await locationService.getLocations();
      if (mounted) {
        setState(() {
          _locations = locations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Laden der Standorte fehlgeschlagen');
      }
    }
  }

  Future<void> _initializeGeolocator() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Standort Service ist deaktiviert');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Keine Berechtigung um auf Standort zuzugreifen');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Standort-Zugriffs Erlaubnis ist dauerhaft deaktiviert');
    }

    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentAccuracy = position.accuracy;
        });
        _mapController.move(_currentPosition!, 12);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Laden der aktuellen Position fehlgeschlagen');
      }
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
            onSave: (Location location) => _saveLocation(location),
            initialPosition: _selectedPosition!,
          );
        },
      );
    }
  }

  Future<void> _saveLocation(Location location) async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    try {
      final newLocation = await locationService.addLocation(location);
      if (mounted) {
        setState(() {
          _locations.add(newLocation);
          _isAddingMarker = false;
          _selectedPosition = null;
        });
        Navigator.of(context).pop();
        _showSuccessSnackBar('Standort hinzugefügt');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
            'Fehler beim Hinzufügen des Standorts: ${e.toString()}');
      }
    }
  }

  void _cancelAddMarkerMode() {
    setState(() {
      _isAddingMarker = false;
      _selectedPosition = null;
    });
  }

  void _toggleMarkerInfo() {
    setState(() {
      _showMarkerInfo = !_showMarkerInfo;
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter:
                      _currentPosition ?? const LatLng(47.9831, 11.9050),
                  initialZoom: 10.0,
                  onTap: _handleMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
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
                          child:
                              const Icon(Icons.location_on, color: Colors.red),
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
                  if (_showMarkerInfo)
                    MarkerLayer(
                      markers: _locations
                          .map((location) => Marker(
                                width: 100.0,
                                height: 40.0,
                                point: LatLng(
                                    location.latitude, location.longitude),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  color: Colors.white,
                                  child: Text(
                                    'Qty: ${location.quantity}\nOversize: ${location.oversizeQuantity}',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ))
                          .toList(),
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
                      heroTag: 'locationButton',
                      child: const Icon(Icons.my_location),
                    ),
                    const SizedBox(height: 10),
                    if (_isAddingMarker)
                      FloatingActionButton(
                        onPressed: _cancelAddMarkerMode,
                        tooltip: 'Cancel Add Marker',
                        heroTag: 'cancelAddMarkerButton',
                        child: const Icon(Icons.close),
                      ),
                    if (_isAddingMarker) const SizedBox(height: 10),
                    FloatingActionButton(
                      onPressed: _isAddingMarker
                          ? _showLocationForm
                          : _toggleAddMarkerMode,
                      tooltip: _isAddingMarker ? 'Add Location' : 'Add Marker',
                      heroTag: 'addMarkerButton',
                      child: Icon(
                          _isAddingMarker ? Icons.check : Icons.add_location),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingActionButton(
                  onPressed: _toggleMarkerInfo,
                  tooltip: 'Toggle Marker Info',
                  heroTag: 'infoButton',
                  child: const Icon(Icons.info),
                ),
              ),
            ],
          );
  }
}
