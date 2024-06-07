import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/station_provider.dart';

//This station details page is a dummy page that displays the list of stations to test the station provider.

class StationDetailPage extends StatefulWidget {
  const StationDetailPage({super.key});

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<StationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Details'),
      ),
      body: ListView.builder(
        itemCount: provider.evStation.length,
        itemBuilder: (context, index) {
          final station = provider.evStation[index];
          return ListTile(
            title: Text(station.name!),
            subtitle: Text(station.addressLine!),
          );
        },
      ),
    );
  }
}
