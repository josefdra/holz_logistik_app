import 'package:flutter/material.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    required this.location,
    super.key,
    this.onTap,
  });

  final Location location;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 50,
        height: 50,
        child: LocationListTileAvatar(location: location),
      ),
      title: Text(location.partieNr),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menge: ${location.initialQuantity} fm'),
          Text('Davon ÜS: ${location.initialOversizeQuantity} fm'),
        ],
      ),
    );
  }
}
