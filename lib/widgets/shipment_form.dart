import 'package:flutter/material.dart';

import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/utils/sync_service.dart';

class ShipmentForm extends StatefulWidget {
  final Location location;

  const ShipmentForm({
    super.key,
    required this.location,
  });

  @override
  State<ShipmentForm> createState() => _ShipmentFormState();
}

class _ShipmentFormState extends State<ShipmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contractController;
  final _additionalInfoController = TextEditingController();
  final _sawmillController = TextEditingController();
  final _normalQuantityController = TextEditingController();
  final _oversizeQuantityController = TextEditingController();
  final _pieceCountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contractController = TextEditingController(text: widget.location.contract);
  }

  @override
  void dispose() {
    _contractController.dispose();
    _additionalInfoController.dispose();
    _sawmillController.dispose();
    _normalQuantityController.dispose();
    _oversizeQuantityController.dispose();
    _pieceCountController.dispose();
    super.dispose();
  }

  String? _validateQuantity<T extends num>(String? value, T? maxQuantity) {
    if (value == null || value.isEmpty) {
      return 'Dieses Feld ist erforderlich';
    }

    final quantity = double.tryParse(value);
    if (maxQuantity != null && quantity! > maxQuantity) {
      return 'Wert kann nicht größer als $maxQuantity sein';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final id = DateTime.now().microsecondsSinceEpoch;

    if (_normalQuantityController.text.isEmpty) {
      _normalQuantityController.text = '0.0';
    }
    if (_oversizeQuantityController.text.isEmpty) {
      _oversizeQuantityController.text = '0.0';
    }

    final shipment = Shipment(
        id: id,
        userId: SyncService.apiKey,
        locationId: widget.location.id,
        date: DateTime.now(),
        name: SyncService.name,
        contract: _contractController.text,
        additionalInfo: _additionalInfoController.text,
        sawmill: _sawmillController.text,
        normalQuantity: double.tryParse(_normalQuantityController.text),
        oversizeQuantity: double.tryParse(_oversizeQuantityController.text),
        pieceCount: int.parse(_pieceCountController.text));

    Navigator.of(context).pop(shipment);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Abfuhr',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Driver information display
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withAlpha(77),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fahrer: ',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              SyncService.name,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _contractController,
                  decoration: const InputDecoration(labelText: 'Vertrag *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Bitte Vertrag eingeben' : null,
                ),
                TextFormField(
                  controller: _additionalInfoController,
                  decoration: const InputDecoration(labelText: 'Zusatzinfo'),
                ),
                TextFormField(
                  controller: _sawmillController,
                  decoration: const InputDecoration(labelText: 'Sägewerk *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Bitte Sägewerk eingeben' : null,
                ),
                TextFormField(
                  controller: _normalQuantityController,
                  decoration: const InputDecoration(labelText: 'Normal (fm)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextFormField(
                  controller: _oversizeQuantityController,
                  decoration: const InputDecoration(labelText: 'ÜS (fm)'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                TextFormField(
                    controller: _pieceCountController,
                    decoration: const InputDecoration(labelText: 'Stückzahl *'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        _validateQuantity(value, widget.location.pieceCount)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Abbrechen'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Bestätigen'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
