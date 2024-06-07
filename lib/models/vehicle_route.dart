import 'package:google_maps_flutter/google_maps_flutter.dart';

class Route {
  int? id;
  int userId;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final List<LatLng> stops;
  final double approximatedDistance;
  final double approximatedDuration;
  final double actualDuration;
  final double actualDistance;

  Route({
    this.id,
    required this.userId,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.approximatedDistance,
    required this.approximatedDuration,
    required this.actualDuration,
    required this.actualDistance,
    this.stops = const [],
  });
}
