import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:holz_logistik/models/general/color.dart';
import 'package:holz_logistik/models/locations/locations.dart';
import 'package:holz_logistik/screens/locations/edit_location/edit_location.dart';
import 'package:holz_logistik/widgets/locations/location_details/location_details.dart';
import 'package:holz_logistik/widgets/photos/photo_viewer/view/photo_view_page.dart';
import 'package:holz_logistik/widgets/shipments/shipment_widgets.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:latlong2/latlong.dart';

class LocationDetailsWidget extends StatelessWidget {
  const LocationDetailsWidget({
    required this.location,
    super.key,
  });

  final Location location;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationDetailsBloc(
        locationsRepository: context.read<LocationRepository>(),
        contractRepository: context.read<ContractRepository>(),
        sawmillRepository: context.read<SawmillRepository>(),
        shipmentRepository: context.read<ShipmentRepository>(),
        photoRepository: context.read<PhotoRepository>(),
        authenticationRepository: context.read<AuthenticationRepository>(),
        userRepository: context.read<UserRepository>(),
        initialLocation: location,
      )..add(const LocationDetailsSubscriptionRequested()),
      child: const LocationDetailsView(),
    );
  }
}

class LocationDetailsView extends StatelessWidget {
  const LocationDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationDetailsBloc, LocationDetailsState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LocationDetailsStatus.close) {
          Navigator.of(context).pop();
        }
      },
      child: BlocBuilder<LocationDetailsBloc, LocationDetailsState>(
        builder: (context, state) {
          if (state.status == LocationDetailsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status != LocationDetailsStatus.success) {
            return const SizedBox();
          }

          return Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 70),
            child: Column(
              children: [
                _buildHeader(context, state),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.photos.isNotEmpty) _buildPhotos(state),
                        if (state.photos.isNotEmpty) const SizedBox(height: 20),
                        _buildQuantityTable(state),
                        const SizedBox(height: 20),
                        _buildSawmillRow(
                          label: 'Sägewerke:',
                          sawmills: state.sawmills,
                        ),
                        const SizedBox(height: 20),
                        _buildSawmillRow(
                          label: 'Sägewerke ÜS:',
                          sawmills: state.oversizeSawmills,
                        ),
                        const SizedBox(height: 20),
                        _buildDateAndInfo(state),
                        const SizedBox(height: 10),
                        _buildMap(context, state),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            'Abfuhren:',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ),
                        ...state.shipments.map(
                          (shipment) => SmallShipmentListTile(
                            shipment: shipment,
                            userName: state.userNames[shipment.userId] ?? '',
                            sawmillName:
                                state.sawmillNames[shipment.sawmillId] ?? '',
                            contractRepository:
                                context.read<ContractRepository>(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildActionButtons(context, state),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LocationDetailsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.location.partieNr,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              Text(
                state.contract.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotos(LocationDetailsState state) {
    return SizedBox(
      height: 120,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: state.photos.length,
          itemBuilder: (context, index) {
            final photo = state.photos[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PhotoViewPage.route(
                      currentIndex: index,
                      photos: state.photos,
                    ),
                  );
                },
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Image.memory(
                    photo.photoFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuantityTable(LocationDetailsState state) {
    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(120),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FixedColumnWidth(60),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        const TableRow(
          children: <Widget>[
            SizedBox(height: 32),
            SizedBox(
              height: 32,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Menge (fm)'),
              ),
            ),
            SizedBox(
              height: 32,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Davon ÜS'),
              ),
            ),
            SizedBox(
              height: 32,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Stück'),
              ),
            ),
          ],
        ),
        _buildQuantityRow(
          label: 'Anfangs:',
          quantity: state.location.initialQuantity,
          oversizeQuantity: state.location.initialOversizeQuantity,
          pieceCount: state.location.initialPieceCount,
        ),
        _buildQuantityRow(
          label: 'Momentan:',
          quantity: state.location.currentQuantity,
          oversizeQuantity: state.location.currentOversizeQuantity,
          pieceCount: state.location.currentPieceCount,
        ),
      ],
    );
  }

  TableRow _buildQuantityRow({
    required String label,
    required num quantity,
    required num oversizeQuantity,
    required int pieceCount,
  }) {
    return TableRow(
      children: <Widget>[
        SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label),
            ),
          ),
        ),
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('$quantity'),
          ),
        ),
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('$oversizeQuantity'),
          ),
        ),
        SizedBox(
          height: 32,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('$pieceCount'),
          ),
        ),
      ],
    );
  }

  Widget _buildSawmillRow({
    required String label,
    required List<Sawmill> sawmills,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label),
            ),
          ),
        ),
        Expanded(
          child: Text(
            sawmills.map((sawmill) => sawmill.name).join(', '),
          ),
        ),
      ],
    );
  }

  Widget _buildDateAndInfo(LocationDetailsState state) {
    return Column(
      children: [
        Text('Datum: ${state.location.date.day}.'
            '${state.location.date.month}.'
            '${state.location.date.year}'),
        const SizedBox(height: 10),
        Text(state.location.additionalInfo),
      ],
    );
  }

  Widget _buildMap(BuildContext context, LocationDetailsState state) {
    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(
          initialCenter:
              LatLng(state.location.latitude, state.location.longitude),
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.draexl_it.holz_logistik',
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 50,
                height: 50,
                point:
                    LatLng(state.location.latitude, state.location.longitude),
                child: Icon(
                  !state.location.started
                      ? Icons.location_pin
                      : Icons.location_off,
                  color: colorFromString(state.contract.name),
                  size: 50,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, LocationDetailsState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (state.location.done && state.user.role.isPrivileged ||
            !state.location.done)
          _buildActionButton(
            context: context,
            icon: state.location.done ? Icons.publish : Icons.local_shipping,
            label: state.location.done ? 'Aktivieren' : 'Abfuhr',
            onPressed: () {
              if (state.location.done) {
                context.read<LocationDetailsBloc>().add(
                      const LocationDetailsLocationReactivated(),
                    );
              } else {
                showDialog<ShipmentFormWidget>(
                  context: context,
                  builder: (context) => ShipmentFormWidget(
                    currentQuantity: state.location.currentQuantity,
                    currentOversizeQuantity:
                        state.location.currentOversizeQuantity,
                    currentPieceCount: state.location.currentPieceCount,
                    location: state.location,
                    userId: state.user.id,
                  ),
                );
              }
            },
          ),
        _buildActionButton(
          context: context,
          icon: Icons.assistant_navigation,
          label: 'Navigation',
          onPressed: () => startNavigation(state.location),
        ),
        if (state.user.role.isPrivileged)
          _buildActionButton(
            context: context,
            icon: Icons.edit,
            label: 'Bearbeiten',
            onPressed: () => Navigator.of(context).push(
              EditLocationPage.route(
                initialLocation: state.location,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 100,
      child: Center(
        child: Column(
          children: [
            IconButton.filled(
              onPressed: onPressed,
              icon: Icon(icon),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(48, 48),
              ),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}
