import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/core/l10n/l10n.dart';
import 'package:holz_logistik/category/screens/location_list/widgets/edit_location/edit_location.dart';
import 'package:holz_logistik_backend/repository/location_repository.dart';

class EditLocationWidget extends StatelessWidget {
  const EditLocationWidget({
    super.key,
  });

  static Route<void> route({Location? initialLocation}) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => EditLocationBloc(
          locationsRepository: context.read<LocationRepository>(),
          initialLocation: initialLocation,
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
              children: [_PartieNrField(), _AdditionalInfoField()],
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
      maxLines: 7,
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
