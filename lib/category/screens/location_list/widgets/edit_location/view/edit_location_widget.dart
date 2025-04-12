import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/edit_location/edit_location.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class EditLocationWidget extends StatelessWidget {
  const EditLocationWidget({
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
        ),
        child: const EditLocationWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditLocationBloc, EditLocationState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditLocationStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
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
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context
                .read<EditLocationBloc>()
                .add(const EditLocationSubmitted()),
        child: status.isLoadingOrSuccess
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      body: const CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _PartieNrField(),
                _AdditionalInfoField(),
                _InitialQuantityField(),
                _InitialOversizeQuantityField(),
                _InitialPieceCountField(),
                _ContractField(),
                _NewSawmillField(),
                _SawmillsField(),
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

    return TextFormField(
      key: const Key('editLocationView_partieNr_textFormField'),
      initialValue: state.partieNr,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationPartieNrLabel,
        hintText: hintText,
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

    return TextFormField(
      key: const Key('editLocationView_initialQuantity_textFormField'),
      initialValue: state.initialLocation?.initialQuantity.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationInitialQuantityLabel,
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

    return TextFormField(
      key: const Key('editLocationView_initialQuantity_textFormField'),
      initialValue: state.initialLocation?.initialQuantity.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationInitialOversizeQuantityLabel,
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

    return TextFormField(
      key: const Key('editLocationView_initialPieceCount_textFormField'),
      initialValue: state.initialLocation?.initialPieceCount.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editLocationInitialPieceCountLabel,
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
    final contracts =
        context.watch<ContractRepository>().currentActiveContracts;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: l10n.editLocationContractLabel,
        enabled: !state.status.isLoadingOrSuccess,
        border: const OutlineInputBorder(),
      ),
      value: state.contractId != '' ? state.contractId : null,
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
  }
}

class _NewSawmillField extends StatelessWidget {
  const _NewSawmillField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditLocationBloc>().state;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            key: const Key('editLocationView_newSawmill_textFormField'),
            initialValue: '',
            decoration: InputDecoration(
              enabled: !state.status.isLoadingOrSuccess,
              labelText: l10n.editLocationNewSawmillLabel,
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
          ),
        ),
        IconButton(
          key: const Key('editLocationView_addSawmill_iconButton'),
          onPressed: () => context
              .read<EditLocationBloc>()
              .add(const EditLocationNewSawmillSubmitted()),
          icon: const Icon(Icons.check),
        ),
      ],
    );
  }
}

class _SawmillsField extends StatelessWidget {
  const _SawmillsField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditLocationBloc>().state;

    return MultiDropdown(
      key: const Key('editLocationView_sawmill_dropDown'),
      controller: state.sawmillController,
      fieldDecoration: FieldDecoration(
        labelText: l10n.editLocationSawmillsLabel,
        border: const OutlineInputBorder(),
      ),
      items: context
          .read<SawmillRepository>()
          .currentSawmills
          .map((item) => DropdownItem(label: item.name, value: item))
          .toList(),
      onSelectionChange: (selectedItems) => context
          .read<EditLocationBloc>()
          .add(EditLocationSawmillsChanged(selectedItems)),
    );
  }
}

class _OversizeSawmillsField extends StatelessWidget {
  const _OversizeSawmillsField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditLocationBloc>().state;

    return MultiDropdown(
      key: const Key('editLocationView_oversizeSawmill_dropDown'),
      controller: state.oversizeSawmillController,
      fieldDecoration: FieldDecoration(
        labelText: l10n.editLocationOversizeSawmillsLabel,
        border: const OutlineInputBorder(),
      ),
      items: context
          .read<SawmillRepository>()
          .currentSawmills
          .map((item) => DropdownItem(label: item.name, value: item))
          .toList(),
      onSelectionChange: (selectedItems) => context
          .read<EditLocationBloc>()
          .add(EditLocationOversizeSawmillsChanged(selectedItems)),
    );
  }
}
