import 'dart:io';
import 'package:flutter/material.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/widgets/photo_preview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class LocationForm extends StatefulWidget {
  final Location? initialLocation;
  final LatLng? initialPosition;

  const LocationForm({
    super.key,
    this.initialLocation,
    this.initialPosition,
  });

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _accessController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _sawmillController = TextEditingController();
  final _oversizeQuantityController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pieceCountController = TextEditingController();
  List<String> _photoUrls = [];
  final List<File> _newPhotos = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      final location = widget.initialLocation!;
      _nameController.text = location.name;
      _additionalInfoController.text = location.additionalInfo;
      _accessController.text = location.access;
      _partNumberController.text = location.partNumber;
      _sawmillController.text = location.sawmill;
      _oversizeQuantityController.text = location.oversizeQuantity?.toString() ?? '';
      _quantityController.text = location.quantity?.toString() ?? '';
      _pieceCountController.text = location.pieceCount?.toString() ?? '';
      _photoUrls = List.from(location.photoUrls);
    }
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
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _newPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fehler beim Laden des Fotos')),
        );
      }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final locationProvider = context.read<LocationProvider>();
    final latitude = widget.initialPosition?.latitude ??
        widget.initialLocation?.latitude ?? 0.0;
    final longitude = widget.initialPosition?.longitude ??
        widget.initialLocation?.longitude ?? 0.0;

    final location = Location(
      id: widget.initialLocation?.id,
      name: _nameController.text,
      latitude: latitude,
      longitude: longitude,
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

    try {
      if (widget.initialLocation != null) {
        await locationProvider.updateLocation(location);
      } else {
        await locationProvider.addLocation(location);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
    child: Form(
    key: _formKey,
    child: SingleChildScrollView(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(labelText: 'Name *'),
    validator: (value) =>
    value?.isEmpty ?? true ? 'Bitte einen Namen eingeben' : null,
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
    decoration: const InputDecoration(labelText: 'Menge ÜS (fm)'),
    keyboardType: TextInputType.number,
    ),
    TextFormField(
    controller: _quantityController,
    decoration: const InputDecoration(labelText: 'Menge (fm)'),
    keyboardType: TextInputType.number,
    ),
    TextFormField(
    controller: _pieceCountController,
    decoration: const InputDecoration(labelText: 'Stückzahl'),
    keyboardType: TextInputType.number,
    ),
    const SizedBox(height: 16),
    ElevatedButton.icon(
    onPressed: _pickImage,
    icon: const Icon(Icons.add_photo_alternate),
    label: const Text('Foto hinzufügen'),
    ),
    if (_photoUrls.isNotEmpty || _newPhotos.isNotEmpty) ...[
    const SizedBox(height: 16),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ..._photoUrls.asMap().entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PhotoPreview(
                  photoUrl: entry.value,
                  onRemove: () => _removePhoto(entry.key),
                ),
              ),
            ),
            ..._newPhotos.asMap().entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PhotoPreview(
                  photoFile: entry.value,
                  onRemove: () => _removePhoto(entry.key + _photoUrls.length),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _submit,
            child: Text(widget.initialLocation != null
                ? 'Aktualisieren'
                : 'Hinzufügen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
        ],
      ),
    ],
    ),
    ),
    ),
    );
  }
}