import 'dart:io';

import 'package:flutter/material.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/widgets/photo_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class LocationForm extends StatefulWidget {
  final Function(Location) onSave;
  final Location? initialLocation;
  final LatLng? initialPosition;

  const LocationForm({
    Key? key,
    required this.onSave,
    this.initialLocation,
    this.initialPosition,
  }) : super(key: key);

  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _partNumberController;
  late TextEditingController _sawmillController;
  late TextEditingController _quantityController;
  late TextEditingController _pieceCountController;
  List<String> _photoUrls = [];
  List<File> _newPhotos = [];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialLocation?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.initialLocation?.description ?? '');
    _partNumberController =
        TextEditingController(text: widget.initialLocation?.partNumber ?? '');
    _sawmillController =
        TextEditingController(text: widget.initialLocation?.sawmill ?? '');
    _quantityController =
        TextEditingController(text: widget.initialLocation?.quantity ?? '');
    _pieceCountController = TextEditingController(
        text: widget.initialLocation?.pieceCount?.toString() ?? '');
    _photoUrls = widget.initialLocation?.photoUrls ?? [];
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

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newPhotos.add(File(image.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      if (index < _photoUrls.length) {
        _photoUrls.removeAt(index);
      } else {
        _newPhotos.removeAt(index - _photoUrls.length);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final location = Location(
        id: widget.initialLocation?.id,
        name: _nameController.text,
        latitude: widget.initialPosition?.latitude ??
            widget.initialLocation?.latitude ??
            0,
        longitude: widget.initialPosition?.longitude ??
            widget.initialLocation?.longitude ??
            0,
        description: _descriptionController.text,
        partNumber: _partNumberController.text,
        sawmill: _sawmillController.text,
        quantity: _quantityController.text,
        pieceCount: int.tryParse(_pieceCountController.text),
        photoUrls: _photoUrls,
        newPhotos: _newPhotos,
      );
      widget.onSave(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
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
            ),
            TextFormField(
              controller: _pieceCountController,
              decoration: InputDecoration(labelText: 'Piece Count'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Add Photo'),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._photoUrls.asMap().entries.map((entry) => PhotoPreview(
                      photoUrl: entry.value,
                      onRemove: () => _removePhoto(entry.key),
                    )),
                ..._newPhotos.asMap().entries.map((entry) => PhotoPreview(
                      photoFile: entry.value,
                      onRemove: () =>
                          _removePhoto(entry.key + _photoUrls.length),
                    )),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.initialLocation == null
                  ? 'Add Location'
                  : 'Update Location'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.initialLocation == null
                      ? 'Add Location'
                      : 'Update Location'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(iconColor: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
