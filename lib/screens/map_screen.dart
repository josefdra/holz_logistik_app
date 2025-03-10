import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:holz_logistik/providers/data_provider.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/widgets/location_details.dart';
import 'package:holz_logistik/config/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with AutomaticKeepAliveClientMixin {
  late final MapController _mapController;
  Timer? _positionUpdateTimer;
  bool _followPosition = true;
  bool _isAddingMarker = false;
  bool _showMarkerInfo = false;
  LatLng? _selectedPosition;
  LatLng? _currentPosition;
  double _currentAccuracy = 0;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    _mapController.mapEventStream.listen((event) {
      if (event is MapEventRotate) {
        _lastRotation = _mapController.rotation;
      } else if (event is MapEventMoveStart) {
        _followPosition = false;
      }
    });

    _initializeLocationAndMap();
  }

  @override
  void dispose() {
    _positionUpdateTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocationAndMap() async {
    try {
      await _initializeGeolocator();
      if (!mounted) return;

      if (!_isInitialized && _currentPosition != null) {
        _mapController.move(_currentPosition!, 15.0);
        _isInitialized = true;
      }

      _startPositionUpdates();
    } catch (e) {
      debugPrint('Error initializing location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Abrufen des Standorts')),
        );
      }
    }
  }

  void _startPositionUpdates() {
    _positionUpdateTimer?.cancel();
    _positionUpdateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _updateCurrentLocation();
    });
  }

  Future<void> _updateCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      if(mounted) {
        setState(() {
          _currentAccuracy = position.accuracy;
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        if(_followPosition) {
          _mapController.move(_currentPosition!, _mapController.zoom);
        }
      }
    } catch(e) {
      debugPrint('Error updating current location: $e');
    }
  }

  Future<void> _initializeGeolocator() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Geolocator initialization error: $e');
      rethrow;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();

      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentAccuracy = position.accuracy;
          _followPosition = true;
        });
      }

      _mapController.move(_currentPosition!, _mapController.zoom);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      rethrow;
    }
  }

  void _resetMapRotation() {
    _mapController.rotate(0.0);
  }

  double _lastRotation = 0.0;

  void _stabilizeMapRotation() {
    double currentRotation = _mapController.rotation;

    if (currentRotation.abs() < 20.0) {
      _mapController.rotate(0.0);
    } else if ((currentRotation - _lastRotation).abs() < 10.0) {
      _mapController.rotate(_lastRotation);
    } else {
      _lastRotation = currentRotation;
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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<DataProvider>(
      builder: (context, dataProvider, _) {
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentPosition ?? const LatLng(Constants.defaultLatitude, Constants.defaultLongitude),
                zoom: Constants.defaultZoom,
                onTap: _handleMapTap,
                onMapEvent: (MapEvent event) {
                  if (event is MapEventRotateEnd) {
                    _stabilizeMapRotation();
                  }
                },
                rotationThreshold: 20.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.draexl_it.holz_logistik',
                ),
                CircleLayer(
                  circles: [
                    if (_currentPosition != null)
                      CircleMarker(
                        point: _currentPosition!,
                        radius: _currentAccuracy,
                        useRadiusInMeter: true,
                        color: Colors.blue.withAlpha(51),
                        borderColor: Colors.blue,
                        borderStrokeWidth: 2,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        point: _currentPosition!,
                        width: 20,
                        height: 20,
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    ...dataProvider.locations.map((location) => Marker(
                      width: 40.0,
                      height: 40.0,
                      point: LatLng(location.latitude, location.longitude),
                      builder: (context) => GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => LocationDetailsDialog(location: location),
                          );
                        },
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
                      ),
                    )),
                    if (_selectedPosition != null)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _selectedPosition!,
                        builder: (context) => const Icon(Icons.location_on, color: Colors.red),
                      ),
                  ],
                ),
                if (_showMarkerInfo)
                  MarkerLayer(
                    markers: dataProvider.locations.map((location) =>
                        Marker(
                          width: 120.0,
                          height: 40.0,
                          point: LatLng(location.latitude, location.longitude),
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(220),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(50),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              'Normal: ${location.normalQuantity ?? 0} fm\nÜS: ${location.oversizeQuantity ?? 0} fm',
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
                  // North orientation button
                  FloatingActionButton(
                    onPressed: _resetMapRotation,
                    heroTag: 'northButton',
                    child: const Icon(Icons.navigation),
                  ),
                  const SizedBox(height: 8),
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