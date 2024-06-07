import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:ev_vehicle_app/enums/amenities_types_class.dart';
import 'package:ev_vehicle_app/enums/connection_types_class.dart';
import 'package:ev_vehicle_app/enums/countries_class.dart';
import 'package:ev_vehicle_app/enums/current_type_class.dart';
import 'package:ev_vehicle_app/enums/usage_type_class.dart';
import 'package:ev_vehicle_app/models/charging.dart';
import 'package:ev_vehicle_app/models/ev_station_mar.dart';
import 'package:ev_vehicle_app/models/filter_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vector_math/vector_math.dart' as vector_math;

import '../api/api_services.dart';
import '../intent_utils.dart';
import '../models/ev_station.dart';
import '../pages/station_details_page.dart';

class StationProvider extends ChangeNotifier {
  final Dio client;
  final ApiService apiService;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  StationProvider(this.client) : apiService = ApiService(client);

  final List<EvStation> _evStation = [];
  List<EvStation> get evStation => UnmodifiableListView(_evStation);

  final List<EvStationMar> _evStationMar = [];
  List<EvStationMar> get evStationMar => UnmodifiableListView(_evStationMar);

  final Set<Marker> _markers = <Marker>{};
  Set<Marker> get marker => UnmodifiableSetView(_markers);

  final List<Amenity> _amenities = [];
  List<Amenity> get amenities => UnmodifiableListView(_amenities);

  final List<UsageType> _usageTypes = [];
  final List<Amenity> _filteredAmenities = [];
  bool? _isFree;
  bool? get isFree => _isFree;

  final List<CurrentType> _currentTypes = [];
  final List<ConnectionType> _connectionTypes = [];

  int _rating = 0;
  int get rating => _rating;
  int _power = 0;
  int get power => _power;

  List<Amenity> get filteredAmenitiesList =>
      UnmodifiableListView(_filteredAmenities);
  List<UsageType> get usageTypes => UnmodifiableListView(_usageTypes);
  List<CurrentType> get currentTypes => UnmodifiableListView(_currentTypes);
  List<ConnectionType> get connectionTypes =>
      UnmodifiableListView(_connectionTypes);

  final List<Amenity> _selectedAmenities = [];
  List<Amenity> get selectedAmenities =>
      UnmodifiableListView(_selectedAmenities);

  Future<void> fetchAmenities() async {
    _amenities.clear();
    clearAmenities();
    const amenities = Amenity.amenityValues;
    _amenities.addAll(amenities);
    notifyListeners();
  }

