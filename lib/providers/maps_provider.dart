import 'package:dio/dio.dart';
import 'package:ev_vehicle_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../api/api_services.dart';

class MapsProvider extends ChangeNotifier {
  final Dio client;
  final ApiService apiService;

  MapsProvider(this.client) : apiService = ApiService(client);

  Map<PolylineId, Polyline> polylines = {};
  LatLng? currentPosition;
  final locationController = Location();
  PolylinePoints polylinePoints = PolylinePoints();

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
//     final coordinates = await fetchPolylinePoints();
//     generatePolyLineFromPoints(coordinates);
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        currentPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      }
    });
  }

  Future<List<LatLng>> fetchPolylinePoints({
    required LatLng initialLocation,
    required LatLng targetLocation,
  }) async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(initialLocation.latitude, initialLocation.longitude),
      PointLatLng(targetLocation.latitude, targetLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    polylines[id] = polyline;
    notifyListeners();
  }

  void _encodeAndSendPolyline(List<LatLng> coordinates) async {
    if (coordinates.isNotEmpty) {
      String encodedPolyline = _encodePolyline(coordinates);
    }
  }

  String _encodePolyline(List<LatLng> coordinates) {
    var encoded = '';
    int lastLat = 0;
    int lastLng = 0;

    for (var point in coordinates) {
      int lat = (point.latitude * 1e5).round();
      int lng = (point.longitude * 1e5).round();

      encoded += _encodePoint(lat - lastLat);
      encoded += _encodePoint(lng - lastLng);

      lastLat = lat;
      lastLng = lng;
    }
    return encoded;
  }

  String _encodePoint(int value) {
    value = value < 0 ? ~(value << 1) : (value << 1);
    var encoded = '';
    while (value >= 0x20) {
      encoded += String.fromCharCode((0x20 | (value & 0x1f)) + 63);
      value >>= 5;
    }
    encoded += String.fromCharCode(value + 63);
    return encoded;
  }
}
