import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../models/location.dart';
import '../services/location_service.dart';
import '../widgets/bottom_navigation.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  List<Marker> markers = [];
  bool isAddingMarker = false;
  bool isLoading = true;
  Location? selectedLocation;
  List<File> _newPhotos = [];
  int currentPage = 1;
  bool hasMoreLocations = true;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    if (!hasMoreLocations || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final result = await LocationService.getLocations(page: currentPage);
      setState(() {
        markers.addAll(result.locations.map(_createMarker));
        currentPage++;
        hasMoreLocations = result.currentPage < result.totalPages;
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading locations: $e');
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load locations')),
      );
    }
  }

  Marker _createMarker(Location location) {
    return Marker(
      point: LatLng(location.latitude ?? 0, location.longitude ?? 0),
      child: CustomMarker(
        location: location,
        onTap: () {
          setState(() {
            selectedLocation = location;
          });
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newPhotos.add(File(image.path));
      });
    }
  }

  void _addMarker(
      LatLng position,
      String name,
      String description,
      String partNumber,
      String sawmill,
      String quantity,
      String pieceCount) async {
    try {
      final newLocation = await LocationService.addLocation(
        Location(
          name: name,
          latitude: position.latitude,
          longitude: position.longitude,
          description: description,
          partNumber: partNumber,
          sawmill: sawmill,
          quantity: quantity,
          pieceCount: int.tryParse(pieceCount),
          newPhotos: _newPhotos,
        ),
      );
      setState(() {
        markers.add(_createMarker(newLocation));
        isAddingMarker = false;
        _newPhotos.clear();
      });
    } catch (e) {
      print('Error adding marker: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add marker')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Holz Logistik'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(51.1657, 10.4515),
                    initialZoom: 6.0,
                    onPositionChanged: (_, __) {
                      if (mapController.camera.zoom > 10) {
                        _loadLocations();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                if (isAddingMarker)
                  Center(
                    child: Icon(Icons.add, color: Colors.red, size: 36),
                  ),
                if (isAddingMarker)
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: FloatingActionButton(
                      heroTag: 'cancelButton',
                      onPressed: _cancelAddMarker,
                      child: Icon(Icons.close),
                      backgroundColor: Colors.red,
                    ),
                  ),
                if (isAddingMarker)
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton(
                      heroTag: 'confirmButton',
                      onPressed: _showMarkerDialog,
                      child: Icon(Icons.check),
                      backgroundColor: Colors.green,
                    ),
                  ),
                if (selectedLocation != null)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: MarkerInfoWindow(
                      location: selectedLocation!,
                      onClose: () {
                        setState(() {
                          selectedLocation = null;
                        });
                      },
                    ),
                  ),
                if (isLoadingMore)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
      floatingActionButton: isAddingMarker
          ? null
          : FloatingActionButton(
              onPressed: _startAddMarker,
              child: Icon(Icons.add_location),
            ),
      bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }

  void _startAddMarker() {
    setState(() {
      isAddingMarker = true;
    });
  }

  void _cancelAddMarker() {
    setState(() {
      isAddingMarker = false;
    });
  }

  void _showMarkerDialog() {
    final currentCenter = mapController.camera.center;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _MarkerInputForm(
          onSave: (name, description, partNumber, sawmill, quantity, pieceCount,
              photos) {
            _addMarker(currentCenter, name, description, partNumber, sawmill,
                quantity, pieceCount);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class CustomMarker extends StatelessWidget {
  final Location location;
  final VoidCallback onTap;

  CustomMarker({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(Icons.location_on, color: Colors.red, size: 40),
    );
  }
}

class MarkerInfoWindow extends StatelessWidget {
  final Location location;
  final VoidCallback onClose;

  MarkerInfoWindow({required this.location, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(location.name),
          Text(location.description),
          ElevatedButton(
            onPressed: onClose,
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MarkerInputForm extends StatefulWidget {
  final Function(String, String, String, String, String, String, List<File>)
      onSave;

  _MarkerInputForm({required this.onSave});

  @override
  _MarkerInputFormState createState() => _MarkerInputFormState();
}

class _MarkerInputFormState extends State<_MarkerInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _sawmillController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pieceCountController = TextEditingController();
  List<File> _photos = [];

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _partNumberController,
              decoration: InputDecoration(labelText: 'Part Number'),
            ),
            TextFormField(
              controller: _sawmillController,
              decoration: InputDecoration(labelText: 'Sawmill'),
            ),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _pieceCountController,
              decoration: InputDecoration(labelText: 'Piece Count'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Add Photo'),
            ),
            SizedBox(height: 10),
            Text('${_photos.length} photos selected'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Add Marker'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave(
                    _nameController.text,
                    _descriptionController.text,
                    _partNumberController.text,
                    _sawmillController.text,
                    _quantityController.text,
                    _pieceCountController.text,
                    _photos,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _partNumberController.dispose();
    _sawmillController.dispose();
    _quantityController.dispose();
    _pieceCountController.dispose();
    super.dispose();
  }
}
