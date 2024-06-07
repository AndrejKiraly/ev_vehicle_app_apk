import 'dart:convert' as convert;

import 'package:ev_vehicle_app/constants.dart';
import 'package:ev_vehicle_app/models/route_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<Map<String, dynamic>> getCoordsFromAddress(String input) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$input&key=$google_api_key';
      var response = await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);

      var longitude = json['results'][0]['geometry']['location']['lng'];
      var latitude = json['results'][0]['geometry']['location']['lat'];

      var place = {'latitude': latitude, 'longitude': longitude};
      return place;
    } catch (e) {
      var place = {'latitude': 48.212112, 'longitude': 17.154521};
      return place;
    }
  }

  Future<Map<String, dynamic>> getAddressFromLatLng(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat%2C$lng&key=$google_api_key';
      var response = await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);

      String address = json['results'][0]['address_components'][1]
              ['long_name'] +
          ' ' +
          json['results'][0]['address_components'][0]['long_name'];
      var city = json['results'][0]['address_components'][2]['long_name'];
      var country = json['results'][0]['address_components'][5]['long_name'];
      var postcode = json['results'][0]['address_components'][6]['long_name'];

      var place = {
        'address': address,
        'city': city,
        'country': country,
        'postcode': postcode
      };
      return place;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error getting address from coordinates'),
        ),
      );
      return {};
    }
  }

  Future<Map<String, dynamic>> getPlace(String input) async {
    //final placeId = await getPlaceId(input);
    //final String url =
    //'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$google_api_key';
    //var response = await http.get(Uri.parse(url));
    //var json = convert.jsonDecode(response.body);
    // var results = json['result'] as Map<String, dynamic>;

    //print(results);
    return {};
  }

  Future<Map<String, dynamic>> getDirections(
      String origin, String destination, String waypoints) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?destination=$destination&origin=$origin&key=$google_api_key&alternatives=true&waypoints=$waypoints';
    var response = await http.get(Uri.parse(url));
    var json = convert.jsonDecode(response.body);

    if (json["routes"] != null && json["routes"].length == 0) {
      return {"error": "No routes found"};
    }

    var result = {"routes": []};
    for (int routeIndex = 0; routeIndex < json["routes"].length; routeIndex++) {
      result["routes"]!.add({
        "bounds_ne": json['routes'][routeIndex]['bounds']['northeast'],
        "bounds_sw": json['routes'][routeIndex]['bounds']['southwest'],
        "start_location": json['routes'][routeIndex]['legs'][0]
            ['start_location'],
        "end_location": json['routes'][routeIndex]['legs'][0]['end_location'],
        "polyline": json['routes'][routeIndex]['overview_polyline']['points'],
        "distance": json['routes'][routeIndex]['legs'][0]['distance']['text'],
        "duration": json['routes'][routeIndex]['legs'][0]['duration']['text'],
        "polyline_decoded": PolylinePoints().decodePolyline(
            json['routes'][routeIndex]['overview_polyline']['points']),
        'polyline_encoded': json['routes'][routeIndex]['overview_polyline']
            ['points'],
      });
    }

    // var results = {
    //   'bounds_ne': json['routes'][0]['bounds']['northeast'],
    //   'bounds_sw': json['routes'][0]['bounds']['southwest'],
    //   'start_location': json['routes'][0]['legs'][0]['start_location'],
    //   'end_location': json['routes'][0]['legs'][0]['end_location'],
    //   'polyline': json['routes'][0]['overview_polyline']['points'],
    //   'polyline_decoded': PolylinePoints()
    //       .decodePolyline(json['routes'][0]['overview_polyline']['points']),
    // };

    print("polyline  $result");
    return result;
  }

  final routeRequest = RouteRequest(
    origin: Origin(
      location: Loc(
        latLng: LatLong(
          latitude: 37.7749,
          longitude: -122.4194,
        ),
      ),
    ),
    destination: Destination(
      location: Loc(
        latLng: LatLong(
          latitude: 37.8199,
          longitude: -122.4783,
        ),
      ),
    ),
    intermediates: [],
  );

  Future<void> getRoutes({
    required LatLng initialLocation,
    required LatLng destinationLocation,
    List<LatLong>? wayPoints,
  }) async {
    final routeRequest = RouteRequest(
      origin: Origin(
        location: Loc(
          latLng: LatLong(
            latitude: initialLocation.latitude,
            longitude: initialLocation.longitude,
          ),
        ),
      ),
      destination: Destination(
        location: Loc(
          latLng: LatLong(
            latitude: destinationLocation.latitude,
            longitude: destinationLocation.longitude,
          ),
        ),
      ),
      intermediates: wayPoints != null
          ? wayPoints
              .map(
                (wayPoint) => Destination(
                  location: Loc(
                    latLng: wayPoint,
                  ),
                ),
              )
              .toList()
          : [],
    );

    try {
      final routeData = convert.jsonEncode(routeRequest.toJson());
      const String url =
          'https://routes.googleapis.com/directions/v2:computeRoutes';

      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': google_api_key,
        'X-Goog-FieldMask':
            'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline'
      };

      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: routeData,
      );
      var json = convert.jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
