// import "dart:async";
// import 'dart:convert';

// import "package:electric_car_app_mapbox/AdvancedFilterScreen.dart";
// import "package:electric_car_app_mapbox/intent_utils.dart";
// import "package:electric_car_app_mapbox/models/ev_station_mar.dart";
// import "package:electric_car_app_mapbox/pages/station_details_page.dart";
// import 'package:electric_car_app_mapbox/services/location_service.dart';
// import "package:electric_car_app_mapbox/widgets/toggleButtonCode/toggle_radionbutton.dart";
// import 'package:flutter/material.dart';
// import "package:google_maps_flutter/google_maps_flutter.dart";
// import 'package:http/http.dart' as http;

// class EvStationsMap extends StatefulWidget {
//   const EvStationsMap({super.key});

//   @override
//   State<EvStationsMap> createState() => EvStationMapState();
// }

// class EvStationMapState extends State<EvStationsMap> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();
//   final TextEditingController _searchController = TextEditingController();

//   bool _showFilterOptions = false;

//   bool? isFree;
//   bool? isOperational;
//   bool? isMembershipRequired;
//   bool? isPayAtLocation;
//   bool? isAccesKeyRequired;

//   final Set<Marker> _markers = <Marker>{};
//   final Set<Marker> _evMarkers = <Marker>{};

//   //We should these by user location and if doesnt not approve location we should use default values
//   var targetLat = 48.148598;
//   var targetLng = 17.107748;
//   var distance = 1000;
//   var bounds_sw;
//   var bounds_ne;

//   List<EvStationMar> evStationMar = [];

//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );

//   @override
//   void initState() {
//     super.initState();

//     //_setMarker(LatLng(37.43296265331129, -122.08832357078792));
//   }

//   //moze sa v setState zavolat funkcia z marker service?
//   void _setMarker(LatLng point) {
//     setState(() {
//       _markers.add(Marker(
//         markerId: const MarkerId('marker'),
//         position: point,
//         icon: BitmapDescriptor.defaultMarker,
//       ));
//       print(_markers.length);
//     });
//   }

//   void _unsetMarker() {
//     setState(() {
//       if (_markers.isNotEmpty) {
//         _markers.remove(_markers.firstWhere(
//           (element) => element.markerId.value == 'marker',
//         ));
//       }
//     });
//   }

//   void _unsetEvMarker() {
//     setState(() {
//       _evMarkers.clear();
//     });
//   }

//   void _setEvMarker(LatLng point, EvStationMar evStationMar) {
//     setState(() {
//       _evMarkers.add(Marker(
//           markerId: MarkerId('markerEv_${evStationMar.id}'),
//           position: point,
//           icon:
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//           onTap: () {
//             _showEvStationMarInfo(evStationMar);
//           }));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: _searchController,
//                     decoration: const InputDecoration(hintText: 'Place'),
//                     onChanged: (value) {
//                       print(value);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: () async {
//                 var place = await LocationService().getCoordsFromAddress(
//                   _searchController.text,
//                 );
//                 targetLat = place['latitude'];
//                 targetLng = place['longitude'];
//                 _goToPlace(targetLat, targetLng);
//                 _unsetEvMarker();
//                 evStationMar = await fetchEvStationMar();
//               },
//               icon: const Icon(Icons.search),
//             ),
//             IconButton(
//                 onPressed: () async {
//                   var place = await LocationService().getCurrentLocation();
//                   targetLat = place.latitude;
//                   targetLng = place.longitude;
//                   _goToPlace(targetLat, targetLng);
//                   print(place.latitude);
//                   print(place.longitude);
//                   _unsetEvMarker();
//                   evStationMar = await fetchEvStationMar();
//                 },
//                 icon: const Icon(Icons.directions)),
//           ],
//         ),

//         /* Row(
//             children: [
//               Expanded(
//                   child: ),
              
//             ],
//           ), */
//         Expanded(
//           child: Stack(children: [
//             GoogleMap(
//               mapType: MapType.normal,
//               markers: {..._markers, ..._evMarkers},
//               initialCameraPosition: _kGooglePlex,
//               onMapCreated: (GoogleMapController controller) {
//                 _controller.complete(controller);
//               },
//               minMaxZoomPreference: const MinMaxZoomPreference(9, 22),
//               onCameraMove: (CameraPosition position) {
//                 targetLat = position.target.latitude;
//                 targetLng = position.target.longitude;

