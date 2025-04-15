import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/category/screens/shipment_list/shipments.dart';
import 'package:holz_logistik_backend/repository/repository.dart';
import 'package:holz_logistik_backend/repository/shipment_repository.dart';

class ShipmentsPage extends StatelessWidget {
  const ShipmentsPage({super.key});

  static Route<void> route({Shipment? initialShipment}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => ShipmentsBloc(
          shipmentRepository: context.read<ShipmentRepository>(),
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
            child: ListView.builder(
              controller: ScrollController(),
              itemCount: state.shipments.length,
              itemBuilder: (_, index) {
                final shipment = state.shipments.elementAt(index);
                return ShipmentListTile(
                  shipment: shipment,
                  onDismissed: (_) {
                    context.read<ShipmentsBloc>().add(
                          ShipmentsShipmentDeleted(shipment),
                        );
                  },
                  onTap: () {},
                );
              },
            ),
          );
        },
      ),
    );
  }
}
