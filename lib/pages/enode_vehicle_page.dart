import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ev_vehicle_app/models/enode_vehicle.dart';
import 'package:ev_vehicle_app/providers/enode_vehicle_provider.dart';

class EnodeVehiclePage extends StatefulWidget {
  final String enodeVehicleId;

  EnodeVehiclePage({required this.enodeVehicleId});

  @override
  _EnodeVehiclePageState createState() => _EnodeVehiclePageState();
}

class _EnodeVehiclePageState extends State<EnodeVehiclePage> {
  @override
  void initState() {
    // Load the enode_vehicle by ID
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<EnodeVehicleProvider>()
          .fetchEnodeVehicle(widget.enodeVehicleId);
      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final enodeVehicle = context.watch<EnodeVehicleProvider>().enodeVehicle;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enode Vehicle Details'),
      ),
      body: enodeVehicle != null
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.electric_car_outlined,
                              size: 48, color: Theme.of(context).primaryColor),
                          title: Text(
                            '${enodeVehicle.brand} ${enodeVehicle.model}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          subtitle:
                              Text('Enode Vehicle ID: ${enodeVehicle.id}'),
                        ),
                        const Divider(),
                        _buildDetailRow(
                            'Battery Level:',
                            '${enodeVehicle.batteryLevel} %',
                            Icons.battery_full),
                        _buildDetailRow(
                            'Battery Capacity:',
                            '${enodeVehicle.batteryCapacity} kWh',
                            Icons.battery_charging_full),
                        _buildDetailRow('Charging Power:',
                            '${enodeVehicle.maxCurrent} A', Icons.power),
                        _buildDetailRow(
                            'Charging State:',
                            '${enodeVehicle.powerDeliveryState}',
                            Icons.charging_station),
                        _buildDetailRow(
                            'Location:',
                            'Lat: ${enodeVehicle.latitude}, Lon: ${enodeVehicle.longitude}',
                            Icons.location_on),
                        _buildDetailRow(
                            'Charge Limit:',
                            '${enodeVehicle.chargeLimit} %',
                            Icons.settings_input_component),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
