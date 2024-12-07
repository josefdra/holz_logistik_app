import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:holz_logistik/widgets/photo_gallery.dart';
import 'package:provider/provider.dart';

class LocationDetailsDialog extends StatelessWidget {
  final Location location;

  const LocationDetailsDialog({
    super.key,
    required this.location,
  });

  void _showEditForm(BuildContext context) {
    Navigator.of(context).pop(); // Close the details dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => LocationForm(initialLocation: location),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Standort löschen'),
        content: const Text('Möchten Sie diesen Standort wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () {
              context.read<LocationProvider>().deleteLocation(location.id!);
              Navigator.of(context).pop(); // Close confirmation dialog
              Navigator.of(context).pop(); // Close details dialog
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Location details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailItem(
                    icon: Icons.location_on,
                    title: 'Koordinaten',
                    value: '${location.latitude}, ${location.longitude}',
                  ),
                  _DetailItem(
                    icon: Icons.info_outline,
                    title: 'Zusatzinfo',
                    value: location.additionalInfo,
                  ),
                  _DetailItem(
                    icon: Icons.directions,
                    title: 'Anfahrt',
                    value: location.access,
                  ),
                  _DetailItem(
                    icon: Icons.numbers,
                    title: 'Partienummer',
                    value: location.partNumber,
                  ),
                  _DetailItem(
                    icon: Icons.business,
                    title: 'Sägewerk',
                    value: location.sawmill,
                  ),
                  _DetailItem(
                    icon: Icons.straighten,
                    title: 'Menge ÜS',
                    value: '${location.oversizeQuantity ?? 0} fm',
                  ),
                  _DetailItem(
                    icon: Icons.scale,
                    title: 'Menge',
                    value: '${location.quantity ?? 0} fm',
                  ),
                  _DetailItem(
                    icon: Icons.format_list_numbered,
                    title: 'Stückzahl',
                    value: '${location.pieceCount ?? 0}',
                  ),
                ],
              ),
            ),
            // Photos section
            if (location.photoUrls.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Fotos'),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: location.photoUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PhotoGallery(
                              photoUrls: location.photoUrls,
                              initialIndex: index,
                            ),
                          ));
                        },
                        child: Image.file(
                          File(location.photoUrls[index]),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showEditForm(context),
                    icon: const Icon(Icons.edit),
                    label: const Text('Bearbeiten'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Löschen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Location? location;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
    this.location,
  });

  Future<void> _copyCoordinates(BuildContext context, String coordinates) async {
    await Clipboard.setData(ClipboardData(text: coordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Koordinaten in die Zwischenablage kopiert'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCoordinates = title == 'Koordinaten';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (isCoordinates)
                  InkWell(
                    onTap: () => _copyCoordinates(context, value),  // Pass context here
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.directions,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  )
                else
                  Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}