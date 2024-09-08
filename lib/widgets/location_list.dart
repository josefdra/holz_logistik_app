import 'package:flutter/material.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/services/location_service.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:provider/provider.dart';

class LocationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocationService>(
      builder: (context, locationService, child) {
        return FutureBuilder<List<Location>>(
          future: locationService.getLocations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Keine Standorte gefunden'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final location = snapshot.data![index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text(location.additional_info),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return LocationForm(
                              initialLocation: location,
                              onSave: (updatedLocation) async {
                                await locationService
                                    .updateLocation(updatedLocation);
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
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
