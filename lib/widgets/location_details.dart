import 'package:flutter/material.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/services/location_service.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationDetailsDialog extends StatelessWidget {
  final Location location;

  const LocationDetailsDialog({Key? key, required this.location})
      : super(key: key);

  void _openInGoogleMaps(BuildContext context) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open Google Maps')),
      );
    }
  }

  void _showUpdateForm(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return LocationForm(
              initialLocation: location,
              onSave: (updatedLocation) async {
                final locationService =
                    Provider.of<LocationService>(context, listen: false);
                try {
                  await locationService.updateLocation(updatedLocation);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location updated successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to update location: ${e.toString()}')),
                  );
                }
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openInGoogleMaps(context),
                    child: Text(
                      '${location.latitude}, ${location.longitude}',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Description: ${location.description}'),
                  Text('Part Number: ${location.partNumber}'),
                  Text('Sawmill: ${location.sawmill}'),
                  Text('Quantity: ${location.quantity ?? 'N/A'}'),
                  Text('Piece Count: ${location.pieceCount ?? 'N/A'}'),
                  SizedBox(height: 16),
                  if (location.photoUrls.isNotEmpty) ...[
                    Text('Photos:',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: location.photoUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Image.network(location.photoUrls[index],
                                height: 100, width: 100, fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showUpdateForm(context),
                      child: Text('Update Location'),
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
