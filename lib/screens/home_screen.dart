import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/providers/data_provider.dart';
import 'package:holz_logistik/widgets/location_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final locations = dataProvider.locations;

        if (locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Keine Standorte gefunden'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await dataProvider.loadLocations();
                    if (context.mounted) {
                      // await context.read<SyncProvider>().sync();
                    }
                  },
                  child: const Text('Neu laden'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (context.mounted) {
              // await context.read<SyncProvider>().sync();
            }
            return dataProvider.loadLocations();
          },
          child: ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return LocationListItem(location: location);
            },
          ),
        );
      },
    );
  }
}

class LocationListItem extends StatelessWidget {
  final Location location;

  const LocationListItem({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => LocationDetailsDialog(location: location),
          );
        },
        leading: SizedBox(
          width: 50,
          height: 50,
          child: location.photoUrls!.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(location.photoUrls!.first),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildLetterAvatar(context),
                  ),
                )
              : _buildLetterAvatar(context),
        ),
        title: Text(location.partieNr),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Normal: ${location.normalQuantity ?? 0} fm'),
            Text('ÜS: ${location.oversizeQuantity ?? 0} fm'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withAlpha(51),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        location.sawmill!.isNotEmpty ? location.sawmill![0].toUpperCase() : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
              context.read<DataProvider>().deleteLocation(location.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }
}
