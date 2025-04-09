import 'package:flutter/material.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/repository/location_repository.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    required this.location,
    super.key,
    this.onDismissed,
    this.onTap,
  });

  final Location location;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key('locationListTile_dismissible_${location.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete,
          color: Color(0xAAFFFFFF),
        ),
      ),
      child: ListTile(
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
        trailing: IconButton(
          onPressed: () => onDismissed?.call(DismissDirection.endToStart),
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
