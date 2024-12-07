import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:holz_logistik/widgets/location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/widgets/location_details.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _isAddingMarker = false;
  bool _showMarkerInfo = false;
  LatLng? _selectedPosition;
  LatLng? _currentPosition;
  double _currentAccuracy = 0;

  @override
  void initState() {
    super.initState();
    _initializeGeolocator();
  }

  Future<void> _initializeGeolocator() async {
    try {
      debugPrint('Starting location initialization...');

      // First check if services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bitte aktivieren Sie die Standortdienste')),
          );
        }
        return;
      }

      // Check current permission status
      var permission = await Geolocator.checkPermission();
      debugPrint('Initial permission status: $permission');

      // If denied, request permission
      if (permission == LocationPermission.denied) {
        debugPrint('Requesting permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $permission');

        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Standortzugriff verweigert')),
            );
          }
          return;
        }
      }

      // Handle permanently denied
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Standortzugriff ist dauerhaft deaktiviert. Bitte in den Einstellungen aktivieren.'),
            ),
          );
        }
        return;
      }

      // If we got here, we should have permission
      debugPrint('Permission granted, getting location...');
      await _getCurrentLocation();
      debugPrint('Location initialization complete');

    } catch (e, stackTrace) {
      debugPrint('Error during location initialization: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Standortfehler: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      debugPrint('Getting current location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint('Position received: ${position.latitude}, ${position.longitude}');

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentAccuracy = position.accuracy;
        });

        _mapController.move(_currentPosition!, 12);
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      rethrow; // Let the parent method handle this error
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
            initialPosition: _selectedPosition!,
          );
        },
      ).then((_) {
        // Reset the add marker mode when the form is closed
        setState(() {
          _isAddingMarker = false;
          _selectedPosition = null;
        });
      });
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

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (locationProvider.locations.isNotEmpty) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }
        });
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(47.9831, 11.9050),
                initialZoom: 10.0,
                onTap: _handleMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                    ...locationProvider.locations.map((location) => LocationMarker(
                      location: location,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => LocationDetailsDialog(location: location),
                        );
                      },
                    )),
                    if (_selectedPosition != null)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _selectedPosition!,
                        child: const Icon(Icons.location_on, color: Colors.red),
                      ),
                  ],
                ),
                if (_showMarkerInfo)
                  MarkerLayer(
                    markers: locationProvider.locations.map((location) =>
                        Marker(
                          width: 120.0,
                          height: 40.0,
                          point: LatLng(location.latitude, location.longitude),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              'Menge: ${location.quantity ?? 0} fm\nÜS: ${location.oversizeQuantity ?? 0} fm',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                    ).toList(),
                  ),
              ],
            ),
            // FAB Controls
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: _getCurrentLocation,
                    heroTag: 'locationButton',
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 8),
                  if (_isAddingMarker)
                    FloatingActionButton(
                      onPressed: _cancelAddMarkerMode,
                      heroTag: 'cancelButton',
                      child: const Icon(Icons.close),
                    ),
                  if (_isAddingMarker) const SizedBox(height: 8),
                  FloatingActionButton(
                    onPressed: _isAddingMarker ? _showLocationForm : _toggleAddMarkerMode,
                    heroTag: 'addButton',
                    child: Icon(_isAddingMarker ? Icons.check : Icons.add_location),
                  ),
                ],
              ),
            ),
            // Info Toggle Button
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton(
                onPressed: _toggleMarkerInfo,
                heroTag: 'infoButton',
                child: Icon(_showMarkerInfo ? Icons.info_outline : Icons.info),
              ),
            ),
          ],
        );
      },
    );
  }
}