import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/shipment_list/shipments.dart';
import 'package:holz_logistik/widgets/shipments/shipment_list_tile.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class ShipmentsPage extends StatelessWidget {
  const ShipmentsPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => ShipmentsBloc(
          shipmentRepository: context.read<ShipmentRepository>(),
          locationRepository: context.read<LocationRepository>(),
          userRepository: context.read<UserRepository>(),
          sawmillRepository: context.read<SawmillRepository>(),
        contractRepository: context.read<ContractRepository>(),
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
        userRepository: context.read<UserRepository>(),
        sawmillRepository: context.read<SawmillRepository>(),
        contractRepository: context.read<ContractRepository>(),
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
    return BlocListener<ShipmentsBloc, ShipmentsState>(
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
                context.read<ShipmentsBloc>().add(
                      ShipmentsDateChanged(
                        startDate,
                        endDate.copyWith(hour: 23, minute: 59, second: 59),
                      ),
                    );
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
        return const Center(child: CircularProgressIndicator());
      } else if (state.status != ShipmentsStatus.success) {
        return const SizedBox();
      } else {
        return Center(
          child: Text(
            'Keine Abfuhren vorhanden',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      }
    }

    return Scrollbar(
      controller: context.read<ShipmentsBloc>().scrollController,
      child: ListView.builder(
        controller: context.read<ShipmentsBloc>().scrollController,
        itemCount: state.shipments.length,
        itemBuilder: (_, index) {
          final shipment = state.shipments.elementAt(index);
          return ShipmentListTile(
            shipment: shipment,
            userName: state.users[shipment.userId]?.name ?? '',
            sawmillName:
                state.sawmills[shipment.sawmillId]?.name ?? '',
            partieNr: state.partieNr[shipment.locationId] ?? '',
            contractRepository: context.read<ContractRepository>(),
            onDeleted: () {
              context.read<ShipmentsBloc>().add(
                    ShipmentsShipmentDeleted(shipment),
                  );
            },
          );
        },
      ),
    );
  }
}
