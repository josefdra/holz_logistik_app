import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/utils/data_provider.dart';
import 'package:holz_logistik/utils/sync_service.dart';

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
  final _partieNrController = TextEditingController();
  final _contractController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  final _accessController = TextEditingController();
  final _sawmillController = TextEditingController();
  final _oversizeSawmillController = TextEditingController();
  final _normalQuantityController = TextEditingController();
  final _oversizeQuantityController = TextEditingController();
  final _pieceCountController = TextEditingController();
  List<int> _photoIds = [];
  List<String> _photoUrls = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      final location = widget.initialLocation!;
      _partieNrController.text = location.partieNr;
      _contractController.text = location.contract!;
      _additionalInfoController.text = location.additionalInfo!;
      _accessController.text = location.access!;
      _sawmillController.text = location.sawmill!;
      _oversizeSawmillController.text = location.oversizeSawmill!;
      _normalQuantityController.text = location.normalQuantity.toString();
      _oversizeQuantityController.text = location.oversizeQuantity.toString();
      _pieceCountController.text = location.pieceCount.toString();
      _photoIds = List.from(location.photoIds as Iterable);
      _photoUrls = List.from(location.photoUrls as Iterable);
    }
  }

  @override
  void dispose() {
    _partieNrController.dispose();
    _contractController.dispose();
    _additionalInfoController.dispose();
    _accessController.dispose();
    _sawmillController.dispose();
    _oversizeSawmillController.dispose();
    _normalQuantityController.dispose();
    _oversizeQuantityController.dispose();
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
          _photoIds.add(DateTime.now().microsecondsSinceEpoch);
          _photoUrls.add(image.path);
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
      _photoUrls.removeAt(index);
      _photoIds.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dataProvider = context.read<DataProvider>();
    final latitude = widget.initialPosition?.latitude ??
        widget.initialLocation?.latitude ??
        0.0;
    final longitude = widget.initialPosition?.longitude ??
        widget.initialLocation?.longitude ??
        0.0;
    final id =
        widget.initialLocation?.id ?? DateTime.now().microsecondsSinceEpoch;
    if (_normalQuantityController.text.isEmpty) {
      _normalQuantityController.text = '0.0';
    }
    if (_oversizeQuantityController.text.isEmpty) {
      _oversizeQuantityController.text = '0.0';
    }

    final location = Location(
        id: id,
        userId: SyncService.apiKey,
        lastEdited: DateTime.now(),
        latitude: latitude,
        longitude: longitude,
        partieNr: _partieNrController.text,
        contract: _contractController.text,
        additionalInfo: _additionalInfoController.text,
        access: _accessController.text,
        sawmill: _sawmillController.text,
        oversizeSawmill: _oversizeSawmillController.text,
        normalQuantity: double.tryParse(_normalQuantityController.text)!,
        oversizeQuantity: double.tryParse(_oversizeQuantityController.text)!,
        pieceCount: int.tryParse(_pieceCountController.text)!,
        photoIds: _photoIds,
        photoUrls: _photoUrls);

    try {
      if (widget.initialLocation != null) {
        await dataProvider.updateLocation(location);
      } else {
        await dataProvider.addLocation(location);
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
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _partieNrController,
                decoration: const InputDecoration(labelText: 'Partie Nummer *'),
                validator: (value) => value?.isEmpty ?? true
                    ? 'Bitte Partienummer eingeben'
                    : null,
              ),
              TextFormField(
                controller: _contractController,
                decoration: const InputDecoration(labelText: 'Vertrag'),
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
                controller: _sawmillController,
                decoration: const InputDecoration(labelText: 'Sägewerk'),
              ),
              TextFormField(
                controller: _oversizeSawmillController,
                decoration: const InputDecoration(labelText: 'Sägewerk ÜS'),
              ),
              TextFormField(
                controller: _normalQuantityController,
                decoration: const InputDecoration(labelText: 'Normal (fm)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _oversizeQuantityController,
                decoration: const InputDecoration(labelText: 'ÜS (fm)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: _pieceCountController,
                decoration: const InputDecoration(labelText: 'Stückzahl *'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bitte Stückzahl eingeben' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Foto hinzufügen'),
              ),
              if (_photoUrls.isNotEmpty) ...[
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
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.initialLocation != null
                        ? 'Aktualisieren'
                        : 'Hinzufügen'),
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

class PhotoPreview extends StatelessWidget {
  final String? photoUrl;
  final File? photoFile;
  final VoidCallback onRemove;

  const PhotoPreview({
    super.key,
    this.photoUrl,
    this.photoFile,
    required this.onRemove,
  }) : assert(photoUrl != null || photoFile != null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: photoUrl != null
                ? Image.file(
                    File(photoUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 40,
                    ),
                  )
                : Image.file(
                    photoFile!,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: -12,
          right: -12,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}
