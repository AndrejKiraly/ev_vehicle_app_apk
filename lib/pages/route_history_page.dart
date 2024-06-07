import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteHistoryPage extends StatefulWidget {
  final List<LatLng> travelledPath;
  const RouteHistoryPage({required this.travelledPath, super.key});

  @override
  State<RouteHistoryPage> createState() => _RouteHistoryPageState();
}

class _RouteHistoryPageState extends State<RouteHistoryPage> {
  GoogleMapController? controller;

  Map<PolylineId, Polyline> polylines = {};
  LatLng? routePosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      routePosition = widget.travelledPath.last;
      await generatePolyLineFromPoints(widget.travelledPath);
      controller!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: routePosition!,
          zoom: 13,
        ),
      ));
    });
  }

  Future<void> generatePolyLineFromPoints(
    List<LatLng> polylineCoordinates,
  ) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Route History')),
      body: GoogleMap(
        onMapCreated: (controller) => this.controller = controller,
        initialCameraPosition: CameraPosition(
          target: routePosition!,
          zoom: 13,
        ),
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }
}
