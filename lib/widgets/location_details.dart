import 'package:flutter/material.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/services/location_service.dart';
import 'package:holz_logistik/widgets/location_form.dart';
import 'package:provider/provider.dart';

class LocationDetailsDialog extends StatefulWidget {
  final Location location;

  const LocationDetailsDialog({Key? key, required this.location})
      : super(key: key);

  @override
  _LocationDetailsDialogState createState() => _LocationDetailsDialogState();
}

class _LocationDetailsDialogState extends State<LocationDetailsDialog> {
  late Location _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.location;
  }

  void _showUpdateForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LocationForm(
          initialLocation: _currentLocation,
          onSave: (updatedLocation) async {
            final locationService =
                Provider.of<LocationService>(context, listen: false);
            try {
              final result =
                  await locationService.updateLocation(updatedLocation);
              setState(() {
                _currentLocation = result;
              });
              Navigator.of(context).pop(); // Close the form
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Aktualisieren des Standorts erfolgreich')),
              );
            } catch (e) {
              Navigator.of(context).pop(); // Close the form
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Aktualisieren des Standorts fehlgeschlagen: ${e.toString()}'),
                ),
              );
            }
          },
        );
      },
    );
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
                    'Details',
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
                  Text(_currentLocation.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8),
                  Text(
                    '${_currentLocation.latitude}, ${_currentLocation.longitude}',
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                  SizedBox(height: 16),
                  Text('${_currentLocation.description}'),
                  SizedBox(height: 8),
                  Text('Partienummer: ${_currentLocation.partNumber}'),
                  SizedBox(height: 8),
                  Text('Sägewerk: ${_currentLocation.sawmill}'),
                  SizedBox(height: 8),
                  Text('Menge: ${_currentLocation.quantity} fm'),
                  SizedBox(height: 8),
                  Text('Stückzahl: ${_currentLocation.pieceCount}'),
                  SizedBox(height: 16),
                  if (_currentLocation.photoUrls.isNotEmpty) ...[
                    Text('Photos:',
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentLocation.photoUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Image.network(
                                _currentLocation.photoUrls[index],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showUpdateForm(context),
                      child: Text('Standort aktualisieren'),
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
