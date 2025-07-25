import 'package:flutter/material.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class ShipmentListTile extends StatelessWidget {
  ShipmentListTile({
    required this.shipment,
    required String userName,
    required this.sawmillName,
    required this.partieNr,
    required this.contractRepository,
    super.key,
    this.onDeleted,
  }) : userName = userName.split(' ');

  final Shipment shipment;
  final List<String> userName;
  final String sawmillName;
  final String partieNr;
  final ContractRepository contractRepository;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Contract>(
      future: contractRepository.getContractById(shipment.contractId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: SizedBox(
              width: 52,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            title: Text('Laden...'),
          );
        }

        if (snapshot.hasError) {
          return ListTile(
            leading: const SizedBox(width: 52),
            title: const Text('Fehler beim Laden der Verträge'),
            subtitle: Text('${snapshot.error}'),
          );
        }

        final contract = snapshot.data ?? Contract();

        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2,
                color: colorFromString(
                  contract.name,
                ),
              ),
              const SizedBox(width: 2),
              SizedBox(
                width: 70,
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${shipment.lastEdit.day}.${shipment.lastEdit.month}.',
                    ),
                    Text(userName[0]),
                    if (userName.length > 1) Text(userName[1]),
                  ],
                ),
              ),
            ],
          ),
          title: Text(partieNr),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sägewerk: $sawmillName'),
              Text('${shipment.quantity} fm, ÜS: ${shipment.oversizeQuantity} '
                  'fm, ${shipment.pieceCount} Stk'),
            ],
          ),
          trailing: SizedBox(
            width: 25,
            child: IconButton(
              onPressed: () => _showDeleteConfirmation(context),
              icon: const Icon(Icons.undo),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abfuhr löschen'),
          content: const Text('Diese Abfuhr sicher löschen?'),
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
                    onDeleted?.call();
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

class SmallShipmentListTile extends StatelessWidget {
  SmallShipmentListTile({
    required this.shipment,
    required String userName,
    required this.sawmillName,
    required this.contractRepository,
    super.key,
  }) : userName = userName.split(' ');

  final Shipment shipment;
  final List<String> userName;
  final String sawmillName;
  final ContractRepository contractRepository;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Contract>(
      future: contractRepository.getContractById(shipment.contractId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: SizedBox(
              width: 52,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            title: Text('Laden...'),
          );
        }

        if (snapshot.hasError) {
          return ListTile(
            leading: const SizedBox(width: 52),
            title: const Text('Fehler beim Laden der Verträge'),
            subtitle: Text('${snapshot.error}'),
          );
        }

        final contract = snapshot.data ?? Contract();

        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2,
                color: colorFromString(
                  contract.name,
                ),
              ),
              const SizedBox(width: 2),
              SizedBox(
                width: 50,
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${shipment.lastEdit.day}.${shipment.lastEdit.month}.',
                    ),
                    Text(userName[0]),
                    if (userName.length > 1) Text(userName[1]),
                  ],
                ),
              ),
            ],
          ),
          title: Text(sawmillName),
          subtitle:
              Text('${shipment.quantity} fm, ÜS: ${shipment.oversizeQuantity} '
                  'fm, ${shipment.pieceCount} Stk'),
        );
      },
    );
  }
}
