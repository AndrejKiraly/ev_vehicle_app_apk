import 'package:flutter/material.dart';

class EvStationMar {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String addressLine;
  final double distance;
  final double rating;
  final bool isFree;

  EvStationMar(
      {required this.id,
      required this.name,
      required this.latitude,
      required this.longitude,
      required this.addressLine,
      required this.distance,
      required this.rating,
      required this.isFree});

  factory EvStationMar.fromJson(Map<String, dynamic> json) {
    return EvStationMar(
      id: json['id']?.toInt(),
      name: json['name'] ??
          'Unknown', // Provide a default value for name if it's null
      latitude: json['latitude'] ??
          0.0, // Provide a default value for latitude if it's null
      longitude: json['longitude'] ??
          0.0, // Provide a default value for longitude if it's null
      addressLine: json['address_line'] ??
          'Unknown', // Provide a default value for addressLine if it's null
      distance: json['distance']?.toDouble() ??
          0.0, // Convert distance to double and provide a default value if it's null
      rating: json['rating']?.toDouble() ??
          0.0, // Convert rating to double and provide a default value if it's null
      isFree: json['is_free'] ??
          false, // Provide a default value for isFree if it's null
    );
  }

  String MarkerTowaypointsString() {
    return "${latitude},${longitude}|";
  }
}
