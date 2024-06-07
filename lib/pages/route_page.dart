import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:ev_vehicle_app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({Key? key}) : super(key: key);

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  final locationController = Location();
  final searchRouteStartController = TextEditingController();
  final searchRouteEndController = TextEditingController();
  final LocationService locationService = LocationService();

  final focusNodeRouteStart = FocusNode();
  final focusNodeRouteEnd = FocusNode();

  LatLng? selectedLocation;

  GoogleMapController? controller;

  Set<Marker> markers = <Marker>{};
  List<Polyline> polylines = List<Polyline>.empty(growable: true);
  int selectedRouteIndex = 0;
  int polylineIdCounter = 1;
  Map<String, dynamic> allRoutes = <String, dynamic>{};
  var directionsForRequest = [];
  var latForRequest;
  var lngForRequest;

  LatLng? currentPosition;
  StationProvider? stationProvider;

  LatLng? swBounds;
  LatLng? neBounds;

  double targetLat = 0.0;
  double targetLng = 0.0;
  String waypoints = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      stationProvider = context.read<StationProvider>();

      await fetchLocationUpdates();
      await updateCameraPosition(currentPosition!);

      // await stationProvider!.fetchStations(
      //   latitude: currentPosition!.latitude.toString(),
      //   longitude: currentPosition!.longitude.toString(),
      //   swBounds: swBounds,
      //   neBound: neBounds,
      // );
    });

    super.initState();
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

    try {
      locationController.onLocationChanged.listen((currentLocation) async {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          if (!mounted) return;
          setState(() {
            currentPosition = LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            );
          });
        }
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> updateCameraPosition(LatLng currentPosition) async {
    final newCameraPosition = CameraPosition(
      target: currentPosition,
      zoom: 13,
    );

    await controller?.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    var polylineColors = [
      Colors.red,
      Colors.amber,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.cyan,
      Colors.indigo,
      Colors.lime,
      Colors.green,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey
    ];
    setState(() {
      final String polylineIdVal = 'polyline_$polylineIdCounter';

      polylines.add(
        Polyline(
          polylineId: PolylineId(polylineIdVal),
          onTap: () {
            //_unsetEvMarker();
            if (selectedRouteIndex !=
                int.parse(polylineIdVal.split("_")[1]) - 1) {
              waypointsClear();
            }
            setState(() {
              selectedRouteIndex = int.parse(polylineIdVal.split("_")[1]) - 1;
              // for (var i = 0; i < polylines.length; i++) {
              //   var element = polylines[i];
              //   if (element.polylineId.value == selectedRouteIndex.toString()) {
              //     polylines[i] =
              //         element.copyWith(colorParam: Colors.greenAccent[800]);
              //   }
              // }
            });

            print("all routes ${polylines[selectedRouteIndex].color}");
            print("selected route index $selectedRouteIndex");
            (polylines[selectedRouteIndex].polylineId.value);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Create Route'),
                  content: const Text('Create selected Route?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Perform route creation logic here
                        Navigator.of(context).pop();
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No'),
                    ),
                  ],
                );
              },
            );

            //fetchEvStationsForRoute();

            //showRouteInfo(selectedRouteIndex);
          },
          consumeTapEvents: true,
          width: 8,
          color: polylineColors[polylineIdCounter - 1],
          points: points
              .map(
                (point) => LatLng(point.latitude, point.longitude),
              )
              .toList(),
        ),
      );
      polylineIdCounter++;
    });
  }

  void waypointsClear() {
    setState(() {
      //waypointMarkers.clear();
      waypoints = "";
    });
  }

  void _unsetPolylines() {
    setState(() {
      polylines.clear();
      polylineIdCounter = 1;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StationProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  //   myLocationEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 13,
                  ),
                  onMapCreated: (controller) => this.controller = controller,
                  markers: provider.marker,
                  polylines: Set<Polyline>.from(polylines),
                  minMaxZoomPreference: const MinMaxZoomPreference(5, 22),
                  onCameraIdle: () async {
                    final bounds = await controller!.getVisibleRegion();

                    final zoomLevel = await controller!.getZoomLevel();
                    final center = await controller!.getLatLng(
                      ScreenCoordinate(
                        x: MediaQuery.of(context).size.width ~/ 2,
                        y: MediaQuery.of(context).size.height ~/ 2,
                      ),
                    );

                    swBounds = bounds.southwest;
                    neBounds = bounds.northeast;

                    // await stationProvider!.fetchStations(
                    //   latitude: targetLat.toString(),
                    //   longitude: targetLng.toString(),
                    //   swBounds: swBounds,
                    //   neBound: neBounds,
                    // );

                    // await stationProvider!.setMarkers(
                    //   zoomLevel: zoomLevel,
                    //   centerCoordinates: center,
                    //   context: context,
                    // );
                  },
                  onCameraMove: (CameraPosition position) {
                    targetLat = position.target.latitude;
                    targetLng = position.target.longitude;
                  },
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: SizedBox(
                        height: 50,
                        child: placesAutoCompleteTextField(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: SizedBox(
                        height: 50,
                        child: routeEndAutoCompleteTextField(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        var directions = await LocationService().getDirections(
                          searchRouteStartController.text,
                          searchRouteEndController.text,
                          waypoints,
                        );
                        _unsetPolylines();
                        setState(() {
                          allRoutes = directions;
                        });

                        // _goToPlace(
                        //   allRoutes["routes"][0]['start_location']['lat'],
                        //   allRoutes["routes"][0]['start_location']['lng'],
                        //   allRoutes["routes"][0]['bounds_ne'],
                        //   allRoutes["routes"][0]['bounds_sw'],
                        // );
                        print("TOTAL ROUTES ${allRoutes['routes'].length}");

                        for (var routesIndex = 0;
                            routesIndex < allRoutes['routes'].length;
                            routesIndex++) {
                          directionsForRequest = allRoutes["routes"]
                              [routesIndex]['polyline_decoded'];
                          latForRequest = allRoutes["routes"][routesIndex]
                              ['end_location']['lat'];
                          lngForRequest = allRoutes["routes"][routesIndex]
                              ['end_location']['lng'];

                          _setPolyline(allRoutes["routes"][routesIndex]
                              ['polyline_decoded']);

                          //await fetchEvStationMar();
                          await stationProvider!.fetchStationsForRoute(
                              polyline: directions["routes"][routesIndex]
                                  ['polyline'],
                              distance: 10);
                        }
                      },
                      child: const Text('Find Route'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget placesAutoCompleteTextField() {
    return GooglePlaceAutoCompleteTextField(
      focusNode: focusNodeRouteStart,
      textEditingController: searchRouteStartController,
      googleAPIKey: google_api_key,
      inputDecoration: const InputDecoration(
        hintText: "Search Start of Route",
        fillColor: Colors.white,
        filled: true,
      ),
      debounceTime: 400,
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (prediction) async {
        final latLng = LatLng(
          double.parse(prediction.lat!),
          double.parse(prediction.lng!),
        );

        final newCameraPosition = CameraPosition(
          target: latLng,
          zoom: 13,
        );
        await controller!.animateCamera(
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

  Widget routeEndAutoCompleteTextField() {
    return GooglePlaceAutoCompleteTextField(
      focusNode: focusNodeRouteEnd,
      textEditingController: searchRouteEndController,
      googleAPIKey: google_api_key,
      inputDecoration: const InputDecoration(
        hintText: "Search End of Route",
        fillColor: Colors.white,
        filled: true,
      ),
      debounceTime: 400,
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (prediction) async {
        final latLng = LatLng(
          double.parse(prediction.lat!),
          double.parse(prediction.lng!),
        );

        final newCameraPosition = CameraPosition(
          target: latLng,
          zoom: 13,
        );
        await controller!.animateCamera(
          CameraUpdate.newCameraPosition(newCameraPosition),
        );
      },

      itemClick: (prediction) {
        searchRouteEndController.text = prediction.description!;
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
}