//                 // print("latitude of camera: ${position.target.latitude}");
//                 // print("longitude of camera: ${position.target.longitude}");
//                 // print("zoom of camera: ${position.zoom}");
//               },
//               onCameraIdle: () async {
//                 _controller.future.then((controller) async {
//                   var zoom = await controller.getZoomLevel();
//                   var bounds = await controller.getVisibleRegion();
//                   bounds_sw = bounds.southwest;
//                   bounds_ne = bounds.northeast;
//                   print(
//                       'bounds_sw: ${bounds_sw.latitude}, ${bounds_sw.longitude}');
//                   print("bounds: $bounds");
//                   print("zoom level: $zoom");
//                 });
//                 _unsetEvMarker();
//                 evStationMar = await fetchEvStationMar();
//                 print("fetching ev stations");
//               },
//             ),
//             _showFilterOptions
//                 ? Positioned(
//                     left: 10,
//                     top: 10,
//                     child: AnimatedContainer(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.5),
//                             spreadRadius: 5,
//                             blurRadius: 7,
//                             offset: const Offset(
//                                 0, 3), // changes position of shadow
//                           ),
//                         ],
//                       ),
//                       duration: const Duration(milliseconds: 200),
//                       width: 260,
//                       child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const Text('Filter Options',
//                                 style: TextStyle(
//                                     fontSize: 20, fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 10),
//                             const Text('Free Charging:'),
//                             Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isFree = null;
//                                         });
//                                       },
//                                       isSelected: isFree == null,
//                                       text: "Both"),
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isFree = true;
//                                         });
//                                       },
//                                       isSelected: isFree == true,
//                                       text: "Free"),
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isFree = false;
//                                         });
//                                       },
//                                       isSelected: isFree == false,
//                                       text: "Paid"),
//                                 ]),
//                             const SizedBox(height: 10),
//                             const Text('Access Key Required:',
//                                 style: TextStyle(fontSize: 16)),
//                             Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isAccesKeyRequired = null;
//                                         });
//                                       },
//                                       isSelected: isAccesKeyRequired == null,
//                                       text: "Both"),
//                                   const SizedBox(width: 6),
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isAccesKeyRequired = true;
//                                         });
//                                       },
//                                       isSelected: isAccesKeyRequired == true,
//                                       text: "Yes"),
//                                   const SizedBox(width: 6),
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isAccesKeyRequired = false;
//                                         });
//                                       },
//                                       isSelected: isAccesKeyRequired == false,
//                                       text: "No"),
//                                 ]),
//                             const SizedBox(height: 10),
//                             const Text('Membership required:',
//                                 style: TextStyle(fontSize: 16)),
//                             Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isMembershipRequired = null;
//                                         });
//                                       },
//                                       isSelected: isMembershipRequired == null,
//                                       text: "Both"),
//                                   const SizedBox(width: 6),
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isMembershipRequired = true;
//                                         });
//                                       },
//                                       isSelected: isMembershipRequired == true,
//                                       text: "Yes"),
//                                   const SizedBox(width: 6),
//                                   ToggleButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           isMembershipRequired = false;
//                                         });
//                                       },
//                                       isSelected: isMembershipRequired == false,
//                                       text: "No"),
//                                 ]),
//                             const SizedBox(height: 10),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     setState(() {
//                                       _showFilterOptions = false;
//                                     });
//                                   },
//                                   child: const Text('Close'),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.of(context).push(
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   AdvancedFilterScreen()));
//                                     },
//                                     child: const Text('Advanced Filter')),
//                               ],
//                             ),
//                             const SizedBox(height: 10),
//                           ]),
//                     ))
//                 : Container(),
//             Positioned(
//               // Adjust right and bottom to position the button as desired
//               left: 20.0,
//               bottom: 20.0,
//               child: FloatingActionButton(
//                 onPressed: () {
//                   setState(() {
//                     _showFilterOptions = !_showFilterOptions;
//                     print('Filter button pressed');
//                   });
//                 },

