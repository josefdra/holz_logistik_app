import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/widgets/contract/edit_contract/edit_contract.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class EditContractWidget extends StatelessWidget {
  const EditContractWidget({
    this.contract,
    super.key,
  });

  final Contract? contract;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditContractBloc(
        initialContract: contract,
        contractsRepository: context.read<ContractRepository>(),
      ),
      child: BlocListener<EditContractBloc, EditContractState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (current.status == EditContractStatus.success),
        listener: (context, state) {
          Navigator.of(context).pop();
        },
        child: const EditContractView(),
      ),
    );
  }
}

class EditContractView extends StatelessWidget {
  const EditContractView({super.key});

  @override
  Widget build(BuildContext context) {
    final title = context.select(
      (EditContractBloc bloc) => bloc.state.isNewContract,
    )
        ? 'Neuer Vertrag'
        : 'Vertrag bearbeiten';

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
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
                const SizedBox(height: 10),
                const _TitleField(),
                const _DateField(),
                const _QuantityField(),
                const SizedBox(height: 10),
                const _AdditionalInfoField(),
                const _FinishContractField(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filled(
                      onPressed: () => context
                          .read<EditContractBloc>()
                          .add(const EditContractCanceled()),
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
                          .read<EditContractBloc>()
                          .add(const EditContractSubmitted()),
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

class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditContractBloc>().state;
    final hintText = state.initialContract?.title ?? '';
    final error = state.validationErrors['title'];

    return TextFormField(
      key: const Key('editContractView_title_textFormField'),
      initialValue: state.title,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: 'Titel',
        hintText: hintText,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      onChanged: (value) {
        context.read<EditContractBloc>().add(EditContractTitleChanged(value));
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditContractBloc>().state;

    return TextButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('${state.startDate.day}.${state.startDate.month}.'
              '${state.startDate.year}'),
          const Icon(
            Icons.date_range,
          ),
          Text('${state.endDate.day}.'
              '${state.endDate.month}.${state.endDate.year}'),
        ],
      ),
      onPressed: () async {
        final pickedDateRange = await showDateRangePicker(
          context: context,
          initialDateRange: DateTimeRange(
            start: state.startDate,
            end: state.endDate,
          ),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );

        if (pickedDateRange != null) {
          final startDate = pickedDateRange.start;
          final endDate = pickedDateRange.end;

          if (context.mounted) {
            context.read<EditContractBloc>().add(
                  EditContractDateRangeChanged(
                    startDate,
                    endDate.copyWith(hour: 23, minute: 59, second: 59),
                  ),
                );
          }
        }
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

class _QuantityField extends StatelessWidget {
  const _QuantityField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditContractBloc>().state;
    final value =
        state.availableQuantity != 0 ? state.availableQuantity.toString() : '';
    final error = state.validationErrors['title'];

    return TextFormField(
      key: const Key('editLocationView_initialQuantity_textFormField'),
      initialValue: value,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: 'Vertragsmenge',
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
          context
              .read<EditContractBloc>()
              .add(EditContractAvailableQuantityChanged(double.parse(value)));
        }
      },
    );
  }
}

class _AdditionalInfoField extends StatelessWidget {
  const _AdditionalInfoField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditContractBloc>().state;
    final hintText = state.initialContract?.additionalInfo ?? '';

    return TextFormField(
      key: const Key('editContractView_additionalInfo_textFormField'),
      initialValue: state.additionalInfo,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: 'Zusätzliche Info',
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context
            .read<EditContractBloc>()
            .add(EditContractAdditionalInfoChanged(value));
      },
    );
  }
}

class _FinishContractField extends StatelessWidget {
  const _FinishContractField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditContractBloc>().state;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: state.contractFinished,
          onChanged: state.status.isLoadingOrSuccess
              ? null
              : (bool? value) {
                  if (value != null) {
                    context
                        .read<EditContractBloc>()
                        .add(EditContractContractFinishedUpdate(value));
                  }
                },
        ),
        Text(
          'Vertrag abschließen',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