  void toggleAmenity(Amenity amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
      notifyListeners();
    } else {
      _selectedAmenities.add(amenity);
      notifyListeners();
    }
  }

  void clearAmenities() {
    _selectedAmenities.clear();
    notifyListeners();
  }

  Future<void> fetchStations({
    required String latitude,
    required String longitude,
    LatLng? swBounds,
    LatLng? neBound,
  }) async {
    _evStationMar.clear();
    notifyListeners();
    final stations = await apiService.fetchStations(
      latitude: latitude,
      longitude: longitude,
      swBounds: swBounds,
      neBound: neBound,
      usageTypes: _usageTypes,
      amenities: _filteredAmenities,
      isFree: _isFree,
      currentTypes: _currentTypes,
      connectionTypes: _connectionTypes,
      rating: _rating,
      power: _power,
    );
    _evStationMar.addAll(stations);
    notifyListeners();
  }

  Future<void> fetchStationsForRoute(
      {int? distance, required String polyline}) async {
    _evStationMar.clear();
    notifyListeners();
    final stations =
        await apiService.fetchEvStationsForRoute(polyline, distance);
    _evStationMar.addAll(stations);
    notifyListeners();
  }

  Future<void> setMarkers({
    double? zoomLevel,
    LatLng? centerCoordinates,
    required BuildContext context,
  }) async {
    _markers.clear();
    notifyListeners();
    for (var station in _evStationMar) {
      _markers.add(
        Marker(
          markerId: MarkerId(station.id.toString()),
          icon: BitmapDescriptor.defaultMarker,
          position: LatLng(station.latitude, station.longitude),
          onTap: () => showEvStationMarInfo(station, context),
        ),
      );
    }
    notifyListeners();
//     }
  }

  // Function to calculate distance between two points using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final dLat = vector_math.radians(lat2 - lat1);
    final dLon = vector_math.radians(lon2 - lon1);
    final a = pow(sin(dLat / 2), 2) +
        cos(vector_math.radians(lat1)) *
            cos(vector_math.radians(lat2)) *
            pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<int?> addStation(EvStation evStation, BuildContext context) async {
    try {
      final response = await apiService.addStation(evStation);

      if (response.statusCode == 200) {
        SnackBar snackBar = const SnackBar(
          content: Text('Station added successfully'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }

      _evStation.add(EvStation.fromJson(response.data));

      notifyListeners();
      return await response.data['id'];
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<void> fetchUserStations(int selectedPage) async {
    try {
      _evStation.clear();
      _isLoading = true;
      notifyListeners();
      final response = await apiService.fetchUserStations(selectedPage);
      final stations = response.data
          .map<EvStation>((station) => EvStation.fromJson(station))
          .toList();
      _evStation.addAll(stations);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch stations: $error';
      notifyListeners();
    }
  }

  Future<void> updateStation(EvStation evStation, BuildContext context) async {
    try {
      final response = await apiService.updateStation(evStation);
      if (response.statusCode == 200) {
        SnackBar snackBar = const SnackBar(
          content: Text('Station updated successfully'),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        notifyListeners();
      }
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<void> generateStations(Country country, BuildContext context) async {
    try {
      _evStation.clear();
      _isLoading = true;
      notifyListeners();
      final response = await apiService.generateStations(country);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'].toString()),
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch stations: $error';
      notifyListeners();
    }
  }

  Future<void> deleteStation(int id, BuildContext context) async {
    try {
      final response = await apiService.deleteStation(id);
      if (response.statusCode == 200) {
        SnackBar snackBar = const SnackBar(
          content: Text('Station deleted successfully'),
        );
        _evStation.removeWhere((station) => station.id == id);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        notifyListeners();
      }
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  void removeStation(int index) {
    _evStation.removeAt(index);
    notifyListeners();
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Colors.grey[300]!, width: 1)), // Add bottom border
      ),
      child: ListTile(
        leading: Icon(icon, size: 24),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        contentPadding: EdgeInsets.zero, // Remove ListTile's default padding
        dense: true, // Make the ListTile more compact
      ),
    );
  }

  void showEvStationMarInfo(EvStationMar evStationMar, context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evStationMar.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                _buildDetailTile(
                    Icons.location_on, 'Location:', evStationMar.addressLine),
                _buildDetailTile(Icons.star, 'Rating:',
                    evStationMar.rating.toStringAsFixed(2)),
                _buildDetailTile(Icons.room_outlined, "distance",
                    "${evStationMar.distance.toStringAsFixed(2)} km"),
                _buildDetailTile(Icons.attach_money, 'Free:',
                    evStationMar.isFree ? 'Yes' : 'No'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        IntentUtils.launchGoogleMaps(
                            evStationMar.latitude, evStationMar.longitude);
                      },
                      icon: const Icon(Icons.navigation_rounded),
                      label: const Text('Navigate'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final response = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StationDetailsPage(stationId: evStationMar.id),
                          ),
                        );

                        if (response != null) {
                          await fetchStations(
                            latitude: evStationMar.latitude.toString(),
                            longitude: evStationMar.toString(),
                          );
                          notifyListeners();
                        }
                      },
                      child: const Text('More Info'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Helper function to create detail tiles with borders

  Future<void> fetchStationsForCharging(Charging charging) async {
    try {
      _evStation.clear();
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      final stations = await apiService.fetchStationsForCharging(charging);
      _evStation.addAll(stations);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch stations: $error';
      notifyListeners();
    }
  }

  Future<void> clearFilter() async {
    _filteredAmenities.clear();
    _usageTypes.clear();
    _currentTypes.clear();
    _connectionTypes.clear();
    _isFree = null;
    _rating = 0;
    _power = 0;
    _evStationMar.clear();
    notifyListeners();
  }

  Future<void> filterStations({required FilterData filterData}) async {
    const storage = FlutterSecureStorage();
    try {
      _evStationMar.clear();
      _isLoading = true;
      notifyListeners();
      final stations = await apiService.filterStations(filterData: filterData);
      await storage.write(
          key: 'filterData', value: jsonEncode(filterData.toJson()));

      _evStationMar.addAll(stations);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch stations: $error';
      notifyListeners();
    }
  }
}
