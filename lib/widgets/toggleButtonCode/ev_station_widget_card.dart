import 'package:ev_vehicle_app/models/ev_station.dart';
import 'package:ev_vehicle_app/pages/station_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EvStationCard extends StatelessWidget {
  final EvStation station;
  final int index;

  const EvStationCard({
    super.key,
    required this.index,
    required this.station,
  });

  String truncateTo30rLess(String input) {
    return input.length <= 30 ? input : input.substring(0, 30);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return StationDetailsPage(
            stationId: station.id!,
          );
        }));
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    station.name != null
                        ? truncateTo30rLess(station.name!.toString())
                        : 'No Name',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('ID: ${station.id}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  RatingBarIndicator(
                    rating: station.rating ?? 0.0,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 20,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                station.addressLine ?? 'No Address',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