//                 child: const Icon(Icons.filter_list), // Customize filter icon
//               ),
//             ),
//           ]),
//         ),
//       ],
//     );
//   }

// //when we go to place it doesnt put marker there
//   Future<void> _goToPlace(double lat, double lng) async {
//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(CameraUpdate.newCameraPosition(
//       CameraPosition(target: LatLng(lat, lng), zoom: 13, tilt: 0.0),
//     ));
//     var bounds = await controller.getVisibleRegion();
//     bounds_sw = bounds.southwest;
//     bounds_ne = bounds.northeast;
//     _unsetMarker();
//     _setMarker(LatLng(lat, lng));
//   }

//   Future<List<EvStationMar>> fetchEvStationMar() async {
//     //final String apiUrl = 'http://10.0.2.2:3000/ev_stations?lat=$targetLat&lng=$targetLng&distance=$distance';
//     // print("is free " + isFree.toString());
//     // print("is operational " + isOperational.toString());
//     // print("is membership required " + isMembershipRequired.toString());
//     // print("is pay at location " + isPayAtLocation.toString());
//     // print("is access key required " + isAccesKeyRequired.toString());

//     final uri =
//         Uri.parse('https://electric-vehicle-app.onrender.com/ev_stations')
//             .replace(queryParameters: {
//       'lat': targetLat.toString(),
//       'lng': targetLng.toString(),
//       'bounds_sw':
//           '${bounds_sw.latitude.toString()},${bounds_sw.longitude.toString()}',
//       'bounds_ne':
//           '${bounds_ne.latitude.toString()},${bounds_ne.longitude.toString()}',
//       // 'is_free':
//       //     isFree.toString(), // This will be null if the user doesn't select anything
//       // 'is_membership_required': isMembershipRequired.toString(), // This will be null if the user doesn't select anything
//       // 'is_pay_at_location': isPayAtLocation.toString(), // This will be null if the user doesn't select anything
//       // 'is_access_key_required': isAccesKeyRequired.toString(), // This will be null if the user doesn't select anything
//     });
//     print("this is uri $uri");

//     try {
//       var response = await http.get(uri);

//       if (response.statusCode == 200) {
//         // If the server returns a successful response, parse the JSON
//         List<dynamic> data = json.decode(response.body);
//         //print(data);

//         List<EvStationMar> evStationMar = data.map((e) {
//           EvStationMar station = EvStationMar.fromJson(e);
//           _setEvMarker(
//               LatLng(
//                 station.latitude,
//                 station.longitude,
//               ),
//               station); // Add marker for this station

//           return station;
//         }).toList();

//         // Do something with the list of EV stations
//         print('EV stations loaded: ${evStationMar.length}  ');
//         return evStationMar;
//       } else {
//         // If the server did not return a 200 OK response, throw an exception.
//         throw Exception('Failed to load EV stations: ${response.statusCode}');
//       }
//     } catch (e) {
//       // Handle errors
//       print('Error loading EV stations: $e');
//       // Re-throw the exception or return a default value
//       rethrow;
//     }
//   }

//   void _showEvStationMarInfo(EvStationMar evStationMar) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(evStationMar.name),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Location: ${evStationMar.addressLine}'),
//               Text('Distance: ${evStationMar.distance.toStringAsFixed(2)} km'),
//               Text('Rating: ${evStationMar.rating.toStringAsFixed(2)}'),
//               Text('Free: ${evStationMar.isFree ? 'Yes' : 'No'}'),
//               // Add more information as needed
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('Close', style: TextStyle(fontSize: 12)),
//             ),
//             TextButton.icon(
//               onPressed: () {
//                 IntentUtils.launchGoogleMaps(
//                   evStationMar.latitude,
//                   evStationMar.longitude,
//                 );
//               },
//               icon: const Icon(
//                 Icons.navigation_rounded,
//                 size: 16,
//               ),
//               label: const Text(
//                 'Navigate',
//                 style: TextStyle(fontSize: 12),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Navigate to another page to show detailed information about the station
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           StationDetailsPage(stationId: evStationMar.id),
//                     ));
//               },
//               child: const Text('More Info', style: TextStyle(fontSize: 12)),
//             )
//           ],
//         );
//       },
//     );
//   }
// }
