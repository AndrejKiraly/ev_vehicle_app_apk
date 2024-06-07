import 'dart:math';

import 'package:ev_vehicle_app/constants.dart';
import 'package:ev_vehicle_app/pages/route_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart';

class CreateRoutePage extends StatefulWidget {
  const CreateRoutePage({super.key});

  @override
  State<CreateRoutePage> createState() => _CreateRoutePageState();
}

class _CreateRoutePageState extends State<CreateRoutePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  GoogleMapController? manualEntryController;
  GoogleMapController? recordRouteController;

  Map<PolylineId, Polyline> manualEntryPolylines = {};
  Map<PolylineId, Polyline> recordRoutePolylines = {};

  final searchRouteStartController = TextEditingController();
  final manualEntrySearchRouteEndController = TextEditingController();
  final recordRouteSearchRouteEndController = TextEditingController();

  final focusNodeRouteStart = FocusNode();
  final focusNodeRouteEnd = FocusNode();

  static const googlePlex = LatLng(37.4223, -122.0848);

  LatLng? currentPosition;
  LatLng? initialLocation;
  LatLng? destinationLocation;

  final List<LatLng> travelledPath = [];
  LatLng? lastSavedPosition;
  final double distanceThreshold = 500.0; // meters
  late Location location;
  final locationController = Location();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Text('Manual Entry'),
                Text('Record Route'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                buildManualEntry(),
                buildRecordRoute(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildManualEntry() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) => manualEntryController = controller,
          initialCameraPosition: const CameraPosition(
            target: googlePlex,
            zoom: 13,
          ),
          polylines: Set<Polyline>.of(manualEntryPolylines.values),
        ),
        Column(
          children: [
            const SizedBox(height: 10),
            placesAutoCompleteTextField(),
            const SizedBox(height: 10),
            routeEndAutoCompleteTextField(
              manualEntrySearchRouteEndController,
              manualEntryController,
              'manual',
              initialLocation,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRecordRoute() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            recordRouteController = controller;
            fetchLocationUpdates();
          },
          initialCameraPosition: CameraPosition(
            target: currentPosition ?? googlePlex,
            zoom: 13,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('currentLocation'),
              icon: BitmapDescriptor.defaultMarker,
              position: currentPosition ?? googlePlex,
            ),
          },
          polylines: Set<Polyline>.of(recordRoutePolylines.values),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              routeEndAutoCompleteTextField(
                recordRouteSearchRouteEndController,
                recordRouteController,
                'record',
                currentPosition,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {
                    if (travelledPath.isEmpty) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RouteHistoryPage(
                          travelledPath: travelledPath,
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.route),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget placesAutoCompleteTextField() {
    return GooglePlaceAutoCompleteTextField(
      focusNode: focusNodeRouteStart,
      textEditingController: searchRouteStartController,
      googleAPIKey: google_api_key,
      inputDecoration: const InputDecoration(
        hintText: "Enter inital location",
        fillColor: Colors.white,
        filled: true,
      ),
      debounceTime: 400,
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (prediction) async {
        initialLocation = LatLng(
          double.parse(prediction.lat!),
          double.parse(prediction.lng!),
        );

        final newCameraPosition = CameraPosition(
          target: initialLocation!,
          zoom: 13,
        );
        await manualEntryController!.animateCamera(
          CameraUpdate.newCameraPosition(newCameraPosition),
        );
      },

      itemClick: (prediction) {
        searchRouteStartController.text = prediction.description!;
        focusNodeRouteStart.unfocus();
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

      // default 600 ms ,
    );
  }

  Widget routeEndAutoCompleteTextField(
    TextEditingController searchController,
    GoogleMapController? mapController,
    String polyLineType,
    LatLng? originLocation,
  ) {
    return GooglePlaceAutoCompleteTextField(
      focusNode: focusNodeRouteEnd,
      textEditingController: searchController,
      googleAPIKey: google_api_key,
      inputDecoration: const InputDecoration(
        hintText: "Enter destination location",
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

        final coordinates = await fetchPolylinePoints(
          originLocation!,
          destinationLocation!,
        );
        generatePolyLineFromPoints(coordinates, polyLineType);

        await mapController!.animateCamera(
          CameraUpdate.newCameraPosition(newCameraPosition),
        );
      },

      itemClick: (prediction) {
        searchController.text = prediction.description!;
        focusNodeRouteEnd.unfocus();
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

      // default 600 ms ,
    );
  }

  Future<List<LatLng>> fetchPolylinePoints(
    LatLng initialLocation,
    LatLng desitnationLocation,
  ) async {
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(initialLocation.latitude, initialLocation.longitude),
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
    List<LatLng> polylineCoordinates,
    String polyLineType,
  ) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    if (polyLineType == 'manual') {
      setState(() => manualEntryPolylines[id] = polyline);
    } else {
      setState(() => recordRoutePolylines[id] = polyline);
    }
  }

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

          recordRouteController?.animateCamera(
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
          setState(() {
            travelledPath.add(currentPosition!);
            lastSavedPosition = currentPosition;
          });
        }
      }
      if (currentPosition == destinationLocation) {
        //  showAlertDialog(context); show the alert dialog that the destination has been reached and call the save coordinates API
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
}
