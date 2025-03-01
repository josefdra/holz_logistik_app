import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../models/shipment.dart';
import '../providers/location_provider.dart';
import '../widgets/location_details.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, provider, child) {
        final archivedLocations = provider.archivedLocations;
        final locationsWithShipments = provider.locationsWithShipments;

        final allLocations = [...archivedLocations, ...locationsWithShipments];

        if (allLocations.isEmpty) {
          return const Center(
            child: Text('Keine Abfuhren vorhanden'),
          );
        }

        return ListView.builder(
          itemCount: allLocations.length,
          itemBuilder: (context, index) {
            final location = allLocations[index];
            final isArchived = archivedLocations.contains(location);
            return ArchivedLocationCard(
              location: location,
              isArchived: isArchived,
            );
          },
        );
      },
    );
  }
}

class ArchivedLocationCard extends StatefulWidget {
  final Location location;
  final bool isArchived;

  const ArchivedLocationCard({
    super.key,
    required this.location,
    required this.isArchived,
  });

  @override
  State<ArchivedLocationCard> createState() => _ArchivedLocationCardState();
}

class _ArchivedLocationCardState extends State<ArchivedLocationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final totals = context.read<LocationProvider>()
        .getShippedTotals(widget.location.id!);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(widget.location.name),
                ),
                if (widget.isArchived)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Archiviert',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sägewerk: ${widget.location.sawmill}'),
                if (!widget.isArchived) Text(
                  'Noch am Standort: ${widget.location.quantity ?? 0} fm, ${widget.location.pieceCount ?? 0} Stück',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Bereits abgefahren: ${totals['quantity']} fm, ${totals['pieceCount']} Stück',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => _showLocationDetails(context),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isExpanded)
            FutureBuilder<List<Shipment>>(
              future: context
                  .read<LocationProvider>()
                  .getShipmentHistory(widget.location.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Keine Abfuhren gefunden'),
                  );
                }

                final shipments = snapshot.data!;
                return Column(
                  children: [
                    const Divider(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: shipments.length,
                      itemBuilder: (context, index) {
                        final shipment = shipments[index];
                        return ShipmentListItem(
                          shipment: shipment,
                          onUndo: () => _handleUndoShipment(context, shipment),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showLocationDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LocationDetailsDialog(location: widget.location),
    );
  }

  Future<void> _handleUndoShipment(BuildContext context, Shipment shipment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abfuhr rückgängig machen'),
        content: const Text(
          'Möchten Sie diese Abfuhr wirklich rückgängig machen? '
              'Die Mengen werden zum Standort zurückgebucht.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Bestätigen'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<LocationProvider>().undoShipment(shipment);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abfuhr wurde rückgängig gemacht')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }
}

class ShipmentListItem extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onUndo;

  const ShipmentListItem({
    super.key,
    required this.shipment,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(shipment.timestamp),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('Menge: ${shipment.quantity} fm'),
                if (shipment.oversizeQuantity != null)
                  Text('Übermaß: ${shipment.oversizeQuantity} fm'),
                Text('Stückzahl: ${shipment.pieceCount}'),
              ],
            ),
          ),
          if (!shipment.isUndone)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: onUndo,
              tooltip: 'Rückgängig machen',
            ),
        ],
      ),
    );
  }
}