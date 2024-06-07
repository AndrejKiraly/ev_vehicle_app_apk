import 'package:ev_vehicle_app/models/charging.dart';
import 'package:ev_vehicle_app/pages/charging_page.dart';
import 'package:ev_vehicle_app/providers/chargings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/add_connection_page.dart';
import '../providers/connection_provider.dart';

class ConnectionsListPage extends StatefulWidget {
  final int? stationId;
  final Charging charging;
  const ConnectionsListPage(
      {super.key, required this.stationId, required this.charging});
  @override
  State<ConnectionsListPage> createState() => _ConnectionsListPageState();
}

class _ConnectionsListPageState extends State<ConnectionsListPage> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await context
          .read<ConnectionProvider>()
          .fetchConnections(widget.stationId!);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final connections = context.watch<ConnectionProvider>().evConnections;
    final isLoading = context.watch<ConnectionProvider>().isLoading;
    final errorMessage = context.watch<ConnectionProvider>().errorMessage;
    final chargingProvider = context.read<ChargingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections List'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != ''
              ? Center(
                  child: Text(errorMessage),
                )
              : connections.isEmpty
                  ? const Center(
                      child: Text('No connectios found!'),
                    )
                  : ListView.builder(
                      itemCount: connections.length,
                      itemBuilder: (ctx, index) {
                        final connection = connections[index];
                        return ListTile(
                          title: Text(connection.connectionType.title!),
                          subtitle: Text(connection.powerKW.toString()),
                          trailing: Wrap(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  chargingProvider.updateChargingsConnection(
                                      widget.charging.id, connection.id!);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
