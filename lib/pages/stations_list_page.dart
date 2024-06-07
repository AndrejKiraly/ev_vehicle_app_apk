import 'package:ev_vehicle_app/models/charging.dart';
import 'package:ev_vehicle_app/pages/station_details_page.dart';
import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/connections_list_page.dart';

class StationsListPage extends StatefulWidget {
  final Charging charging;

  StationsListPage({Key? key, required this.charging}) : super(key: key);
  @override
  State<StationsListPage> createState() => _StationsListPageState();
}

class _StationsListPageState extends State<StationsListPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<StationProvider>()
          .fetchStationsForCharging(widget.charging);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final stations = context.watch<StationProvider>().evStation;
    final isLoading = context.watch<StationProvider>().isLoading;
    final errorMessage = context.watch<StationProvider>().errorMessage;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stations List'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != ''
              ? Center(
                  child: Text(errorMessage),
                )
              : stations.isEmpty
                  ? const Center(
                      child: Text('No stations found!'),
                    )
                  : ListView.builder(
                      itemCount: stations.length,
                      itemBuilder: (ctx, index) {
                        final station = stations[index];
                        return ListTile(
                          title: Text(station.name!),
                          subtitle: Text(station.addressLine!),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ConnectionsListPage(
                                          stationId: station.id!,
                                          charging: widget.charging,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return StationDetailsPage(
                                stationId: station.id!,
                              );
                            }));
                          },
                        );
                      },
                    ),
    );
  }
}
