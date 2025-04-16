import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../location_list.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    required this.location,
    super.key,
    this.onDelete,
    this.onTap,
  });

  final Location location;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: context.read<AuthenticationRepository>().authenticatedUser,
      builder: (context, snapshot) {
        final privileged =
            snapshot.hasData && (snapshot.data!.role != Role.basic);

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
          trailing: privileged
              ? IconButton(
                  onPressed: () => onDelete?.call(),
                  icon: const Icon(Icons.delete),
                )
              : null,
        );
      },
    );
  }
}
