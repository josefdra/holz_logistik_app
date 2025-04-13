import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/location_list/location_list.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

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
      trailing: context
              .read<AuthenticationRepository>()
              .userHasElevatedPrivileges
          ? IconButton(
              onPressed: () => onDismissed?.call(DismissDirection.endToStart),
              icon: const Icon(Icons.delete),
            )
          : null,
    );
  }
}
