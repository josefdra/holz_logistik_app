import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/analytics/analytics.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

class EditContractWidget extends StatelessWidget {
  const EditContractWidget({
    super.key,
  });

  static Route<void> route({Contract? initialContract}) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => EditContractBloc(
          contractsRepository: context.read<ContractRepository>(),
          initialContract: initialContract,
        ),
        child: const EditContractWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditContractBloc, EditContractState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditContractStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const EditContractView(),
    );
  }
}

class EditContractView extends StatelessWidget {
  const EditContractView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = context.select((EditContractBloc bloc) => bloc.state.status);
    final isNewContract = context.select(
      (EditContractBloc bloc) => bloc.state.isNewContract,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewContract
              ? l10n.editContractAddAppBarTitle
              : l10n.editContractEditAppBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'editContractWidgetFloatingActionButton',
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context
                .read<EditContractBloc>()
                .add(const EditContractSubmitted()),
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
                _TitleField(),
                _AdditionalInfoField(),
                _AvailableQuantityField(),
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
    final l10n = context.l10n;
    final state = context.watch<EditContractBloc>().state;
    final hintText = state.initialContract?.title ?? '';

    return TextFormField(
      key: const Key('editContractView_title_textFormField'),
      initialValue: state.title,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editContractTitleLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context.read<EditContractBloc>().add(EditContractTitleChanged(value));
      },
    );
  }
}

class _AdditionalInfoField extends StatelessWidget {
  const _AdditionalInfoField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditContractBloc>().state;
    final hintText = state.initialContract?.additionalInfo ?? '';

    return TextFormField(
      key: const Key('editContractView_additionalInfo_textFormField'),
      initialValue: state.additionalInfo,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editContractAdditionalInfoLabel,
        hintText: hintText,
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

class _AvailableQuantityField extends StatelessWidget {
  const _AvailableQuantityField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditContractBloc>().state;

    return TextFormField(
      key: const Key('editContractView_availableQuantity_textFormField'),
      initialValue: state.initialContract?.availableQuantity.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editContractAvailableQuantityLabel,
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
