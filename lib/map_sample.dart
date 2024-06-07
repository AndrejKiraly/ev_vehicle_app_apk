import "dart:async";
import 'dart:convert';

import "package:ev_vehicle_app/models/ev_station_mar.dart";
import "package:ev_vehicle_app/pages/station_details_page.dart";
import 'package:ev_vehicle_app/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import "package:google_maps_flutter/google_maps_flutter.dart";
import 'package:http/http.dart' as http;

import "intent_utils.dart";

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  static final LatLng markerPos1 =
      const LatLng(37.42796133580664, -122.085749655962);
  static final LatLng markerPos2 =
      const LatLng(37.43296265331129, -122.08832357078792);

  Set<Marker> _markers = Set<Marker>();
  Set<Marker> _evMarkers = Set<Marker>();
  Set<Marker> _waypointMarkers = Set<Marker>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  List<Polyline> _polylines = List<Polyline>.empty(growable: true);
  var directionsForRequest = [];
  int selectedRouteIndex = 0;
  var allRoutes = Map<String, dynamic>();
  String waypoints = "";

  var latForRequest;
  var lngForRequest;
  int distance = 3;

  int _polylineIdCounter = 1;

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('marker'),
        position: point,
      ));
    });
  }

  void _unsetMarker() {
    setState(() {
      _markers.remove(_markers.firstWhere(
        (element) => element.markerId.value == 'marker',
      ));
    });
  }

  void _setEvMarker(LatLng point, EvStationMar evStationMar) {
    setState(() {
      _evMarkers.add(Marker(
          markerId: MarkerId('markerEv_${evStationMar.id}'),
          position: point,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          zIndex: 0,
          onTap: () {
            _showEvStationMarInfo(evStationMar);
          }));
    });
  }

  void _unsetEvMarker() {
    setState(() {
      _evMarkers.clear();
    });
  }

  void setStationToWaypoints(EvStationMar evStationMar) {
    setState(() {
      _waypointMarkers.add(Marker(
          markerId: MarkerId('markerWaypoint_${evStationMar.id}'),
          position: LatLng(evStationMar.latitude, evStationMar.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          zIndex: 1,
          onTap: () {
            _showWaypointMarkerInfo(evStationMar);
          }));

      Navigator.of(context).pop();
      _evMarkers.remove(_evMarkers.firstWhere(
        (element) => element.markerId.value == 'markerEv_${evStationMar.id}',
      ));
      waypoints += evStationMar.MarkerTowaypointsString();
      LocationService().getDirections(
          _originController.text, _destinationController.text, waypoints);
    });
  }

  void removeStationFromWaypoints(EvStationMar evStationMar) {
    setState(() {
      _waypointMarkers.remove(_waypointMarkers.firstWhere(
        (element) =>
            element.markerId.value == 'markerWaypoint_${evStationMar.id}',
      ));
      Navigator.of(context).pop();
      _evMarkers.add(Marker(
          markerId: MarkerId('markerEv_${evStationMar.id}'),
          position: LatLng(evStationMar.latitude, evStationMar.longitude),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          onTap: () {
            _showEvStationMarInfo(evStationMar);
          }));
      waypoints =
          waypoints.replaceAll(evStationMar.MarkerTowaypointsString(), "");
      LocationService().getDirections(
          _originController.text, _destinationController.text, waypoints);
    });
  }

  void waypointsClear() {
    setState(() {
      _waypointMarkers.clear();
      waypoints = "";
    });
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final Marker _kGooglePlexMarker = Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: 'Google Plex'),
    icon: BitmapDescriptor.defaultMarker,
    position: markerPos1,
  );

  static final Marker _kLakeMarker = Marker(
    markerId: MarkerId('_kLake'),
    infoWindow: InfoWindow(title: 'Lake'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: markerPos2,
  );

  static final Polyline _kPolyline = Polyline(
      polylineId: PolylineId('kPolyline'),
      points: [
        markerPos1,
        markerPos2,
      ],
      width: 5);

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      //tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();

    //_setMarker(LatLng(37.43296265331129, -122.08832357078792));
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
      final String polylineIdVal = 'polyline_$_polylineIdCounter';

      _polylines.add(
        Polyline(
          polylineId: PolylineId(polylineIdVal),
          onTap: () {
            _unsetEvMarker();
            if (selectedRouteIndex !=
                int.parse(polylineIdVal.split("_")[1]) - 1) {
              waypointsClear();
            }
            setState(() {
              selectedRouteIndex = int.parse(polylineIdVal.split("_")[1]) - 1;
              for (var i = 0; i < _polylines.length; i++) {
                var element = _polylines[i];
                if (element.polylineId.value == selectedRouteIndex.toString()) {
                  _polylines[i] =
                      element.copyWith(colorParam: Colors.greenAccent[800]);
                }
              }
            });
            print("all routes " +
                _polylines[selectedRouteIndex].color.toString());
            print("selected route index " + selectedRouteIndex.toString());
            (_polylines[selectedRouteIndex].polylineId.value);

            fetchEvStationsForRoute();

            showRouteInfo(selectedRouteIndex);
          },
          consumeTapEvents: true,
          width: 8,
          color: polylineColors[_polylineIdCounter - 1],
          points: points
              .map(
                (point) => LatLng(point.latitude, point.longitude),
              )
              .toList(),
        ),
      );
      _polylineIdCounter++;
    });
  }

  void _unsetPolylines() {
    setState(() {
      _polylines.clear();
      _polylineIdCounter = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    controller: _originController,
                    decoration: InputDecoration(hintText: 'Origin'),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                  TextFormField(
                    controller: _destinationController,
                    decoration: InputDecoration(hintText: 'Destination'),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                var directions = await LocationService().getDirections(
                    _originController.text,
                    _destinationController.text,
                    waypoints);
                //start is always same
                _unsetPolylines();
                setState(() {
                  allRoutes = directions;
                });

                _goToPlace(
                  allRoutes["routes"][0]['start_location']['lat'],
                  allRoutes["routes"][0]['start_location']['lng'],
                  allRoutes["routes"][0]['bounds_ne'],
                  allRoutes["routes"][0]['bounds_sw'],
                );
                print("TOTAL ROUTES " + allRoutes['routes'].length.toString());

                for (var routesIndex = 0;
                    routesIndex < allRoutes['routes'].length;
                    routesIndex++) {
                  directionsForRequest =
                      allRoutes["routes"][routesIndex]['polyline_decoded'];
                  latForRequest =
                      allRoutes["routes"][routesIndex]['end_location']['lat'];
                  lngForRequest =
                      allRoutes["routes"][routesIndex]['end_location']['lng'];

                  _setPolyline(
                      allRoutes["routes"][routesIndex]['polyline_decoded']);

                  //await fetchEvStationMar();
                }
                fetchEvStationsForRoute();
              },
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () async {
                var directions = await LocationService().getDirections(
                    _originController.text,
                    _destinationController.text,
                    waypoints);
                await LocationService().getCurrentLocation().then((value) {});
                IntentUtils.launchGoogleMaps(
                  directions['end_location']['lat'],
                  directions['end_location']['lng'],
                );
              },
              icon: const Icon(Icons.navigation),
            ),
          ],
        ),

        /* Row(
            children: [
              Expanded(
                  child: ),
              
            ],
          ), */
        Expanded(
          child: GoogleMap(
            mapType: MapType.normal,
            markers: {..._markers, ..._evMarkers, ..._waypointMarkers},
            polylines: Set<Polyline>.from(_polylines),
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },

            // onTap: (point) {
            //   setState(() {
            //     polygonLatLngs.add(point);
            //     _setPolygon();
            //   });
            // },
          ),
        ),
      ],
    );
  }

  Future<void> _goToPlace(double lat, double lng, Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw) async {
    //final double lat = place['geometry']['location']['lat'];
    //final double lng = place['geometry']['location']['lng'];

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 12),
    ));

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
              northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
          25),
    );

    _setMarker(LatLng(lat, lng));
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<List<EvStationMar>> fetchEvStationsForRoute() async {
    final uri =
        Uri.parse('http://10.0.2.2:3000/planroute').replace(queryParameters: {
      'distance': distance.toString(),
      'polyline': allRoutes["routes"][selectedRouteIndex]['polyline'],
    });
    try {
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        // If the server returns a successful response, parse the JSON
        List<dynamic> data = json.decode(response.body);

        List<EvStationMar> evStationMar = data.map((e) {
          EvStationMar station = EvStationMar.fromJson(e);
          _setEvMarker(
              LatLng(
                station.latitude,
                station.longitude,
              ),
              station); // Add marker for this station

          return station;
        }).toList();

        // Do something with the list of EV stations
        print('EV stations loaded: ${evStationMar.length}');
        return evStationMar;
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load EV stations: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors
      print('Error loading EV stations: $e');
      // Re-throw the exception or return a default value
      throw e;
    }
  }

  void showRouteInfo(int selectedRouteIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Route Info'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Route: ${selectedRouteIndex}'),
              Text(
                  'Distance: ${allRoutes["routes"][selectedRouteIndex]['distance']}'),
              Text(
                  'Duration: ${allRoutes["routes"][selectedRouteIndex]["duration"]}'),
              // Add more information as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showEvStationMarInfo(EvStationMar evStationMar) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(evStationMar.name),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Location: ${evStationMar.addressLine}'),
              Text('Distance: ${evStationMar.distance.toStringAsFixed(2)} km'),
              Text('Rating: ${evStationMar.rating.toStringAsFixed(2)}'),
              // Add more information as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                // Navigate to another page to show detailed information about the station
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StationDetailsPage(stationId: evStationMar.id),
                    ));
              },
              child: Text('More Info', style: TextStyle(fontSize: 12)),
            ),
            TextButton(
                onPressed: () {
                  setStationToWaypoints(evStationMar);
                },
                child: Text('Add to Route', style: TextStyle(fontSize: 12)))
          ],
        );
      },
    );
  }

  _showWaypointMarkerInfo(EvStationMar waypointMarker) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(waypointMarker.name),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Location: ${waypointMarker.addressLine}'),
                Text(
                    'Distance: ${waypointMarker.distance.toStringAsFixed(2)} km'),
                Text('Rating: ${waypointMarker.rating.toStringAsFixed(2)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close', style: TextStyle(fontSize: 12)),
              ),
              TextButton(
                onPressed: () {
                  removeStationFromWaypoints(waypointMarker);
                },
                child:
                    Text('Remove from Route', style: TextStyle(fontSize: 12)),
              )
            ],
          );
        });
  }
}
