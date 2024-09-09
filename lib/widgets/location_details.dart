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
  State<LocationDetailsDialog> createState() => _LocationDetailsDialogState();
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
          onSave: (updatedLocation) {
            final locationService =
                Provider.of<LocationService>(context, listen: false);

            Navigator.of(context).pop();

            locationService.updateLocation(updatedLocation).then((result) {
              if (mounted) {
                setState(() {
                  _currentLocation = result;
                });
                _showSnackBar('Aktualisieren des Standorts erfolgreich');
              }
            }).catchError((e) {
              _showSnackBar(
                  'Aktualisieren des Standorts fehlgeschlagen: ${e.toString()}');
            });
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    }
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
                    icon: const Icon(Icons.close),
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
                  const SizedBox(height: 8),
                  Text(
                    '${_currentLocation.latitude}, ${_currentLocation.longitude}',
                    style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline),
                  ),
                  const SizedBox(height: 16),
                  Text('Zusatzinfo: ${_currentLocation.additionalInfo}'),
                  const SizedBox(height: 8),
                  Text('Anfahrt: ${_currentLocation.access}'),
                  const SizedBox(height: 8),
                  Text('Partienummer: ${_currentLocation.partNumber}'),
                  const SizedBox(height: 8),
                  Text('Sägewerk: ${_currentLocation.sawmill}'),
                  const SizedBox(height: 8),
                  Text('Menge ÜS: ${_currentLocation.oversizeQuantity} fm'),
                  const SizedBox(height: 8),
                  Text('Menge: ${_currentLocation.quantity} fm'),
                  const SizedBox(height: 8),
                  Text('Stückzahl: ${_currentLocation.pieceCount}'),
                  const SizedBox(height: 16),
                  if (_currentLocation.photoUrls.isNotEmpty) ...[
                    Text('Photos:',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _currentLocation.photoUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Image.network(
                                _currentLocation.photoUrls[index],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showUpdateForm(context),
                      child: const Text('Standort aktualisieren'),
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
