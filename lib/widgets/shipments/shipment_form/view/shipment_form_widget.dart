import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/widgets/shipments/shipment_form/shipment_form.dart';
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
        contractRepository: context.read<ContractRepository>(),
      )..add(const ShipmentFormSubscriptionRequested()),
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Neue Abfuhr',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 28,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _QuantityField(isRest: false)),
                    SizedBox(width: 10),
                    Expanded(child: _QuantityField(isRest: true)),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _OversizeQuantityField(isRest: false)),
                    SizedBox(width: 10),
                    Expanded(child: _OversizeQuantityField(isRest: true)),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _PieceCountField(isRest: false)),
                    SizedBox(width: 10),
                    Expanded(child: _PieceCountField(isRest: true)),
                  ],
                ),
                const SizedBox(height: 20),
                const _SawmillField(),
                const SizedBox(height: 20),
                const _AdditionalInfoField(),
                const _FinishLocationField(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filled(
                      onPressed: () => context
                          .read<ShipmentFormBloc>()
                          .add(const ShipmentFormCanceled()),
                      icon: const Icon(Icons.close),
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
                      icon: const Icon(Icons.check),
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
  const _QuantityField({required this.isRest});

  final bool isRest;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final error = isRest ? null : state.validationErrors['quantity'];
    final controller =
        isRest ? context.read<ShipmentFormBloc>().restQuantityController : null;

    return TextFormField(
      controller: controller,
      key: Key('${isRest ? 'rest' : ''}shipmentForm_quantity_textFormField'),
      initialValue: isRest ? null : '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '${isRest ? 'Rest' : 'Abfuhr'} (fm)',
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
        DecimalInputFormatter(),
      ],
      onChanged: (value) {
        if (value.isNotEmpty) {
          context.read<ShipmentFormBloc>().add(
                isRest
                    ? ShipmentFormRestQuantityUpdate(double.parse(value))
                    : ShipmentFormQuantityUpdate(double.parse(value)),
              );
        } else if (isRest) {
          controller!.clear();
        }
      },
    );
  }
}

class _OversizeQuantityField extends StatelessWidget {
  const _OversizeQuantityField({required this.isRest});

  final bool isRest;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final controller = isRest
        ? context.read<ShipmentFormBloc>().restOversizeQuantityController
        : null;

    return TextFormField(
      controller: controller,
      key: Key('${isRest ? 'rest' : ''}shipmentForm_oversizeQuantity_'
          'textFormField'),
      initialValue: isRest ? null : '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '${isRest ? 'Rest' : 'Abfuhr'} davon ÜS',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
        DecimalInputFormatter(),
      ],
      onChanged: (value) {
        if (value.isNotEmpty) {
          context.read<ShipmentFormBloc>().add(
                isRest
                    ? ShipmentFormRestOversizeQuantityUpdate(
                        double.parse(value),
                      )
                    : ShipmentFormOversizeQuantityUpdate(double.parse(value)),
              );
        } else if (isRest) {
          controller!.clear();
        }
      },
    );
  }
}

class _PieceCountField extends StatelessWidget {
  const _PieceCountField({required this.isRest});

  final bool isRest;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final error = isRest ? null : state.validationErrors['pieceCount'];
    final controller = isRest
        ? context.read<ShipmentFormBloc>().restPieceCountController
        : null;

    return TextFormField(
      controller: controller,
      key: Key('${isRest ? 'rest' : ''}shipmentForm_pieceCount_'
          'textFormField'),
      initialValue: isRest ? null : '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: '${isRest ? 'Rest' : 'Abfuhr'} Stk',
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
        DecimalInputFormatter(),
      ],
      onChanged: (value) {
        if (value.isNotEmpty) {
          context.read<ShipmentFormBloc>().add(
                isRest
                    ? ShipmentFormRestPieceCountUpdate(int.parse(value))
                    : ShipmentFormPieceCountUpdate(int.parse(value)),
              );
        } else if (isRest) {
          controller!.clear();
        }
      },
    );
  }
}

class _SawmillField extends StatelessWidget {
  const _SawmillField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;
    final error = state.validationErrors['sawmill'];

    return StreamBuilder<Map<String, Sawmill>>(
      stream: context.watch<SawmillRepository>().sawmills,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final sawmills = snapshot.data!;

        return DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Sägewerk',
            enabled: !state.status.isLoadingOrSuccess,
            errorText: error,
            border: const OutlineInputBorder(),
          ),
          value: state.sawmillId.isNotEmpty ? state.sawmillId : null,
          items: sawmills.values.map((sawmill) {
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

class _AdditionalInfoField extends StatelessWidget {
  const _AdditionalInfoField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;

    return TextFormField(
      key: const Key('shipmentForm_additionalInfo_textFormField'),
      initialValue: state.additionalInfo,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: 'Zusätzliche Info',
        border: const OutlineInputBorder(),
      ),
      maxLength: 60,
      maxLines: 2,
      inputFormatters: [
        LengthLimitingTextInputFormatter(60),
      ],
      onChanged: (value) {
        context
            .read<ShipmentFormBloc>()
            .add(ShipmentFormAdditionalInfoChanged(value));
      },
    );
  }
}

class _FinishLocationField extends StatelessWidget {
  const _FinishLocationField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShipmentFormBloc>().state;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: state.locationFinished,
          onChanged: state.status.isLoadingOrSuccess
              ? null
              : (bool? value) {
                  if (value != null) {
                    context
                        .read<ShipmentFormBloc>()
                        .add(ShipmentFormLocationFinishedUpdate(value));
                  }
                },
        ),
        Text(
          'Standort abschließen',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
