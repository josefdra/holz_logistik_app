import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/models/shipment.dart';

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
  final _oversizeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pieceCountController = TextEditingController();

  @override
  void dispose() {
    _oversizeController.dispose();
    _quantityController.dispose();
    _pieceCountController.dispose();
    super.dispose();
  }

  String? _validateQuantity(String? value, int? maxQuantity) {
    if (value == null || value.isEmpty) {
      return 'Dieses Feld ist erforderlich';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Bitte geben Sie eine gültige Zahl ein';
    }
    if (maxQuantity != null && quantity > maxQuantity) {
      return 'Wert kann nicht größer als $maxQuantity sein';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final shipment = Shipment(
      locationId: widget.location.id!,
      oversizeQuantity: int.tryParse(_oversizeController.text),
      quantity: int.parse(_quantityController.text),
      pieceCount: int.parse(_pieceCountController.text),
    );

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
                TextFormField(
                  controller: _oversizeController,
                  decoration: const InputDecoration(
                    labelText: 'Menge ÜS (fm)',
                    helperText: 'Optional',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value?.isEmpty ?? true) return null;
                    return _validateQuantity(value, widget.location.oversizeQuantity);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Menge (fm)',
                    helperText: 'Erforderlich',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateQuantity(value, widget.location.quantity),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pieceCountController,
                  decoration: const InputDecoration(
                    labelText: 'Stückzahl',
                    helperText: 'Erforderlich',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => _validateQuantity(value, widget.location.pieceCount),
                ),
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