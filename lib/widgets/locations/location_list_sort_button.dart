import 'package:flutter/material.dart';
import 'package:holz_logistik/models/locations/location_list_sort.dart';

class LocationListSortButton extends StatelessWidget {
  const LocationListSortButton({
    required this.activeSort,
    required this.onSelected,
    super.key,
  });

  final LocationListSort activeSort;
  final void Function(LocationListSort) onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<LocationListSort>(
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      initialValue: activeSort,
      onSelected: onSelected,
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: LocationListSort.partieNrUp,
            child: Text('PartieNr. ↑'),
          ),
          const PopupMenuItem(
            value: LocationListSort.partieNrDown,
            child: Text('PartieNr. ↓'),
          ),
          const PopupMenuItem(
            value: LocationListSort.dateUp,
            child: Text('Datum ↑'),
          ),
          const PopupMenuItem(
            value: LocationListSort.dateDown,
            child: Text('Datum ↓'),
          ),
        ];
      },
      icon: const Icon(Icons.filter_list_rounded),
    );
  }
}
