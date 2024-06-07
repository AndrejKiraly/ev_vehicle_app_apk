import 'package:ev_vehicle_app/pages/add_station_page.dart';
import 'package:ev_vehicle_app/pages/chargings_page.dart';
import 'package:ev_vehicle_app/pages/show_connections_page.dart';
import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:ev_vehicle_app/providers/station_detail_provider.dart';
import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StationDetailsPage extends StatefulWidget {
  final int stationId;

  const StationDetailsPage({required this.stationId, super.key});

  @override
  State<StationDetailsPage> createState() => _StationDetailsPageState();
}

class _StationDetailsPageState extends State<StationDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<StationDetailProvider>()
          .fetchStationDetail(stationId: widget.stationId);
      final loginProvider = context.read<LoginProvider>();
      await loginProvider.checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stationDetailProvider = context.watch<StationDetailProvider>();
    final isLoading = stationDetailProvider.isLoading;
    final station = stationDetailProvider.station;
    final connections = stationDetailProvider.connections;
    final isLoggedIn = context.watch<LoginProvider>().isLoggedIn;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Details'),
        actions: [
          isLoggedIn == true
              ? PopupMenuButton<String>(
                  onSelected: (String value) async {
                    if (value == 'edit') {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return AddStationPage(
                            station: station,
                            isEditing: true,
                          );
                        }),
                      );

                      if (result == true) {
                        await context
                            .read<StationDetailProvider>()
                            .fetchStationDetail(stationId: widget.stationId);
                      }
                    } else if (value == 'delete') {
                      await context
                          .read<StationProvider>()
                          .deleteStation(station!.id!, context);
                      Navigator.of(context).pop(false);
                      Navigator.of(context).pop(false);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit Station'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete Station'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_vert),
                )
              : Container(),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Card(
                    elevation: 2,
                    margin: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Name: ${station!.name}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            subtitle: Text(
                              'Address: ${station.addressLine}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Column(
                              children: [
                                Text(
                                  'Rating: ${station.rating}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'User Ratings: ${station.userRatingTotal}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 16),
                          _buildDetailRow('Country:', station.countryString!),
                          _buildDetailRow('City:', station.city!),
                          _buildDetailRow('Source:', station.source.title),
                          _buildDetailRow('Phone Number:',
                              station.phoneNumber ?? 'Not available'),
                          _buildDetailRow(
                              'Email:', station.email ?? 'Not available'),
                          _buildDetailRow('Operator Website:',
                              station.operatorWebsite ?? 'Not available'),
                          _buildDetailRow('Open Hours:',
                              station.openHours ?? 'Not available'),
                          station.isFree!
                              ? _buildDetailRow('Price Information:', 'Free')
                              : _buildDetailRow('Price Information:',
                                  station.priceInformation ?? 'Not available'),
                          _buildDetailRow(
                              'Created At:',
                              station.createdAt!.toString().substring(0,
                                  station.createdAt.toString().indexOf('.'))),
                          _buildDetailRow(
                              'Updated At:',
                              station.updatedAt!.toString().substring(0,
                                  station.updatedAt.toString().indexOf('.'))),
                          _buildDetailRow(
                              'Usage Type:', station.usageType.title),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Amenities:',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: station.amenities.map((amenity) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Chip(
                                        label: Text(amenity.title),
                                        backgroundColor: Colors.blue[100],
                                        elevation: 2, // Add a slight elevation
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical:
                                                8), // Adjust padding as needed
                                        labelStyle: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(
                                  height:
                                      16), // Add spacing below the amenities section
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ShowConnectionsPage(
                            connections: connections,
                            isLoggedIn: isLoggedIn,
                          );
                        }));
                      },
                      icon: const Icon(Icons.power),
                      label: const Text("View Connections")),
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ChargingsPage(
                              is_user: false, stationId: station.id!);
                        }));
                      },
                      icon: const Icon(Icons.reviews),
                      label: const Text("View Chargings")),
                ],
              ),
            ),
    );
  }
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to top
      children: [
        // Only show label if value is not empty (optional
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
        value == ''
            ? const Expanded(
                child: Text(
                "Unknown", // Only show value if not empty
              )) // Only show value if not empty
            : Expanded(child: Text(value)), // Make the value text wrap
      ],
    ),
  );
}
