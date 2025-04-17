import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:holz_logistik/screens/locations/edit_location/edit_location.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class EditLocationPage extends StatelessWidget {
  const EditLocationPage({
    super.key,
  });

  static Route<void> route({
    Location? initialLocation,
    LatLng? newMarkerPosition,
  }) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => EditLocationBloc(
          locationsRepository: context.read<LocationRepository>(),
          sawmillRepository: context.read<SawmillRepository>(),
          photoRepository: context.read<PhotoRepository>(),
          initialLocation: initialLocation,
          newMarkerPosition: newMarkerPosition,
        )..add(const EditLocationInit()),
        child: const EditLocationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditLocationBloc, EditLocationState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          (current.status == EditLocationStatus.success),
      listener: (context, state) {
        Navigator.of(context).pop();
      },
      child: const EditLocationView(),
    );
  }
}

class EditLocationView extends StatelessWidget {
  const EditLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = context.select((EditLocationBloc bloc) => bloc.state.status);
    final isNewLocation = context.select(
      (EditLocationBloc bloc) => bloc.state.isNewLocation,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewLocation
              ? l10n.editLocationAddAppBarTitle
              : l10n.editLocationEditAppBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'editLocationWidgetFloatingActionButton',
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context
                .read<EditLocationBloc>()
                .add(const EditLocationSubmitted()),
        child: status.isLoadingOrSuccess
            ? const CircularProgressIndicator()
            : const Icon(Icons.check_circle_outline),
      ),
      body: const Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _PartieNrField(),
                _AdditionalInfoField(),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _InitialQuantityField(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _InitialOversizeQuantityField(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _InitialPieceCountField(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ContractField(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _NewSawmillField(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _SawmillsField(),
                SizedBox(height: 20),
                _OversizeSawmillsField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PartieNrField extends StatelessWidget {
  const _PartieNrField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditLocationBloc>().state;
    final hintText = state.initialLocation?.partieNr ?? '';
    final error = state.validationErrors['partieNr'];

    return TextFormField(
      key: const Key('editLocationView_partieNr_textFormField'),
      initialValue: state.partieNr,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationPartieNrLabel,
        hintText: hintText,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context
            .read<EditLocationBloc>()
            .add(EditLocationPartieNrChanged(value));
      },
    );
  }
}

class _AdditionalInfoField extends StatelessWidget {
  const _AdditionalInfoField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditLocationBloc>().state;
    final hintText = state.initialLocation?.additionalInfo ?? '';

    return TextFormField(
      key: const Key('editLocationView_additionalInfo_textFormField'),
      initialValue: state.additionalInfo,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationAdditionalInfoLabel,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      maxLength: 300,
      maxLines: 4,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context
            .read<EditLocationBloc>()
            .add(EditLocationAdditionalInfoChanged(value));
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditLocationBloc>().state;

    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Datum',
        enabled: !state.status.isLoadingOrSuccess,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: state.date ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null &&
                pickedDate != state.date &&
                context.mounted) {
              context
                  .read<EditLocationBloc>()
                  .add(EditLocationDateChanged(pickedDate));
            }
          },
          icon: const Icon(Icons.calendar_month),
        ),
        counterText: '',
      ),
      controller: TextEditingController(
        text: state.date != null
            ? '${state.date!.day}.${state.date!.month}.${state.date!.year}'
            : 'Datum',
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

class _InitialQuantityField extends StatelessWidget {
  const _InitialQuantityField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditLocationBloc>().state;
    final error = state.validationErrors['initialQuantity'];

    return TextFormField(
      key: const Key('editLocationView_initialQuantity_textFormField'),
      initialValue: state.initialLocation?.initialQuantity.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationInitialQuantityLabel,
        errorText: error,
        border: const OutlineInputBorder(),
        counterText: '',
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
              .read<EditLocationBloc>()
              .add(EditLocationInitialQuantityChanged(double.parse(value)));
        }
      },
    );
  }
}

class _InitialOversizeQuantityField extends StatelessWidget {
  const _InitialOversizeQuantityField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditLocationBloc>().state;
    final error = state.validationErrors['initialOversizeQuantity'];

