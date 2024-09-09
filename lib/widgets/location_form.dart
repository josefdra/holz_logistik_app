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
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _additionalInfoController;
  late TextEditingController _accessController;
  late TextEditingController _partNumberController;
  late TextEditingController _sawmillController;
  late TextEditingController _oversizeQuantityController;
  late TextEditingController _quantityController;
  late TextEditingController _pieceCountController;
  List<String> _photoUrls = [];
  final List<File> _newPhotos = [];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialLocation?.name ?? '');
    _additionalInfoController = TextEditingController(
        text: widget.initialLocation?.additionalInfo ?? '');
    _accessController =
        TextEditingController(text: widget.initialLocation?.access ?? '');
    _partNumberController =
        TextEditingController(text: widget.initialLocation?.partNumber ?? '');
    _sawmillController =
        TextEditingController(text: widget.initialLocation?.sawmill ?? '');
    _oversizeQuantityController = TextEditingController(
        text: widget.initialLocation?.oversizeQuantity?.toString() ?? '');
    _quantityController = TextEditingController(
        text: widget.initialLocation?.quantity?.toString() ?? '');
    _pieceCountController = TextEditingController(
        text: widget.initialLocation?.pieceCount?.toString() ?? '');
    _photoUrls = widget.initialLocation?.photoUrls ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _additionalInfoController.dispose();
    _accessController.dispose();
    _partNumberController.dispose();
    _sawmillController.dispose();
    _oversizeQuantityController.dispose();
    _quantityController.dispose();
    _pieceCountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

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
        additionalInfo: _additionalInfoController.text,
        access: _accessController.text,
        partNumber: _partNumberController.text,
        sawmill: _sawmillController.text,
        oversizeQuantity: int.tryParse(_oversizeQuantityController.text),
        quantity: int.tryParse(_quantityController.text),
        pieceCount: int.tryParse(_pieceCountController.text),
        photoUrls: _photoUrls,
        newPhotos: _newPhotos,
      );
      widget.onSave(location);
      Navigator.of(context).pop(); // Close the form after submitting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte einen Namen eingeben';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(labelText: 'Zusatzinfo'),
            ),
            TextFormField(
              controller: _accessController,
              decoration: const InputDecoration(labelText: 'Anfahrt'),
            ),
            TextFormField(
              controller: _partNumberController,
              decoration: const InputDecoration(labelText: 'Partienummer'),
            ),
            TextFormField(
              controller: _sawmillController,
              decoration: const InputDecoration(labelText: 'Sägewerk'),
            ),
            TextFormField(
              controller: _oversizeQuantityController,
              decoration: const InputDecoration(labelText: 'Menge ÜS'),
            ),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Menge'),
            ),
            TextFormField(
              controller: _pieceCountController,
              decoration: const InputDecoration(labelText: 'Stückzahl'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Foto hinzufügen'),
            ),
            const SizedBox(height: 16),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.initialLocation == null
                      ? 'Standort hinzufügen'
                      : 'Standort aktualisieren'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(iconColor: Colors.grey),
                  child: const Text('Abbrechen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
