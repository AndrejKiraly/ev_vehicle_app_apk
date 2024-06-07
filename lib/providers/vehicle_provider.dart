import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/api_services.dart';
import '../models/vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  final Dio client;
  final ApiService apiService;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  VehicleProvider(this.client) : apiService = ApiService(client);

  late Vehicle _vehicles;
  Vehicle get vehicles => _vehicles;

  Future<Vehicle> fetchVehicles() async {
    final vehicles = await apiService.fetchVehicles();
    _vehicles = vehicles;
    notifyListeners();
    return vehicles;
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      final response = await apiService.addVehicle(vehicle);
      final currentResponse = jsonDecode(response.toString());
      _vehicles = Vehicle.fromJson(currentResponse);
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      final response = await apiService.updateVehicle(vehicle);
      final data = jsonDecode(response.toString());
      _vehicles = Vehicle.fromJson(data);
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
    notifyListeners();
  }
}
