import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holz_logistik/data/database_helper.dart';

import 'package:holz_logistik/data/models.dart';
import 'package:holz_logistik/data/sync_service.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String newText = newValue.text.replaceAll(',', '.');

    if (newText.isEmpty || double.tryParse(newText) != null) {
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    return oldValue;
  }
}

class ShipmentForm extends StatefulWidget {
  final Location location;
  final Shipment? shipment;

  const ShipmentForm({
    super.key,
    required this.location,
    this.shipment,
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

  List<Contract> _contracts = [];
  Contract? _selectedContract;
  String _searchText = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContracts();
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

  Future<void> _loadContracts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contracts = await DatabaseHelper.instance.getAllContracts();

      setState(() {
        _contracts = contracts;
        _isLoading = false;

        if (widget.shipment != null) {
          _selectedContract = _contracts.firstWhere(
            (c) => c.id == widget.shipment!.contractId,
            orElse: () => _contracts.first,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Verträge: $e')),
        );
      }
    }
  }

  List<Contract> get _filteredContracts {
    if (_searchText.isEmpty) {
      return _contracts;
    }

    return _contracts
        .where((contract) =>
            contract.name.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
  }

  String? _validateQuantity<T extends num>(
      String? value, T? maxQuantity, bool pieceCount) {
    if (pieceCount) {
      if (value == null || value.isEmpty) {
        return 'Dieses Feld ist erforderlich';
      }
    } else {
      if (value == null || value.isEmpty) {
        return null;
      }
    }

    final quantity = double.tryParse(value);
    if (maxQuantity != null && quantity! > maxQuantity) {
      return 'Wert kann nicht größer als $maxQuantity sein';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedContract == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wählen Sie einen Vertrag aus')),
      );
      return;
    }

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
        contractId: _selectedContract!.id,
        sawmill: _sawmillController.text,
        normalQuantity: double.tryParse(_normalQuantityController.text)!,
        oversizeQuantity: double.tryParse(_oversizeQuantityController.text)!,
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
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vertrag *',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Vertrag suchen...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _filteredContracts.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Keine Verträge gefunden'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredContracts.length,
                                itemBuilder: (context, index) {
                                  final contract = _filteredContracts[index];
                                  return RadioListTile<Contract>(
                                    title: Text(contract.name),
                                    subtitle: Text(
                                        '${contract.price} • ${contract.time}'),
                                    value: contract,
                                    groupValue: _selectedContract,
                                    onChanged: (Contract? value) {
                                      setState(() {
                                        _selectedContract = value;
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                      if (_selectedContract != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Ausgewählt: ${_selectedContract!.name}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
                    inputFormatters: [DecimalInputFormatter()],
                    validator: (value) => _validateQuantity(
                        value, widget.location.normalQuantity, false)),
                TextFormField(
                    controller: _oversizeQuantityController,
                    decoration: const InputDecoration(labelText: 'ÜS (fm)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [DecimalInputFormatter()],
                    validator: (value) => _validateQuantity(
                        value, widget.location.oversizeQuantity, false)),
                TextFormField(
                    controller: _pieceCountController,
                    decoration: const InputDecoration(labelText: 'Stückzahl *'),
                    keyboardType: TextInputType.number,
                    validator: (value) => _validateQuantity(
                        value, widget.location.pieceCount, true)),
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
