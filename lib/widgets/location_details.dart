import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:holz_logistik/widgets/photo_gallery.dart';
import 'package:holz_logistik/widgets/shipment_form.dart';
import 'package:provider/provider.dart';

import '../models/shipment.dart';

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

  Future<void> _showShipmentForm(BuildContext context) async {
    final shipment = await showDialog<Shipment>(
      context: context,
      builder: (context) => ShipmentForm(location: location),
    );

    if (shipment != null && context.mounted) {
      try {
        await context.read<LocationProvider>().addShipment(shipment);
        Navigator.of(context).pop(); // Close the details dialog after successful shipment
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler beim Speichern der Abfuhr: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          if (location.sawmill.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              location.sawmill,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quantities and Shipment Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aktueller Bestand',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                _QuantityItem(
                                  label: 'Menge',
                                  value: '${location.quantity ?? 0} fm',
                                ),
                                if (location.oversizeQuantity != null &&
                                    location.oversizeQuantity! > 0)
                                  _QuantityItem(
                                    label: 'Übermaß',
                                    value: '${location.oversizeQuantity} fm',
                                  ),
                                _QuantityItem(
                                  label: 'Stückzahl',
                                  value: '${location.pieceCount ?? 0}',
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: IconButton.filled(
                              onPressed: () => _showShipmentForm(context),
                              icon: const Icon(Icons.local_shipping),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                minimumSize: const Size(48, 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Section
                    if (location.additionalInfo.isNotEmpty ||
                        location.access.isNotEmpty ||
                        location.partNumber.isNotEmpty) ...[
                      Text(
                        'Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (location.additionalInfo.isNotEmpty)
                        _InfoSection(
                          icon: Icons.info_outline,
                          title: 'Zusatzinfo',
                          content: location.additionalInfo,
                        ),
                      if (location.access.isNotEmpty)
                        _InfoSection(
                          icon: Icons.directions,
                          title: 'Anfahrt',
                          content: location.access,
                        ),
                      if (location.partNumber.isNotEmpty)
                        _InfoSection(
                          icon: Icons.numbers,
                          title: 'Partienummer',
                          content: location.partNumber,
                        ),
                    ],

                    // Coordinates Button
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: '${location.latitude}, ${location.longitude}',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Koordinaten kopiert'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on),
                      label: const Text('Koordinaten kopieren'),
                      style: TextButton.styleFrom(
                        minimumSize: const Size(0, 36),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Photos section
              if (location.photoUrls.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fotos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(location.photoUrls[index]),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action buttons
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditForm(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('Bearbeiten'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: const Icon(Icons.delete),
                        label: const Text('Löschen'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityItem extends StatelessWidget {
  final String label;
  final String value;

  const _QuantityItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(content),
          ],
        ),
      ),
    );
  }
}
