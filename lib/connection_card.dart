import 'package:ev_vehicle_app/models/ev_connection.dart';
import 'package:ev_vehicle_app/pages/add_charging_page.dart';
import 'package:flutter/material.dart';

class ConnectionCard extends StatefulWidget {
  final EvConnection connection;
  final bool? isAssigningCharging;
  final bool isLoggedIn;

  const ConnectionCard(
      {super.key,
      required this.connection,
      this.isAssigningCharging,
      this.isLoggedIn = false});

  @override
  _ConnectionCardState createState() => _ConnectionCardState();
}

class _ConnectionCardState extends State<ConnectionCard> {
  @override
  initState() {}

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Type: ${widget.connection.connectionType.title}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Chip(
                    label: Text(
                      widget.connection.isOperationalStatus != null
                          ? (widget.connection.isOperationalStatus!
                              ? 'Operational'
                              : 'Not Operational')
                          : 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor:
                        widget.connection.isOperationalStatus != null
                            ? (widget.connection.isOperationalStatus!
                                ? Colors.green[100]
                                : Colors.red[100])
                            : Colors.grey[200],
                  ),
                ],
              ),
              const Divider(),
              _buildDetailRow('ID:', '${widget.connection.id}'),
              _buildDetailRow(
                  'Fast Charge:',
                  widget.connection.isFastChargeCapable != null
                      ? (widget.connection.isFastChargeCapable! ? 'Yes' : 'No')
                      : 'Unknown'),
              _buildDetailRow(
                  'Current Type:', widget.connection.currentType.title),
              _buildDetailRow('Amps:', '${widget.connection.amps}'),
              _buildDetailRow('Voltage:', '${widget.connection.voltage}'),
              _buildDetailRow('Power (KW):', '${widget.connection.powerKW}'),
              _buildDetailRow('Quantity:', '${widget.connection.quantity}'),
              const SizedBox(height: 16),
              Center(
                child: widget.isLoggedIn
                    ? FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddChargingPage(
                              connectionId: widget.connection.id!,
                              isEditMode: false,
                            ),
                          ));
                        },
                        child: const Icon(Icons.battery_charging_full_outlined),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
