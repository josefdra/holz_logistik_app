import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];
  MapController mapController = MapController();
  bool isAddingMarker = false;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.2.109:3000/locations'));
      if (response.statusCode == 200) {
        final List<dynamic> locations = json.decode(response.body);
        setState(() {
          markers = locations
              .map((location) => Marker(
                    point: LatLng(location['latitude'], location['longitude']),
                    builder: (ctx) => GestureDetector(
                      onTap: () =>
                          _showLocationDetails(Location.fromJson(location)),
                      child: Icon(Icons.location_on, color: Colors.red),
                    ),
                  ))
              .toList();
        });
      } else {
        print('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Standortkarte')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(51.1657, 10.4515),
              zoom: 6.0,
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
              child: Icon(Icons.add, color: Colors.grey, size: 40),
            ),
          if (isAddingMarker)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _cancelAddMarker,
                    child: Text('Abbrechen'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: _confirmAddMarker,
                    child: Text('Bestätigen'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleAddMarker,
        child: Icon(isAddingMarker ? Icons.close : Icons.add_location),
      ),
    );
  }

  void _toggleAddMarker() {
    setState(() {
      isAddingMarker = !isAddingMarker;
    });
  }

  void _cancelAddMarker() {
    setState(() {
      isAddingMarker = false;
    });
  }

  void _confirmAddMarker() {
    final currentCenter = mapController.center;
    _showLocationInputDialog(currentCenter);
  }

  void _showLocationInputDialog(LatLng position) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationInputDialog(
          onSave: (location) {
            _saveNewLocation(location, position);
          },
        );
      },
    );
  }

  Future<void> _saveNewLocation(Location location, LatLng position) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://192.168.2.109:3000/locations'));
      request.fields['name'] = location.name;
      request.fields['latitude'] = position.latitude.toString();
      request.fields['longitude'] = position.longitude.toString();
      request.fields['description'] = location.description;
      request.fields['part_number'] = location.partNumber;
      request.fields['sawmill'] = location.sawmill;
      request.fields['quantity'] = location.quantity;
      request.fields['piece_count'] = location.pieceCount;

      for (var photo in location.photos) {
        var file = await http.MultipartFile.fromPath('photos', photo.path);
        request.files.add(file);
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var savedLocation = Location.fromJson(json.decode(responseData));
        setState(() {
          markers.add(Marker(
            point: position,
            builder: (ctx) => GestureDetector(
              onTap: () => _showLocationDetails(savedLocation),
              child: Icon(Icons.location_on, color: Colors.red),
            ),
          ));
          isAddingMarker = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Neuer Standort erfolgreich gespeichert')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern des neuen Standorts')),
        );
      }
    } catch (e) {
      print('Fehler beim Speichern des neuen Standorts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Netzwerkfehler beim Speichern des neuen Standorts')),
      );
    }
  }

  void _showLocationDetails(Location location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: LocationDetailsWidget(
            location: location,
            onDelete: () => _deleteLocation(location),
            onUpdate: (updatedLocation) => _updateLocation(updatedLocation),
          ),
        );
      },
    );
  }

  Future<void> _deleteLocation(Location location) async {
    try {
      final response = await http.delete(
          Uri.parse('http://192.168.2.109:3000/locations/${location.id}'));
      if (response.statusCode == 204) {
        setState(() {
          markers.removeWhere((marker) =>
              marker.point.latitude == location.latitude &&
              marker.point.longitude == location.longitude);
        });
        Navigator.of(context).pop(); // Close the details sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Standort erfolgreich gelöscht')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen des Standorts')),
        );
      }
    } catch (e) {
      print('Fehler beim Löschen des Standorts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Netzwerkfehler beim Löschen des Standorts')),
      );
    }
  }

  Future<void> _updateLocation(Location updatedLocation) async {
    try {
      var request = http.MultipartRequest(
          'PUT',
          Uri.parse(
              'http://192.168.2.109:3000/locations/${updatedLocation.id}'));
      request.fields['name'] = updatedLocation.name;
      request.fields['latitude'] = updatedLocation.latitude.toString();
      request.fields['longitude'] = updatedLocation.longitude.toString();
      request.fields['description'] = updatedLocation.description;
      request.fields['part_number'] = updatedLocation.partNumber;
      request.fields['sawmill'] = updatedLocation.sawmill;
      request.fields['quantity'] = updatedLocation.quantity;
      request.fields['piece_count'] = updatedLocation.pieceCount;

      for (var photo in updatedLocation.photos) {
        if (photo is File) {
          var file = await http.MultipartFile.fromPath('photos', photo.path);
          request.files.add(file);
        } else if (photo is String) {
          request.fields['existing_photos'] = photo;
        }
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var updatedLoc = Location.fromJson(json.decode(responseData));
        setState(() {
          int index = markers.indexWhere((marker) =>
              marker.point.latitude == updatedLocation.latitude &&
              marker.point.longitude == updatedLocation.longitude);
          if (index != -1) {
            markers[index] = Marker(
              point: LatLng(updatedLoc.latitude, updatedLoc.longitude),
              builder: (ctx) => GestureDetector(
                onTap: () => _showLocationDetails(updatedLoc),
                child: Icon(Icons.location_on, color: Colors.red),
              ),
            );
          }
        });
        Navigator.of(context).pop(); // Close the details sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Standort erfolgreich aktualisiert')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Aktualisieren des Standorts')),
        );
      }
    } catch (e) {
      print('Fehler beim Aktualisieren des Standorts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Netzwerkfehler beim Aktualisieren des Standorts')),
      );
    }
  }
}

