import 'package:dio/dio.dart';
import 'package:ev_vehicle_app/api/api_services.dart';
import 'package:ev_vehicle_app/models/charging.dart';
import 'package:flutter/foundation.dart';

class ChargingsProvider with ChangeNotifier {
  final Dio client;
  final ApiService apiService;

  ChargingsProvider(this.client) : apiService = ApiService(client);

  List<Charging> _chargings = [];
  bool _isLoading = false;
  String _errorMessage = '';
  double _totalChargingsCost = 0.0;
  int _totalChargingsEnergy = 0;

  List<Charging> get chargings => _chargings;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  double get totalChargingsCost => _totalChargingsCost;
  int get totalChargingsEnergy => _totalChargingsEnergy;

  Charging _charging = Charging.emptyCharging();
  Charging get charging => _charging; // Add a semicolon at the end of the line.

  Future<void> fetchUserChargings() async {
    //   final chargings = await apiService.fetchUserChargings();
    //   _chargings = chargings;
    //   notifyListeners();
    //   return chargings;
    // }
    _chargings.clear();
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      // Call your charging service to fetch the chargings
      final chargingsFetched = await apiService.fetchUserChargings();
      _chargings = chargingsFetched;

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch chargings: $error';
      notifyListeners();
    }
  }

  Future<void> fetchStationsChargings(int stationId) async {
    _chargings.clear();
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      final chargings = await apiService.fetchStationsChargings(stationId);
      _chargings = chargings;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch chargings: $error';
      notifyListeners();
    }
  }

  Future<Charging> fetchCharging(int chargingId) async {
    try {
      _charging = Charging.emptyCharging();
      _isLoading = true;
      notifyListeners();
      // Call your charging service to fetch the charging
      final charging = await apiService.fetchCharging(chargingId);
      _charging = charging;
      _isLoading = false;
      notifyListeners();
      return _charging;
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch charging: $error';
      notifyListeners();
      return _charging;
    }
  }

  Future<void> updateCharging(Charging charging) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      // Call your charging service to update the charging
      final response = await apiService.updateCharging(charging);
      _charging = Charging.fromJson(response.data);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to update charging: $error';
      notifyListeners();
    }
  }

  Future<void> updateChargingsConnection(
      int chargingId, int connectionId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      // Call your charging service to update the charging
      ;
      final response =
          await apiService.updateChargingConnection(chargingId, connectionId);
      _charging = Charging.fromJson(response.data);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to update charging: $error';
      notifyListeners();
    }
  }

  Future<void> addCharging(Charging charging) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      final response = await apiService.addCharging(charging);
      _charging = Charging.fromJson(response.data);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to add charging: $error';
      notifyListeners();
    }
  }

  Future<void> deleteCharging(int chargingId, int index) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      apiService.deleteCharging(chargingId);
      _chargings.removeAt(index);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to delete charging: $error';
      rethrow;
    }
  }

  Future<void> fetchMonthlyChargingsSummary(int year, int month) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      _chargings.clear();
      // Call your charging service to fetch the total cost of chargings
      final response =
          await apiService.fetchChargingsMonthlySummary(year, month);
      final totalCost = response.data['total_charging_cost'];
      final totalEnergy = response.data['total_energy_used'];
      List<Charging> fetchedChargings = [];
      for (var item in response.data['chargings']) {
        fetchedChargings.add(Charging.fromJson(item));
      }
      _chargings = fetchedChargings;
      _totalChargingsEnergy = totalEnergy;
      _totalChargingsCost = totalCost;
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch total cost of chargings: $error';
      notifyListeners();
    }
  }
}
