import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik/widgets/locations/location_widgets.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    required this.location,
    this.photo,
    super.key,
    this.onDelete,
    this.onTap,
  });

  final Location location;
  final Photo? photo;
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
          leading: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: colorFromString(location.contractId),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            width: 50,
            height: 50,
            child: LocationListTileAvatar(photo: photo),
          ),
          title: Text(location.partieNr),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menge: ${location.currentQuantity} fm'),
              Text('Davon ÜS: ${location.currentOversizeQuantity} fm'),
            ],
          ),
          trailing: privileged
              ? IconButton(
                  onPressed: () => onDelete?.call(),
                  icon: const Icon(Icons.delete_outline),
                )
              : null,
        );
      },
    );
  }
}
