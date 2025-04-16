import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/shipment_form/bloc/shipment_form_bloc.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class ShipmentFormWidget extends StatelessWidget {
  const ShipmentFormWidget({
    required this.currentQuantity,
    required this.currentOversizeQuantity,
    required this.currentPieceCount,
    required this.location,
    required this.userId,
    super.key,
  });

  final double currentQuantity;
  final double currentOversizeQuantity;
  final int currentPieceCount;
  final Location location;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShipmentFormBloc(
        currentQuantity: currentQuantity,
        currentOversizeQuantity: currentOversizeQuantity,
        currentPieceCount: currentPieceCount,
        location: location,
        userId: userId,
        shipmentRepository: context.read<ShipmentRepository>(),
        locationRepository: context.read<LocationRepository>(),
      ),
      child: BlocListener<ShipmentFormBloc, ShipmentFormState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (current.status == ShipmentFormStatus.success),
        listener: (context, state) {
          Navigator.of(context).pop();
        },
        child: const ShipmentFormView(),
      ),
    );
  }
}

class ShipmentFormView extends StatelessWidget {
  const ShipmentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const _QuantityField(),
                const _OversizeQuantityField(),
                const _PieceCountField(),
                const _SawmillField(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filled(
                      onPressed: () => context
                          .read<ShipmentFormBloc>()
                          .add(const ShipmentFormCanceled()),
                      icon: const Icon(Icons.cancel),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => context
                          .read<ShipmentFormBloc>()
                          .add(const ShipmentFormSubmitted()),
                      icon: const Icon(Icons.check_circle),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size(48, 48),
                      ),
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

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(',', '.');

    if (newText.isEmpty || double.tryParse(newText) != null) {
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    return oldValue;
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final error = state.validationErrors['quantity'];

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Verfügbare Menge: ${state.currentQuantity}'),
        ),
        TextFormField(
          key: const Key('shipmentForm_quantity_textFormField'),
          initialValue: '',
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: 'Menge (fm)',
            errorText: error,
            border: const OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 20,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            DecimalInputFormatter(),
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              context
                  .read<ShipmentFormBloc>()
                  .add(ShipmentFormQuantityUpdate(double.parse(value)));
            }
          },
        ),
      ],
    );
  }
}

class _OversizeQuantityField extends StatelessWidget {
  const _OversizeQuantityField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final error = state.validationErrors['oversizeQuantity'];

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Verfügbare Menge ÜS: ${state.currentOversizeQuantity}'),
        ),
        TextFormField(
          key: const Key('shipmentForm_oversizeQuantity_textFormField'),
          initialValue: '',
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: 'Davon ÜS',
            errorText: error,
            border: const OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          maxLength: 20,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            DecimalInputFormatter(),
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              context.read<ShipmentFormBloc>().add(
                    ShipmentFormOversizeQuantityUpdate(double.parse(value)),
                  );
            }
          },
        ),
      ],
    );
  }
}

class _PieceCountField extends StatelessWidget {
  const _PieceCountField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final error = state.validationErrors['pieceCount'];

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Verfügbare Stückzahl: ${state.currentPieceCount}'),
        ),
        TextFormField(
          key: const Key('shipmentForm_pieceCount_textFormField'),
          initialValue: '',
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: 'Stückzahl',
            errorText: error,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 20,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
            DecimalInputFormatter(),
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              context
                  .read<ShipmentFormBloc>()
                  .add(ShipmentFormPieceCountUpdate(int.parse(value)));
            }
          },
        ),
      ],
    );
  }
}

class _SawmillField extends StatelessWidget {
  const _SawmillField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final error = state.validationErrors['sawmill'];

    return StreamBuilder<List<Sawmill>>(
      stream: context.watch<SawmillRepository>().sawmills,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final sawmills = snapshot.data!;

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Sägewerk',
            enabled: !state.status.isLoadingOrSuccess,
            errorText: error,
            border: const OutlineInputBorder(),
          ),
          value: state.sawmillId.isNotEmpty ? state.sawmillId : null,
          items: sawmills.map((sawmill) {
            return DropdownMenuItem<String>(
              value: sawmill.id,
              child: Text(sawmill.name),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context
                  .read<ShipmentFormBloc>()
                  .add(ShipmentFormSawmillUpdate(value));
            }
          },
        );
      },
    );
  }
}
