import 'package:ev_vehicle_app/enums/amenities_types_class.dart';
import 'package:ev_vehicle_app/enums/countries_class.dart';
import 'package:ev_vehicle_app/enums/data_source_class.dart';
import 'package:ev_vehicle_app/enums/usage_type_class.dart';
import 'package:ev_vehicle_app/models/ev_connection.dart';

class EvStation {
  int? id;
  String? name;
  double? latitude;
  double? longitude;
  String? addressLine;
  double? distance;
  double? rating;
  String? email;
  String? countryString;
  String? city;
  String? postCode;
  Country? country;
  Source source;
  int? userRatingTotal;
  String? phoneNumber;
  String? operatorWebsite;
  String? priceInformation;
  bool? isFree;
  String? openHours;
  String? instructionForUsers;
  DateTime? createdAt;
  DateTime? updatedAt;
  UsageType usageType;
  List<Amenity> amenities = [];
  List<EvConnection>? connections;

  EvStation({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.addressLine,
    this.distance,
    this.rating,
    required this.email,
    required this.countryString,
    required this.city,
    required this.postCode,
    this.country,
    required this.source,
    this.userRatingTotal,
    required this.phoneNumber,
    this.operatorWebsite,
    this.priceInformation,
    required this.isFree,
    this.openHours,
    this.instructionForUsers,
    this.createdAt,
    this.updatedAt,
    this.amenities = const [],
    required this.usageType,
    this.connections,
  });

  factory EvStation.fromJson(Map<String, dynamic> json) {
    return EvStation(
      id: json['id'] as int,
      name: json['name'] ?? 'Unknown',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      addressLine: json['address_line'] ?? 'Unknown',
      distance: json['distance']?.toDouble() ?? 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      email: json['email'] ?? '',
      countryString: json['country_string'] ?? '',
      city: json['city'] ?? '',
      postCode: json['post_code'] ?? '',
      country: Country.fromId(1),

      userRatingTotal: json['user_rating_total'] as int? ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      operatorWebsite: json['operator_website_url'] ?? '',
      priceInformation: json['price'] ?? 'Unknown',
      isFree: json['is_free'] ?? false,
      openHours: json['open_hours'] ?? 'Unknown',
      instructionForUsers: json['instruction_for_users'] ?? '',
      source: Source.fromId(json['source_id'] as int),
      usageType: json['usage_type']['id'] == null
          ? UsageType.unknown
          : UsageType.fromId(
              json['usage_type']['id'] as int), // json['usage_type']['title

      amenities: json['amenities'] != List.empty()
          ? json['amenities']
              .map<Amenity>((e) => Amenity.fromId(e['id'] as int))
              .toList()
          : [],
      updatedAt: DateTime.parse(json['updated_at'] ?? '').subtract(
        Duration(
          milliseconds: DateTime.parse(json['updated_at'] ?? '').millisecond,
        ),
      ),
      createdAt: DateTime.parse(json['created_at'] ?? '').subtract(
        Duration(
          milliseconds: DateTime.parse(json['created_at'] ?? '').millisecond,
        ),
      ),
      connections: json['connections'] != List.empty()
          ? json['connections']
              .map<EvConnection>(
                  (connection) => EvConnection.fromJson(connection))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ev_station": {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address_line': addressLine,
        'distance': distance,
        'rating': rating,
        'email': email,
        'country_string': countryString,
        'city': city,
        'post_code': postCode,
        'country_id': country!.id,
        'source_id': source.id,
        'user_rating_total': userRatingTotal,
        'phone_number': phoneNumber,
        'operator_website_url': operatorWebsite,
        'price': priceInformation,
        'is_free': isFree,
        'open_hours': openHours,
        'instruction_for_users': instructionForUsers,
        'usage_type_id': usageType.id,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'amenity_ids': amenities.map((e) => e.id).toList(),
        'connections': connections?.map((e) => e.toJson()).toList() ?? '',
      }
    };
  }

  EvStation copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? addressLine,
    double? distance,
    double? rating,
    String? email,
    String? countryString,
    String? city,
    String? postCode,
    Country? country,
    Source? source,
    int? userRatingTotal,
    String? phoneNumber,
    String? operatorWebsite,
    String? priceInformation,
    bool? isFree,
    String? openHours,
    String? instructionForUsers,
    UsageType? usageType,
    List<Amenity>? amenities,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<EvConnection>? connections,
  }) {
    return EvStation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressLine: addressLine ?? this.addressLine,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      email: email ?? this.email,
      countryString: countryString ?? this.countryString,
      city: city ?? this.city,
      postCode: postCode ?? this.postCode,
      country: country ?? this.country,
      source: source ?? this.source,
      userRatingTotal: userRatingTotal ?? this.userRatingTotal,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      operatorWebsite: operatorWebsite ?? this.operatorWebsite,
      priceInformation: priceInformation ?? this.priceInformation,
      isFree: isFree ?? this.isFree,
      openHours: openHours ?? this.openHours,
      instructionForUsers: instructionForUsers ?? this.instructionForUsers,
      usageType: usageType ?? this.usageType,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      connections: connections ?? this.connections,
    );
  }
}
