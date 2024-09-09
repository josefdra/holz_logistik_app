import 'package:flutter/material.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/services/location_service.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:provider/provider.dart';

class LocationList extends StatefulWidget {
  const LocationList({Key? key}) : super(key: key);

  @override
  State<LocationList> createState() => _LocationListState();
}

class _LocationListState extends State<LocationList> {
  void _showSnackBar(String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    }
  }

  void _showUpdateForm(BuildContext context, Location location,
      LocationService locationService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LocationForm(
          initialLocation: location,
          onSave: (updatedLocation) {
            Navigator.pop(context);

            locationService.updateLocation(updatedLocation).then((_) {
              _showSnackBar('Standort erfolgreich aktualisiert');
            }).catchError((error) {
              _showSnackBar('Fehler beim Aktualisieren des Standorts: $error');
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        return FutureBuilder<List<Location>>(
          future: locationService.getLocations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Keine Standorte gefunden'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final location = snapshot.data![index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text(location.additionalInfo),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          _showUpdateForm(context, location, locationService),
                    ),
                    onTap: () {
                      // Navigate to location detail page
                      // TODO: Implement location detail page
                    },
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
