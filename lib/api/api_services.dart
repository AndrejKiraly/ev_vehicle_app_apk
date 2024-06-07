import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ev_vehicle_app/api/endpoints.dart';
import 'package:ev_vehicle_app/enums/amenities_types_class.dart';
import 'package:ev_vehicle_app/enums/connection_types_class.dart';
import 'package:ev_vehicle_app/enums/countries_class.dart';
import 'package:ev_vehicle_app/enums/current_type_class.dart';
import 'package:ev_vehicle_app/enums/usage_type_class.dart';
import 'package:ev_vehicle_app/models/charging.dart';
import 'package:ev_vehicle_app/models/enode_vehicle.dart';
import 'package:ev_vehicle_app/models/ev_connection.dart';
import 'package:ev_vehicle_app/models/ev_station_mar.dart';
import 'package:ev_vehicle_app/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/ev_station.dart';
import '../models/filter_data.dart';
import '../providers/login_provider.dart';

class ApiService {
  final Dio _client;

  ApiService(this._client);

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        print(response.headers['access-token']);
        final accessToken = response.headers['access-token']![0];
        final uid = response.headers['uid']![0];
        final client = response.headers['client']![0];
        final expiry = response.headers['expiry']![0];
        final tokenType = response.headers['token-type']![0];
        final authorization = response.headers['authorization']![0];
        final email = response.data['data']['email'];
        final name = response.data['data']['name'];
        final username = response.data['data']['username'];
        final isAdmin = response.data['data']['is_admin'];

        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'isLoggedIn', value: 'true');
        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'token_type', value: tokenType);
        await secureStorage.write(key: 'expiry', value: expiry);
        await secureStorage.write(key: 'authorization', value: authorization);
        await secureStorage.write(key: 'client', value: client);
        await secureStorage.write(key: 'uid', value: uid);
        await secureStorage.write(key: 'email', value: email);
        await secureStorage.write(key: 'username', value: username);
        await secureStorage.write(key: 'name', value: name);
        await secureStorage.write(
          key: 'isAdmin',
          value: isAdmin.toString(),
        );

        if (await secureStorage.read(key: 'isLoggedIn') == 'true') {
          context.read<LoginProvider>().login();
        }
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<void> register(
      String email,
      String password,
      String passwordConfirmation,
      String name,
      String username,
      BuildContext context) async {
    try {
      final response = await _client.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'name': name,
          'username': username,
        },
      );

      if (response.statusCode == 200) {
        print(response.headers['access-token']);
        final accessToken = response.headers['access-token']![0];
        final uid = response.headers['uid']![0];
        final client = response.headers['client']![0];
        final expiry = response.headers['expiry']![0];
        final tokenType = response.headers['token-type']![0];
        final authorization = response.headers['authorization']![0];
        final email = response.data['data']['email'];
        final name = response.data['data']['name'];
        final isAdmin = response.data['data']['admin'];
        final username = response.data['data']['username'];

        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'isLoggedIn', value: 'true');
        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'token_type', value: tokenType);
        await secureStorage.write(key: 'expiry', value: expiry);
        await secureStorage.write(key: 'authorization', value: authorization);
        await secureStorage.write(key: 'client', value: client);
        await secureStorage.write(key: 'uid', value: uid);
        await secureStorage.write(key: 'email', value: email);
        await secureStorage.write(key: 'username', value: username);
        await secureStorage.write(
          key: 'name',
          value: name,
        );

        await secureStorage.write(
          key: 'isAdmin',
          value: isAdmin.toString(),
        );
        if (await secureStorage.read(key: 'isLoggedIn') == 'true') {
          context.read<LoginProvider>().login();
        }
      } else {
        throw Exception('Failed to login');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final response = await _client.delete(ApiEndpoints.logout);
      if (response.statusCode != 200) {
        throw Exception('Failed to logout');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  //STATIONS

  Future<List<EvStationMar>> fetchStations({
    required String latitude,
    required String longitude,
    LatLng? swBounds,
    LatLng? neBound,
    List<UsageType>? usageTypes,
    List<Amenity>? amenities,
    bool? isFree,
    List<CurrentType>? currentTypes,
    List<ConnectionType>? connectionTypes,
    int? power,
    int? rating,
  }) async {
    try {
      final params = {
        'lat': latitude,
        'lng': longitude,
        'bounds_sw':
            '${swBounds!.latitude.toString()},${swBounds.longitude.toString()}',
        'bounds_ne':
            '${neBound!.latitude.toString()},${neBound.longitude.toString()}',
        'power_kw': power.toString(),
        'usage_type_ids[]': usageTypes!.map((e) => e.id).toList(),
        'amenity_ids[]': amenities!.map((e) => e.id).toList(),
        'is_free': isFree,
        'current_type_id[]': currentTypes!.map((e) => e.id).toList(),
        'connection_type_ids[]': connectionTypes!.map((e) => e.id).toList(),
        'connection_jebat_ids[]': [1, 2, 3],
        'rating': rating.toString(),
      };
      print(params);
      final response = await _client.get(
        ApiEndpoints.stations,
        queryParameters: params,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => EvStationMar.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch stations');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> fetchStationDetail({required int stationId}) async {
    try {
      final response = await _client.get('${ApiEndpoints.stations}/$stationId');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to fetch station detail');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<List<EvStation>> fetchStationsForCharging(Charging charging) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.chargings}/${charging.id}/nearby_ev_stations',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => EvStation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch stations for charging');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<List<EvStationMar>> fetchEvStationsForRoute(
      String polyline, int? distance) async {
    try {
      var response = await _client.get(
        '/planroute',
        queryParameters: {
          'distance': distance.toString(),
          'polyline': polyline,
        },
      );

      if (response.statusCode == 200) {
        // If the server returns a successful response, parse the JSON
        final List<dynamic> data = response.data;
        return data.map((json) => EvStationMar.fromJson(json)).toList();
      } else {
        // If the server returns an error response, throw an exception.
        throw Exception('Failed to fetch stations for route');
      }
    } catch (e) {
      // If the server returns an error response, throw an exception.
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> addStation(EvStation evStation) async {
    final stationData = json.encode(evStation.toJson());
    try {
      final response = await _client.post(
        ApiEndpoints.stations,
        data: stationData,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add station');
      }

      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> updateStation(EvStation evStation) async {
    final stationData = json.encode(evStation.toJson());
    try {
      final response = await _client.patch(
        '${ApiEndpoints.stations}/${evStation.id}',
        data: stationData,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update station');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> deleteStation(int stationId) async {
    try {
      final response = await _client.delete(
        '${ApiEndpoints.stations}/$stationId',
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete station');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> fetchUserStations(int selectedPage) async {
    try {
      final response =
          await _client.get('${ApiEndpoints.userStations}/$selectedPage');

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch user stations');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  //CONNECTIONS

  // Future<List<EvConnection>> fetchConnections() async {
  //   try {
  //     final response = await _client.get(ApiEndpoints.connections);

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = response.data;
  //       return data.map((json) => EvConnection.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to fetch Connections');
  //     }
  //   } catch (e) {
  //     debugPrint('Error $e');
  //     rethrow;
  //   }
  // }

  Future<List<EvConnection>> fetchConnections(int stationId) async {
    List<EvConnection> connections = [];
    try {
      final response =
          await _client.get('${ApiEndpoints.stations}/$stationId/connections');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        for (var i = 0; i < data.length; i++) {
          connections.add(EvConnection.fromJson(data[i]));
        }
        return connections;
      } else {
        throw Exception('Failed to fetch Connections');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> addConnection(EvConnection evConnection) async {
    final connectionData = json.encode(evConnection.toJson());
    try {
      final response = await _client.post(
        ApiEndpoints.connections,
        data: connectionData,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add station');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> updateConnection(EvConnection evConnection) async {
    final connectionData = json.encode(evConnection.toJson());
    try {
      final response = await _client.patch(
        '${ApiEndpoints.connections}/${evConnection.id}',
        data: connectionData,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update connection');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> deleteConnection(int connectionId) async {
    try {
      final response = await _client.delete(
        '${ApiEndpoints.connections}/$connectionId',
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete connection');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Vehicle> fetchVehicles() async {
    try {
      final response = await _client.get(ApiEndpoints.vehicles);

      if (response.statusCode == 200) {
        return Vehicle.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch vehicles');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Vehicle> addVehicle(vehicle) async {
    final vehicleData = json.encode(vehicle.toJson());
    try {
      final response = await _client.post(
        ApiEndpoints.vehicles,
        data: vehicleData,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add vehicle');
      }
      return Vehicle.fromJson(response.data);
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Vehicle> updateVehicle(vehicle) async {
    final vehicleData = json.encode(vehicle.toJson());
    try {
      final response = await _client.patch(
        '${ApiEndpoints.vehicles}/${vehicle.vehicleId}',
        data: vehicleData,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update vehicle');
      }
      return Vehicle.fromJson(response.data);
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<List<EnodeVehicle>> fetchEnodeVehicles() async {
    List<EnodeVehicle> enodeVehicles = [];
    try {
      final response = await _client.get(
        '${ApiEndpoints.enodeVehicles}/user',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        for (var i = 0; i < data.length; i++) {
          enodeVehicles.add(EnodeVehicle.fromJson(data[i]));
        }
        print(enodeVehicles);
        return enodeVehicles;
      } else {
        throw Exception('Failed to fetch vehicles');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> linkEnodeVehicle() async {
    try {
      final response = await _client.post(
        ApiEndpoints.enodeVehicles,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        return data;
      } else {
        throw Exception('Failed to link a vehicle');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<EnodeVehicle> fetchEnodeVehicle(String vehicleId) async {
    EnodeVehicle enodeVehicle = EnodeVehicle.emptyEnodeVehicle();
    try {
      final response = await _client.get(
        '${ApiEndpoints.enodeVehicles}/$vehicleId',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        enodeVehicle = EnodeVehicle.fromJson(data);
        return enodeVehicle;
      } else {
        throw Exception('Failed to fetch vehicle');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<void> unlinkEnodeIntegration() async {
    try {
      final response = await _client.delete(
        ApiEndpoints.enodeVehicles,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unlink vehicle');
      }
      return;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<List<Charging>> fetchUserChargings() async {
    List<Charging> chargings = [];
    try {
      final response = await _client.get(
        ApiEndpoints.chargings,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        for (var i = 0; i < data.length; i++) {
          chargings.add(Charging.fromJson(data[i]));
        }
        return chargings;
      } else {
        throw Exception('Failed to fetch chargings');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> updateChargingConnection(
      int chargingId, int connectionId) async {
    try {
      final response = await _client.patch(
        '${ApiEndpoints.chargings}/$chargingId',
        data: {
          'connection_id': connectionId,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update charging connection');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<List<Charging>> fetchStationsChargings(int stationId) async {
    List<Charging> chargings = [];
    try {
      final response = await _client.get(
        '${ApiEndpoints.stations}/$stationId/chargings',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        for (var i = 0; i < data.length; i++) {
          chargings.add(Charging.fromJson(data[i]));
        }
        return chargings;
      } else {
        throw Exception('Failed to fetch chargings');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Charging> fetchCharging(int chargingId) async {
    Charging charging = Charging.emptyCharging();
    try {
      final response = await _client.get(
        '${ApiEndpoints.chargings}/$chargingId',
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        charging = Charging.fromJson(data);
        return charging;
      } else {
        throw Exception('Failed to fetch charging');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> addCharging(Charging charging) async {
    final chargingData = json.encode(charging.toJson());
    try {
      final response = await _client.post(
        ApiEndpoints.chargings,
        data: chargingData,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add charging');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> updateCharging(Charging charging) async {
    final chargingData = json.encode(charging.toJson());
    try {
      final response = await _client.patch(
        '${ApiEndpoints.chargings}/${charging.id}',
        data: chargingData,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update charging');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> deleteCharging(int chargingId) async {
    try {
      final response = await _client.delete(
        '${ApiEndpoints.chargings}/$chargingId',
      );
      if (response.statusCode != 204) {
        throw Exception('Failed to delete charging');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> fetchChargingsMonthlySummary(int year, int month) async {
    try {
      final response = await _client.get(
        '${ApiEndpoints.chargings}/monthly/$year/$month',
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch chargings');
      }
      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<List<EvStationMar>> filterStations({
    required FilterData filterData,
  }) async {
    try {
      final filterParams = filterData.toJson();

      print(filterParams);

      final response = await _client.get(
        ApiEndpoints.stations,
        queryParameters: filterParams,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data;

        return data.map((json) => EvStationMar.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch stations');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> generateStations(Country selectedCountry) async {
    try {
      final response = await _client.post(
        '${ApiEndpoints.stations}/multiple',
        queryParameters: {
          'countrycode': selectedCountry.isoCode,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
            'Failed to generate stations #${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> changePassword(
    String password,
    String currentPassword,
    String passwordConfirmation,
  ) async {
    try {
      final response = await _client.patch(
        '/auth',
        data: {
          'password': password,
          'current_password': currentPassword,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }

  Future<Response> changeProfileInformation(
      String name, String username) async {
    try {
      final response = await _client.patch(
        '/auth',
        data: {
          'name': name,
          'username': username,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(key: 'name', value: name);
        await secureStorage.write(key: 'username', value: username);
      } else {
        throw Exception('Failed to change profile information');
      }

      return response;
    } catch (e) {
      debugPrint('Error $e');
      rethrow;
    }
  }
}
