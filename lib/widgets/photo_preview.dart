import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPreview extends StatelessWidget {
  final String? photoUrl;
  final File? photoFile;
  final VoidCallback onRemove;

  const PhotoPreview({
    super.key,
    this.photoUrl,
    this.photoFile,
    required this.onRemove,
  }) : assert(photoUrl != null || photoFile != null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: photoUrl != null
                ? Image.file(
              File(photoUrl!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 40,
              ),
            )
                : Image.file(
              photoFile!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -12,
          right: -12,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
            onPressed: onRemove,
          ),
        ),
      ],
    );
  }
}