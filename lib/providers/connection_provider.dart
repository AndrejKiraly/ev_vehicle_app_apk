import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/api_services.dart';
import '../models/ev_connection.dart';

class ConnectionProvider extends ChangeNotifier {
  final Dio client;
  final ApiService apiService;

  ConnectionProvider(this.client) : apiService = ApiService(client);

  final List<EvConnection> _evConnections = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<EvConnection> get evConnections => UnmodifiableListView(_evConnections);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> addConnection(EvConnection evConnection) async {
    try {
      final response = await apiService.addConnection(evConnection);

      final currentResponse = jsonDecode(response.toString());
      _evConnections.add(EvConnection.fromJson(currentResponse));

      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
  }

  void clearConnections() {
    _evConnections.clear();
    notifyListeners();
  }

  void updateConnection(EvConnection evConnection, BuildContext context) async {
    try {
      final response = await apiService.updateConnection(evConnection);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = EvConnection.fromJson(jsonDecode(response.toString()));
        final index =
            _evConnections.indexWhere((element) => element.id == data.id);
        _evConnections[index] = data;
        SnackBar snackBar = const SnackBar(
          content: Text('Connection updated successfully'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        notifyListeners();
      }
    } catch (error) {
      debugPrint(error.toString());
      rethrow;
    }
    notifyListeners();
  }

  Future<void> deleteConnection(int connectionId, int index) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      apiService.deleteConnection(connectionId);
      _evConnections.removeAt(index);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to delete charging: $error';
      rethrow;
    }
  }

  Future<void> fetchConnections(int stationId) async {
    try {
      _evConnections.clear();
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      final connections = await apiService.fetchConnections(stationId);
      _evConnections.addAll(connections);
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Failed to fetch chargings: $error';
      notifyListeners();
    }
  }
}