    return TextFormField(
      key: const Key('editLocationView_initialQuantity_textFormField'),
      initialValue:
          state.initialLocation?.initialOversizeQuantity.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationInitialOversizeQuantityLabel,
        border: const OutlineInputBorder(),
        errorText: error,
        counterText: '',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      maxLength: 20,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
        DecimalInputFormatter(),
      ],
      onChanged: (value) {
        if (value.isNotEmpty) {
          context.read<EditLocationBloc>().add(
                EditLocationInitialOversizeQuantityChanged(double.parse(value)),
              );
        }
      },
    );
  }
}

class _InitialPieceCountField extends StatelessWidget {
  const _InitialPieceCountField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditLocationBloc>().state;
    final error = state.validationErrors['initialPieceCount'];

    return TextFormField(
      key: const Key('editLocationView_initialPieceCount_textFormField'),
      initialValue: state.initialLocation?.initialPieceCount.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationInitialPieceCountLabel,
        errorText: error,
        border: const OutlineInputBorder(),
        counterText: '',
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
              .read<EditLocationBloc>()
              .add(EditLocationInitialPieceCountChanged(int.parse(value)));
        }
      },
    );
  }
}

class _ContractField extends StatelessWidget {
  const _ContractField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditLocationBloc>().state;

    return StreamBuilder<List<Contract>>(
      stream: context.watch<ContractRepository>().activeContracts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final contracts = {
          for (final contract in snapshot.data!) contract.id: contract,
        };

        final selectedId = state.contractId != ''
            ? state.contractId
            : state.initialLocation?.contractId;
        final value = selectedId != null && contracts.containsKey(selectedId)
            ? selectedId
            : null;

        return DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: InputDecoration(
            labelText: l10n.editLocationContractLabel,
            enabled: !state.status.isLoadingOrSuccess,
            border: const OutlineInputBorder(),
          ),
          value: value,
          items: contracts.entries.map((entry) {
            final contract = entry.value;
            return DropdownMenuItem<String>(
              value: contract.id,
              child: Text(contract.title),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context
                  .read<EditLocationBloc>()
                  .add(EditLocationContractChanged(value));
            }
          },
        );
      },
    );
  }
}

class _NewSawmillField extends StatelessWidget {
  const _NewSawmillField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditLocationBloc>().state;

    return TextField(
      controller: state.newSawmillController,
      key: const Key('editLocationView_newSawmill_textFormField'),
      decoration: InputDecoration(
        labelText: l10n.editLocationNewSawmillLabel,
        enabled: !state.status.isLoadingOrSuccess,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          key: const Key('editLocationView_addSawmill_iconButton'),
          onPressed: () => context
              .read<EditLocationBloc>()
              .add(const EditLocationNewSawmillSubmitted()),
          icon: const Icon(Icons.check_circle_outline),
        ),
        counterText: '',
      ),
      maxLength: 30,
      inputFormatters: [
        LengthLimitingTextInputFormatter(30),
      ],
      onChanged: (value) {
        context.read<EditLocationBloc>().add(
              EditLocationNewSawmillChanged(
                Sawmill.empty(name: value),
              ),
            );
      },
    );
  }
}

class _SawmillsField extends StatelessWidget {
  const _SawmillsField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<EditLocationBloc, EditLocationState>(
      builder: (context, state) {
        return MultiDropdown(
          controller: state.sawmillController,
          key: const Key('editLocationView_sawmill_dropDown'),
          fieldDecoration: FieldDecoration(
            labelText: l10n.editLocationSawmillsLabel,
            border: const OutlineInputBorder(),
          ),
          items: state.sawmillController.items,
          onSelectionChange: (selectedItems) => context
              .read<EditLocationBloc>()
              .add(EditLocationSawmillsChanged(selectedItems)),
        );
      },
    );
  }
}

class _OversizeSawmillsField extends StatelessWidget {
  const _OversizeSawmillsField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<EditLocationBloc, EditLocationState>(
      builder: (context, state) {
        return MultiDropdown(
          controller: state.oversizeSawmillController,
          key: const Key('editLocationView_oversizeSawmill_dropDown'),
          fieldDecoration: FieldDecoration(
            labelText: l10n.editLocationOversizeSawmillsLabel,
            border: const OutlineInputBorder(),
          ),
          items: state.oversizeSawmillController.items,
          onSelectionChange: (selectedItems) => context
              .read<EditLocationBloc>()
              .add(EditLocationOversizeSawmillsChanged(selectedItems)),
        );
      },
    );
  }
}
