import 'dart:convert';

import 'package:ev_vehicle_app/models/filter_data.dart';
import 'package:ev_vehicle_app/pages/filter_page.dart';
import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({Key? key}) : super(key: key);

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  final locationController = Location();
  final searchController = TextEditingController();

  final focusNode = FocusNode();

  LatLng? selectedLocation;

  GoogleMapController? controller;

  Set<Marker> markers = <Marker>{};

  LatLng? currentPosition;
  StationProvider? stationProvider;

  LatLng? swBounds;
  LatLng? neBounds;

  double targetLat = 0.0;
  double targetLng = 0.0;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      stationProvider = context.read<StationProvider>();

      await fetchLocationUpdates();

      await Future.delayed(const Duration(seconds: 2), () async {
        await updateCameraPosition(currentPosition!);
      });

      final filterData = await storage.read(key: 'filterData');

      if (filterData == null) {
        await stationProvider!.fetchStations(
          latitude: currentPosition!.latitude.toString(),
          longitude: currentPosition!.longitude.toString(),
          swBounds: swBounds,
          neBound: neBounds,
        );
      } else {
        final filter = FilterData.fromJson(json.decode(filterData));
        final newFilterData = filter.copyWith(
          latitude: currentPosition!.latitude.toString(),
          longitude: currentPosition!.longitude.toString(),
          boundSw:
              '${swBounds!.latitude.toString()},${swBounds!.longitude.toString()}',
          boundsNe:
              '${neBounds!.latitude.toString()},${neBounds!.longitude.toString()}',
        );

        await stationProvider!.filterStations(filterData: newFilterData);
      }

      await stationProvider!.setMarkers(context: context);
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  bool? isFree;
  bool? isAccesKeyRequired;
  bool? isMembershipRequired;
  final bool _showFilterOptions = true;

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
                  minMaxZoomPreference: const MinMaxZoomPreference(9, 22),
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

                    final filterData = await storage.read(key: 'filterData');

                    if (filterData == null) {
                      await stationProvider!.fetchStations(
                        latitude: targetLat.toString(),
                        longitude: targetLng.toString(),
                        swBounds: swBounds,
                        neBound: neBounds,
                      );
                    } else {
                      final filter =
                          FilterData.fromJson(json.decode(filterData));
                      final newFilterData = filter.copyWith(
                        latitude: targetLat.toString(),
                        longitude: targetLng.toString(),
                        boundSw:
                            '${swBounds!.latitude.toString()},${swBounds!.longitude.toString()}',
                        boundsNe:
                            '${neBounds!.latitude.toString()},${neBounds!.longitude.toString()}',
                      );

                      await stationProvider!
                          .filterStations(filterData: newFilterData);
                    }

                    await stationProvider!.setMarkers(
                      zoomLevel: zoomLevel,
                      centerCoordinates: center,
                      context: context,
                    );
                  },
                  onCameraMove: (CameraPosition position) {
                    targetLat = position.target.latitude;
                    targetLng = position.target.longitude;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: SizedBox(
                    height: 50,
                    child: placesAutoCompleteTextField(),
                  ),
                ),
                Positioned(
                  bottom: 90,
                  left: 17,
                  child: FloatingActionButton(
                    onPressed: () => showBottomSheet(context),
                    child: const Icon(Icons.info),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FilterPage(
              latitude: currentPosition!.latitude.toString(),
              longitude: currentPosition!.longitude.toString(),
              swBounds: swBounds,
              neBound: neBounds,
            ),
          ),
        ),

        child: const Icon(Icons.filter_list), // Customize filter icon
      ),
    );
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow scrolling for longer text
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Constrain column height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Information About Stations:',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall, // Use a headline style
              ),
              const SizedBox(height: 10), // Add spacing
              RichText(
                // RichText for styling the link
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(
                      text:
                          'Stations marked with the source "OpenChargeMap" were initially retrieved from the ',
                    ),
                    TextSpan(
                      text: 'OpenChargeMap API',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => launchUrl(
                            Uri.parse('https://openchargemap.org/site')),
                    ),
                    const TextSpan(
                      text:
                          '. Within our system, these stations can be updated. Any stations that have been updated or newly created within our app are designated with the source "From Mobile App."',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget placesAutoCompleteTextField() {
    return GooglePlaceAutoCompleteTextField(
      focusNode: focusNode,
      textEditingController: searchController,
      googleAPIKey: google_api_key,
      inputDecoration: const InputDecoration(
        hintText: "Search your location",
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
        searchController.text = prediction.description!;
        focusNode.unfocus();
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
