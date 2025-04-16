import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../shipments.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class ShipmentsPage extends StatelessWidget {
  const ShipmentsPage({super.key});

  static Route<void> route({Shipment? initialShipment}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => ShipmentsBloc(
          shipmentRepository: context.read<ShipmentRepository>(),
          locationRepository: context.read<LocationRepository>(),
        ),
        child: const ShipmentsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShipmentsBloc(
        shipmentRepository: context.read<ShipmentRepository>(),
        locationRepository: context.read<LocationRepository>(),
      )..add(const ShipmentsSubscriptionRequested()),
      child: const Scaffold(
        body: ShipmentList(),
      ),
    );
  }
}

class ShipmentList extends StatelessWidget {
  const ShipmentList({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ShipmentsBloc, ShipmentsState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ShipmentsStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Error'),
                  ),
                );
            }
          },
        ),
        BlocListener<ShipmentsBloc, ShipmentsState>(
          listenWhen: (previous, current) =>
              previous.lastDeletedShipment != current.lastDeletedShipment &&
              current.lastDeletedShipment != null,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 5),
                  content: const Text(
                    'text',
                  ),
                  action: SnackBarAction(
                    label: 'label',
                    onPressed: () {
                      messenger.hideCurrentSnackBar();
                      context
                          .read<ShipmentsBloc>()
                          .add(const ShipmentsUndoDeletionRequested());
                    },
                  ),
                ),
              );
          },
        ),
      ],
      child: BlocBuilder<ShipmentsBloc, ShipmentsState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildDatePickerRow(context, state),
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDatePickerRow(BuildContext context, ShipmentsState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
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
                context
                    .read<ShipmentsBloc>()
                    .add(ShipmentsDateChanged(startDate, endDate));
              }
            }
          },
          icon: const Icon(
            Icons.date_range,
          ),
        ),
        Center(
          child: Text('${state.startDate.day}.${state.startDate.month}.'
              '${state.startDate.year} - ${state.endDate.day}.'
              '${state.endDate.month}.${state.endDate.year}'),
        ),
        IconButton(
          onPressed: () =>
              context.read<ShipmentsBloc>().add(const ShipmentsAutomaticDate()),
          icon: const Icon(
            Icons.schedule,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ShipmentsState state) {
    if (state.shipments.isEmpty) {
      if (state.status == ShipmentsStatus.loading) {
        return const Center(child: CupertinoActivityIndicator());
      } else if (state.status != ShipmentsStatus.success) {
        return const SizedBox();
      } else {
        return Center(
          child: Text(
            'Nix',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }
    }

    return CupertinoScrollbar(
      controller: state.scrollController,
      child: ListView.builder(
        controller: state.scrollController,
        itemCount: state.shipments.length,
        itemBuilder: (_, index) {
          final shipment = state.shipments.elementAt(index);
          return ShipmentListTile(
            shipment: shipment,
            onDeleted: () {
              context.read<ShipmentsBloc>().add(
                    ShipmentsShipmentDeleted(shipment),
                  );
            },
            onTap: () {},
          );
        },
      ),
    );
  }
}
