import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/providers/location_provider.dart';
import 'package:holz_logistik/widgets/location_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final locations = locationProvider.locations;

        if (locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Keine Standorte gefunden'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => locationProvider.loadLocations(),
                  child: const Text('Neu laden'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => locationProvider.loadLocations(),
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
          child: location.photoUrls.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(location.photoUrls.first),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildLetterAvatar(context),
            ),
          )
              : _buildLetterAvatar(context),
        ),
        title: Text(location.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (location.sawmill.isNotEmpty)
              Text('Sägewerk: ${location.sawmill}'),
            Text('Menge: ${location.quantity ?? 0} fm'),
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        location.name.isNotEmpty ? location.name[0].toUpperCase() : '?',
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
              context.read<LocationProvider>().deleteLocation(location.id!);
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