class Location {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String partNumber;
  final String sawmill;
  final String quantity;
  final String pieceCount;
  final List<dynamic> photos;

  Location({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.partNumber,
    required this.sawmill,
    required this.quantity,
    required this.pieceCount,
    required this.photos,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'] ?? '',
      partNumber: json['part_number'] ?? '',
      sawmill: json['sawmill'] ?? '',
      quantity: json['quantity'] ?? '',
      pieceCount: json['piece_count'] ?? '',
      photos: json['photos'] ?? [],
    );
  }
}

class LocationInputDialog extends StatefulWidget {
  final Function(Location) onSave;

  LocationInputDialog({required this.onSave});

  @override
  _LocationInputDialogState createState() => _LocationInputDialogState();
}

class _LocationInputDialogState extends State<LocationInputDialog> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String description = '';
  String partNumber = '';
  String sawmill = '';
  String quantity = '';
  String pieceCount = '';
  List<File> photos = [];

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        photos.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Neuen Standort hinzufügen'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Bitte einen Namen eingeben' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Beschreibung'),
                maxLength: 500,
                onSaved: (value) => description = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Partienummer'),
                maxLength: 10,
                onSaved: (value) => partNumber = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Sägewerk'),
                maxLength: 100,
                onSaved: (value) => sawmill = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Menge'),
                maxLength: 50,
                onSaved: (value) => quantity = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Stückzahl'),
                maxLength: 20,
                onSaved: (value) => pieceCount = value!,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Foto hinzufügen'),
              ),
              SizedBox(height: 10),
              Text('${photos.length} Fotos ausgewählt'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Abbrechen'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text('Speichern'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave(Location(
                name: name,
                latitude:
                    0, // Diese werden später mit der tatsächlichen Position aktualisiert
                longitude: 0,
                description: description,
                partNumber: partNumber,
                sawmill: sawmill,
                quantity: quantity,
                pieceCount: pieceCount,
                photos: photos,
              ));
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

class LocationDetailsWidget extends StatefulWidget {
  final Location location;
  final Function onDelete;
  final Function(Location) onUpdate;

  LocationDetailsWidget(
      {required this.location, required this.onDelete, required this.onUpdate});

  @override
  _LocationDetailsWidgetState createState() => _LocationDetailsWidgetState();
}

class _LocationDetailsWidgetState extends State<LocationDetailsWidget> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController partNumberController;
  late TextEditingController sawmillController;
  late TextEditingController quantityController;
  late TextEditingController pieceCountController;
  List<dynamic> photos = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.location.name);
    descriptionController =
        TextEditingController(text: widget.location.description);
    partNumberController =
        TextEditingController(text: widget.location.partNumber);
    sawmillController = TextEditingController(text: widget.location.sawmill);
    quantityController = TextEditingController(text: widget.location.quantity);
    pieceCountController =
        TextEditingController(text: widget.location.pieceCount);
    photos = List.from(widget.location.photos);
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        photos.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Beschreibung'),
              maxLength: 500,
            ),
            TextField(
              controller: partNumberController,
              decoration: InputDecoration(labelText: 'Partienummer'),
              maxLength: 10,
            ),
            TextField(
              controller: sawmillController,
              decoration: InputDecoration(labelText: 'Sägewerk'),
              maxLength: 100,
            ),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'Menge'),
              maxLength: 50,
            ),
            TextField(
              controller: pieceCountController,
              decoration: InputDecoration(labelText: 'Stückzahl'),
              maxLength: 20,
            ),
            SizedBox(height: 20),
            Text('Fotos:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length + 1,
                itemBuilder: (context, index) {
                  if (index == photos.length) {
                    return InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.add_a_photo),
                      ),
                    );
                  }
                  return Container(
                    width: 100,
                    margin: EdgeInsets.only(right: 8),
                    child: photos[index] is File
                        ? Image.file(photos[index], fit: BoxFit.cover)
                        : Image.network(photos[index], fit: BoxFit.cover),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    widget.onUpdate(Location(
                      id: widget.location.id,
                      name: nameController.text,
                      latitude: widget.location.latitude,
                      longitude: widget.location.longitude,
                      description: descriptionController.text,
                      partNumber: partNumberController.text,
                      sawmill: sawmillController.text,
                      quantity: quantityController.text,
                      pieceCount: pieceCountController.text,
                      photos: photos,
                    ));
                  },
                  child: Text('Aktualisieren'),
                ),
                ElevatedButton(
                  onPressed: () => widget.onDelete(),
                  child: Text('Löschen'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    partNumberController.dispose();
    sawmillController.dispose();
    quantityController.dispose();
    pieceCountController.dispose();
    super.dispose();
  }
}
