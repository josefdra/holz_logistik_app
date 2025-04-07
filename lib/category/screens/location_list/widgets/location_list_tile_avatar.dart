import 'dart:io';

import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/repository/location_repository.dart';

class LocationListTileAvatar extends StatelessWidget {
  const LocationListTileAvatar({
    required this.location,
    super.key,
  });

  final Location location;

  @override
  Widget build(BuildContext context) {
    return location.photos.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(location.photos.first.localPhotoUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildLetterAvatar(context),
            ),
          )
        : _buildLetterAvatar(context);
  }

  Widget _buildLetterAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(51),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        location.sawmills.isNotEmpty
            ? location.sawmills.first.name[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
