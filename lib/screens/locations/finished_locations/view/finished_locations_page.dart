import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../lib_old/category/screens/location_list/location_list.dart';
import '../finished_locations.dart';
import 'package:holz_logistik_backend/repository/repository.dart';

class FinishedLocationPage extends StatelessWidget {
  const FinishedLocationPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => FinishedLocationBloc(
          locationRepository: context.read<LocationRepository>(),
        ),
        child: const FinishedLocationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinishedLocationBloc(
        locationRepository: context.read<LocationRepository>(),
      )..add(const FinishedLocationSubscriptionRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Abgeschlossene Standorte')),
        body: const FinishedLocationList(),
      ),
    );
  }
}

class FinishedLocationList extends StatelessWidget {
  const FinishedLocationList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinishedLocationBloc, FinishedLocationState>(
      builder: (context, state) {
        if (state.locations.isEmpty) {
          if (state.status == FinishedLocationStatus.loading) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (state.status != FinishedLocationStatus.success) {
            return const SizedBox();
          } else {
            return Center(
              child: Text(
                'Keine abgeschlossenen Standorte',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
        }

        return CupertinoScrollbar(
          controller: state.scrollController,
          child: ListView.builder(
            controller: state.scrollController,
            itemCount: state.locations.length,
            itemBuilder: (_, index) {
              final location = state.locations.elementAt(index);
              return LocationListTile(
                location: location,
                onTap: () {
                  print('Show location details widget');
                },
              );
            },
          ),
        );
      },
    );
  }
}
