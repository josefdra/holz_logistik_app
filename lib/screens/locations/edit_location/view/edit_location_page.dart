import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:holz_logistik/screens/locations/edit_location/edit_location.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class EditLocationPage extends StatelessWidget {
  const EditLocationPage({
    super.key,
  });

  static Route<void> route({
    required bool isPrivileged,
    Location? initialLocation,
    LatLng? newMarkerPosition,
  }) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (context) => EditLocationBloc(
          locationsRepository: context.read<LocationRepository>(),
          sawmillRepository: context.read<SawmillRepository>(),
          contractRepository: context.read<ContractRepository>(),
          photoRepository: context.read<PhotoRepository>(),
          initialLocation: initialLocation,
          newMarkerPosition: newMarkerPosition,
          isPrivileged: isPrivileged,
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
    final status = context.select((EditLocationBloc bloc) => bloc.state.status);
    final state = context.watch<EditLocationBloc>().state;
    final isNewLocation = context.select(
      (EditLocationBloc bloc) => bloc.state.isNewLocation,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewLocation ? 'Standort hinzufügen' : 'Standort bearbeiten',
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
            : const Icon(Icons.check),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const _PartieNrField(),
                const _AdditionalInfoField(),
                const Row(
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
                const SizedBox(height: 20),
                const Row(
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
                const SizedBox(height: 20),
                const Row(
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
                if (state.isPrivileged) const SizedBox(height: 20),
                if (state.isPrivileged) const _SawmillsField(),
                if (state.isPrivileged) const SizedBox(height: 20),
                if (state.isPrivileged) const _OversizeSawmillsField(),
                const SizedBox(height: 20),
                const _PhotoField(),
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
    final state = context.watch<EditLocationBloc>().state;
    final hintText = state.initialLocation?.partieNr ?? '';
    final error = state.validationErrors['partieNr'];

    return TextFormField(
      key: const Key('editLocationView_partieNr_textFormField'),
      initialValue: state.partieNr,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess && state.isPrivileged,
        labelText: 'Partie Nummer',
        hintText: hintText,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
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
    final state = context.watch<EditLocationBloc>().state;
    final hintText = state.initialLocation?.additionalInfo ?? '';

    return TextFormField(
      key: const Key('editLocationView_additionalInfo_textFormField'),
      initialValue: state.additionalInfo,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess && state.isPrivileged,
        labelText: 'Zusätzliche Info',
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
    final today = DateTime.now();

    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Datum',
        enabled: !state.status.isLoadingOrSuccess && state.isPrivileged,
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
            : '${today.day}.${today.month}.${today.year}',
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
    final state = context.watch<EditLocationBloc>().state;
    final error = state.validationErrors['initialQuantity'];

    return TextFormField(
      key: const Key('editLocationView_initialQuantity_textFormField'),
      initialValue: state.initialLocation?.initialQuantity.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess && state.isPrivileged,
        labelText: 'Menge (fm)',
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
    final state = context.watch<EditLocationBloc>().state;
    final error = state.validationErrors['initialOversizeQuantity'];

    return TextFormField(
      key: const Key('editLocationView_initialQuantity_textFormField'),
      initialValue:
          state.initialLocation?.initialOversizeQuantity.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess && state.isPrivileged,
        labelText: 'Davon ÜS (fm)',
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
    final state = context.watch<EditLocationBloc>().state;
    final error = state.validationErrors['initialPieceCount'];

    return TextFormField(
      key: const Key('editLocationView_initialPieceCount_textFormField'),
      initialValue: state.initialLocation?.initialPieceCount.toString() ?? '',
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess && state.isPrivileged,
        labelText: 'Stückzahl',
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
    final state = context.watch<EditLocationBloc>().state;
    final error = state.validationErrors['contract'];

    final selectedId = state.contractId.isNotEmpty
        ? state.contractId
        : state.initialLocation?.contractId;

    final value = selectedId != null &&
            state.contracts.any((contract) => contract.id == selectedId)
        ? selectedId
        : null;

    final isEnabled = !state.status.isLoadingOrSuccess && state.isPrivileged;

    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Vertrag',
        enabled: isEnabled,
        errorText: error,
        border: const OutlineInputBorder(),
      ),
      value: value,
      items: state.contracts.map((contract) {
        return DropdownMenuItem<String>(
          value: contract.id,
          child: Text(contract.title),
        );
      }).toList(),
      onChanged: isEnabled
          ? (value) {
              if (value != null) {
                context
                    .read<EditLocationBloc>()
                    .add(EditLocationContractChanged(value));
              }
            }
          : null,
    );
  }
}

class _NewSawmillField extends StatelessWidget {
  const _NewSawmillField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditLocationBloc>().state;

    return TextField(
      controller: state.newSawmillController,
      key: const Key('editLocationView_newSawmill_textFormField'),
      decoration: InputDecoration(
        labelText: 'Neues Sägewerk erstellen',
        enabled: !state.status.isLoadingOrSuccess && state.isPrivileged,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          key: const Key('editLocationView_addSawmill_iconButton'),
          onPressed: () => context
              .read<EditLocationBloc>()
              .add(const EditLocationNewSawmillSubmitted()),
          icon: const Icon(Icons.check),
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
                Sawmill(name: value),
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
    return BlocBuilder<EditLocationBloc, EditLocationState>(
      builder: (context, state) {
        return MultiDropdown(
          controller: state.sawmillController,
          enabled: !state.status.isLoadingOrSuccess,
          key: const Key('editLocationView_sawmill_dropDown'),
          fieldDecoration: const FieldDecoration(
            labelText: 'Sägewerke',
            border: OutlineInputBorder(),
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
    return BlocBuilder<EditLocationBloc, EditLocationState>(
      builder: (context, state) {
        return MultiDropdown(
          controller: state.oversizeSawmillController,
          enabled: !state.status.isLoadingOrSuccess,
          key: const Key('editLocationView_oversizeSawmill_dropDown'),
          fieldDecoration: const FieldDecoration(
            labelText: 'Sägewerke ÜS',
            border: OutlineInputBorder(),
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

class _PhotoField extends StatelessWidget {
  const _PhotoField();

  Future<List<Photo>> _showPhotoSourceBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Foto aufnehmen'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Aus Galerie'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
            ],
          ),
        );
      },
    );

    if (result == 'camera') {
      return _takePhoto();
    } else if (result == 'gallery') {
      return _pickPhotos();
    }

    return <Photo>[];
  }

  Future<List<Photo>> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    final photoObjects = <Photo>[];

    if (photo != null) {
      final photoFile = File(photo.path);
      final fileSize = await photoFile.length();

      if (fileSize < 2 * 1024 * 1024) {
        final bytePhoto = await photo.readAsBytes();
        final photoObject = Photo(photoFile: bytePhoto);
        photoObjects.add(photoObject);
      } else {
        const maxSize = 2 * 1024 * 1024;
        var quality = (maxSize / fileSize * 100).round();

        quality = quality.clamp(50, 90);

        final compressedData = await FlutterImageCompress.compressWithFile(
          photo.path,
          quality: quality,
        );

        if (compressedData != null) {
          final photoObject = Photo(photoFile: compressedData);
          photoObjects.add(photoObject);
        }
      }
    }

    return photoObjects;
  }

  Future<List<Photo>> _pickPhotos() async {
    final picker = ImagePicker();
    final photos = await picker.pickMultiImage();
    final photoObjects = <Photo>[];

    if (photos.isNotEmpty) {
      for (final photo in photos) {
        final photoFile = File(photo.path);
        final fileSize = await photoFile.length();

        if (fileSize < 2 * 1024 * 1024) {
          final bytePhoto = await photo.readAsBytes();
          final photoObject = Photo(photoFile: bytePhoto);
          photoObjects.add(photoObject);
        } else {
          const maxSize = 2 * 1024 * 1024;
          var quality = (maxSize / fileSize * 100).round();

          quality = quality.clamp(50, 90);

          final compressedData = await FlutterImageCompress.compressWithFile(
            photo.path,
            quality: quality,
          );

          if (compressedData != null) {
            final photoObject = Photo(photoFile: compressedData);
            photoObjects.add(photoObject);
          }
        }
      }
    }

    return photoObjects;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditLocationBloc, EditLocationState>(
      builder: (context, state) {
        return Column(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final photos = await _showPhotoSourceBottomSheet(context);
                if (photos.isNotEmpty && context.mounted) {
                  context
                      .read<EditLocationBloc>()
                      .add(EditLocationPhotosAdded(photos));
                }
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Fotos hinzufügen'),
            ),
            const SizedBox(height: 16),
            if (state.photos.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.photos.length,
                  itemBuilder: (context, index) {
                    final photo = state.photos[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 120,
                            width: 120,
                            child: Image.memory(
                              photo.photoFile,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                context.read<EditLocationBloc>().add(
                                      EditLocationPhotoRemoved(photo.id),
                                    );
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
