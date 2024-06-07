import 'dart:async';
import 'dart:math';

import 'package:ev_vehicle_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart';

import 'route_history_page.dart';

class RealTimeRoutePage extends StatefulWidget {
  const RealTimeRoutePage({super.key});

  @override
  State<RealTimeRoutePage> createState() => _RealTimeRoutePageState();
}

class _RealTimeRoutePageState extends State<RealTimeRoutePage> {
  final focusNodeRoute = FocusNode();
  final searchRouteController = TextEditingController();

  GoogleMapController? controller;

  final locationController = Location();

  final List<LatLng> travelledPath = [];
  LatLng? lastSavedPosition;
  final double distanceThreshold = 500.0; // meters
  late Location location;

  LatLng? currentPosition;
  LatLng? destinationLocation;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());
  }

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) => this.controller = controller,
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 13,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      icon: BitmapDescriptor.defaultMarker,
                      position: currentPosition!,
                    ),
                  },
                  polylines: Set<Polyline>.of(polylines.values),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    height: 50,
                    child: placesAutoCompleteTextField(),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RouteHistoryPage(
                travelledPath: travelledPath,
              ),
            ),
          );
        },
        child: const Icon(Icons.route),
      ));

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    location = Location();

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

    travelledPath.clear();

    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );

          controller?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentPosition!,
                zoom: 13,
              ),
            ),
          );
        });
      }
      if (lastSavedPosition == null) {
        lastSavedPosition = currentPosition;
        travelledPath.add(currentPosition!);
      } else {
        double distance = calculateDistance(
          lastSavedPosition!.latitude,
          lastSavedPosition!.longitude,
          currentPosition!.latitude,
          currentPosition!.longitude,
        );

        if (distance >= distanceThreshold) {
          print('points added');
          setState(() {
            travelledPath.add(currentPosition!);
            lastSavedPosition = currentPosition;
          });
        }
      }
    });
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // pi / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R * asin... in meters
  }

  Future<List<LatLng>> fetchPolylinePoints(LatLng desitnationLocation) async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(currentPosition!.latitude, currentPosition!.longitude),
      PointLatLng(desitnationLocation.latitude, desitnationLocation.longitude),
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

    setState(() => polylines[id] = polyline);
  }

  Widget placesAutoCompleteTextField() {
    return GooglePlaceAutoCompleteTextField(
      focusNode: focusNodeRoute,
      textEditingController: searchRouteController,
      googleAPIKey: google_api_key,
      inputDecoration: const InputDecoration(
        hintText: "Enter Destination Location",
        fillColor: Colors.white,
        filled: true,
      ),
      debounceTime: 400,
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (prediction) async {
        destinationLocation = LatLng(
          double.parse(prediction.lat!),
          double.parse(prediction.lng!),
        );

        final newCameraPosition = CameraPosition(
          target: destinationLocation!,
          zoom: 13,
        );

        final coordinates = await fetchPolylinePoints(destinationLocation!);
        generatePolyLineFromPoints(coordinates);

        await controller!.animateCamera(
          CameraUpdate.newCameraPosition(newCameraPosition),
        );
      },
      itemClick: (prediction) {
        searchRouteController.text = prediction.description!;
        focusNodeRoute.unfocus();
      },
      seperatedBuilder: const Divider(),
      containerHorizontalPadding: 10,
      itemBuilder: (context, index, Prediction prediction) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(
                width: 7,
              ),
              Expanded(child: Text(prediction.description ?? ""))
            ],
          ),
        );
      },
      isCrossBtnShown: true,
    );
  }
}
