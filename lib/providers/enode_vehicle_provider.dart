import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/api_services.dart';
import '../models/enode_vehicle.dart';

class EnodeVehicleProvider extends ChangeNotifier {
  final Dio client;
  final ApiService apiService;

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  EnodeVehicleProvider(this.client) : apiService = ApiService(client);

  List<EnodeVehicle> _enodeVehicles = [];
  List<EnodeVehicle> get enodeVehicles => _enodeVehicles;

  EnodeVehicle _enodeVehicle = EnodeVehicle.emptyEnodeVehicle();
  EnodeVehicle get enodeVehicle => _enodeVehicle;

  Future<List<EnodeVehicle>> fetchEnodeVehicles() async {
    try {
      _enodeVehicles.clear();
      _isLoading = true;
      notifyListeners();

      final enodeVehicles = await apiService.fetchEnodeVehicles();
      _isLoading = false;
      _enodeVehicles = enodeVehicles;
      notifyListeners();
      return enodeVehicles;
    } catch (error) {
      _isLoading = false;
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<EnodeVehicle> fetchEnodeVehicle(String vehicleId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final enodeVehicle = await apiService.fetchEnodeVehicle(vehicleId);
      _isLoading = false;
      _enodeVehicle = enodeVehicle;
      notifyListeners();
      return enodeVehicle;
    } catch (error) {
      _isLoading = false;
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> linkEnodeVehicle() async {
    try {
      final response = await apiService.linkEnodeVehicle();
      notifyListeners();
      return response;
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  Future<void> unlinkEnodeIntegration() async {
    try {
      await apiService.unlinkEnodeIntegration();
      _enodeVehicles.clear();
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  // Future<void> addEnodeVehicle(EnodeVehicle enodeVehicle) async {
  //   try {
  //     final response = await apiService.addEnodeVehicle(enodeVehicle);
  //     final currentResponse = jsonDecode(response.toString());
  //     _enodeVehicles = EnodeVehicle.fromJson(currentResponse);
  //     notifyListeners();
  //   } catch (error) {
  //     debugPrint(error.toString());
  //     rethrow;
  //   }
  // }

  // Future<void> updateEnodeVehicle(EnodeVehicle enodeVehicle) async {
  //   try {
  //     final response = await apiService.updateEnodeVehicle(enodeVehicle);
  //     final data = jsonDecode(response.toString());
  //     _enodeVehicles = EnodeVehicle.fromJson(data);
  //     notifyListeners();
  //   } catch (error) {
  //     debugPrint(error.toString());
  //     rethrow;
  //   }
  //   notifyListeners();
  // }
}
