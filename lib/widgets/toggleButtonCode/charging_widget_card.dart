import 'package:flutter/material.dart';
import 'package:ev_vehicle_app/models/charging.dart';
import 'package:ev_vehicle_app/pages/add_station_page.dart';
import 'package:ev_vehicle_app/pages/charging_page.dart';
import 'package:ev_vehicle_app/pages/stations_list_page.dart';
import 'package:ev_vehicle_app/providers/chargings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ChargingCard extends StatelessWidget {
  final Charging charging;
  final bool is_user;
  final int index;

  const ChargingCard({
    required this.charging,
    this.is_user = false,
    required this.index,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Stack(children: [
        ListTile(
          contentPadding: const EdgeInsets.all(16),
          tileColor:
              charging.connectionId != -1 ? Colors.green[100] : Colors.red[100],
          leading: const Icon(Icons.battery_charging_full, size: 40),
          title: Text(
            'Charging ID: ${charging.id}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Duration: ${charging.endTime!.difference(charging.startTime).inMinutes} minutes',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Started: ${charging.startTime?.toLocal().toString().split('.')[0]}',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wallet, size: 16),
                      const SizedBox(width: 4),
                      Text('Cost: ${charging.price} €'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.battery_charging_full, size: 16),
                      const SizedBox(width: 4),
                      Text('Energy:${charging.energyUsed} kWh'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: charging.rating!.toDouble(),
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemSize: 20,
                    ignoreGestures: true,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      print(rating);
                    },
                  ),
                ],
              ),
              if (charging.comment != null && charging.comment!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Comment: ${charging.comment!.length > 50 ? charging.comment!.substring(0, 50) + '...' : charging.comment}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ],
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return ChargingPage(
                chargingId: charging.id,
                is_user: is_user,
              );
            }));
          },
        ),
        Positioned(
          // Position the delete button at the top right
          top: 8,
          right: 8,
          child: is_user
              ? IconButton(
                  icon: const Icon(Icons.delete,
                      size: 26, color: Colors.black), // X icon
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Charging'),
                          content: const Text(
                              'Are you sure you want to delete this charging?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                try {
                                  Provider.of<ChargingsProvider>(context,
                                          listen: false)
                                      .deleteCharging(charging.id, index);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text('Charging deleted!'),
                                  ));
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text('Error deleting charging!'),
                                  ));
                                }
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
              : const SizedBox(),
        ),
      ]),
    );
  }
}
