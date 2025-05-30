import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationListTile extends StatelessWidget {
  const LocationListTile({
    required this.location,
    required this.contractName,
    this.photo,
    super.key,
    this.onDelete,
    this.onTap,
  });

  final Location location;
  final String contractName;
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
            width: 2,
            color: colorFromString(
              contractName,
            ),
          ),
          title: Text(location.partieNr),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menge: ${location.currentQuantity} fm'),
              Text('Davon ÜS: ${location.currentOversizeQuantity} fm'),
            ],
          ),
          trailing: privileged && onDelete != null
              ? IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(Icons.delete_outline),
                )
              : null,
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Standort löschen'),
          content: const Text('Diesen Standort sicher löschen?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Abbrechen'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onDelete?.call();
                  },
                  child: const Text('Löschen'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
