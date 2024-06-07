import 'package:ev_vehicle_app/pages/add_charging_page.dart';
import 'package:ev_vehicle_app/pages/add_station_page.dart';
import 'package:ev_vehicle_app/pages/station_details_page.dart';
import 'package:ev_vehicle_app/pages/stations_list_page.dart';
import 'package:ev_vehicle_app/providers/chargings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ChargingPage extends StatefulWidget {
  final int chargingId;
  final bool is_user;
  const ChargingPage({Key? key, required this.chargingId, this.is_user = false})
      : super(key: key);

  @override
  State<ChargingPage> createState() => _ChargingPageState();
}

class _ChargingPageState extends State<ChargingPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ChargingsProvider>().fetchCharging(widget.chargingId);
    });
    super.initState();
  }

  String truncateTo12OrLess(String input) {
    return input.length <= 12 ? input : input.substring(0, 12);
  }

  @override
  Widget build(BuildContext context) {
    final charging = context.watch<ChargingsProvider>().charging;
    final isLoading = context.watch<ChargingsProvider>().isLoading;
    final errorMessage = context.watch<ChargingsProvider>().errorMessage;
    return Scaffold(
      appBar: AppBar(title: const Text('Charging Page')),
      body: SingleChildScrollView(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage != ""
                  ? Text(errorMessage)
                  : Column(
                      children: [
                        Stack(
                          children: [
                            Card(
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Charging ID: ${charging.id}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            charging.startTime
                                                .toLocal()
                                                .toString()
                                                .split('.')[0],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      leading: const Icon(
                                          Icons.battery_charging_full,
                                          size: 40),
                                    ),
                                    widget.is_user == true
                                        ? ListTile(
                                            title: const Text('Vehicle ID:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            trailing: Text(charging.vehicleId),
                                          )
                                        : Container(),
                                    ListTile(
                                      title: const Text('Battery Level:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: Text(
                                          '${charging.batteryLevelStart}% - ${charging.batteryLevelEnd}%'),
                                    ),
                                    ListTile(
                                      title: const Text('Duration:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: Text(
                                          '${charging.endTime!.difference(charging.startTime).inMinutes} minutes'),
                                    ),
                                    ListTile(
                                      title: const Text('Energy Consumed:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing:
                                          Text('${charging.energyUsed} kWh'),
                                    ),
                                    ListTile(
                                      title: const Text('Cost:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: Text('${charging.price}'),
                                    ),
                                    ListTile(
                                      title: const Text('Coordinates: ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: Text(
                                          "${truncateTo12OrLess(charging.latitude.toString())}, ${truncateTo12OrLess(charging.longitude.toString())}"),
                                    ),
                                    ListTile(
                                      title: const Text('Connection ID:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      trailing: Text(
                                          '${charging.connectionId != -1 ? charging.connectionId : 'Not Assigned'}'),
                                    ),
                                    const SizedBox(height: 16),
                                    if (charging.comment != null &&
                                        charging.comment!.isNotEmpty) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          charging.comment!,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Center contents
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        RatingBar.builder(
                                          initialRating:
                                              charging.rating!.toDouble(),
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          allowHalfRating: false,
                                          itemCount: 5,
                                          itemSize: 30,
                                          ignoreGestures: true,
                                          itemPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 4.0),
                                          itemBuilder: (context, _) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {},
                                        ),
                                      ],
                                    ),
                                    if (charging.connectionId != -1) ...[
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () async {
                                                  final stationId =
                                                      Navigator.of(context)
                                                          .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          StationDetailsPage(
                                                              stationId: charging
                                                                  .evStationId!),
                                                    ),
                                                  );
                                                },
                                                child: Text("Show Station")),
                                          ])
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (widget.is_user == true &&
                                charging.connectionId != -1) ...[
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  padding: const EdgeInsets.all(20),
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddChargingPage(
                                          connectionId: charging.connectionId!,
                                          isEditMode: true,
                                          charging: charging,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ]
                          ],
                        ),
                        if (charging.connectionId == -1) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[300]!,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Problem: Connection not assigned ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      child: const Text('Add Station'),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddStationPage(
                                                    isEditing: false,
                                                    latitudeFromCharging:
                                                        charging.latitude,
                                                    longitudeFromCharging:
                                                        charging.longitude),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      child: const Text('Assign Connection'),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StationsListPage(
                                                    charging: charging),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
        ),
      ),
    );
  }
}
