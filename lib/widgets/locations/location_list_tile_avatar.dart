import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class LocationListTileAvatar extends StatelessWidget {
  const LocationListTileAvatar({
    this.photo,
    super.key,
  });

  final Photo? photo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(51),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: photo != null
          ? Image.memory(photo!.photoFile)
          : Text(
              '?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
