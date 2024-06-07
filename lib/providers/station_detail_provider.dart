import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/api_services.dart';
import '../models/ev_connection.dart';
import '../models/ev_station.dart';

class StationDetailProvider extends ChangeNotifier {
  final Dio client;
  final ApiService apiService;

  StationDetailProvider(this.client) : apiService = ApiService(client);

  bool isLoading = true;

  EvStation? station;

  final List<EvConnection> _connections = [];
  List<EvConnection> get connections => UnmodifiableListView(_connections);

  Future<void> fetchStationDetail({required int stationId}) async {
    final stationDetail =
        await apiService.fetchStationDetail(stationId: stationId);
    Map<String, dynamic> jsonData = jsonDecode(stationDetail.toString());
    station = EvStation.fromJson(jsonData);

    final connectionsData = jsonData['connections'] as List;

    final connectionList = connectionsData
        .map<EvConnection>((connData) => EvConnection.fromJson(connData))
        .toList();

    _connections.clear();
    _connections.addAll(connectionList);

    isLoading = false;
    notifyListeners();
  }
}
