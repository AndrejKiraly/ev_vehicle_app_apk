import '../enums/amenities_types_class.dart';
import '../enums/connection_types_class.dart';
import '../enums/current_type_class.dart';
import '../enums/usage_type_class.dart';

class FilterData {
  final String latitude;
  final String longitude;
  final String boundSw;
  final String boundsNe;
  final String? power;
  final List<UsageType>? usageTypes;
  final List<Amenity>? amenities;
  final bool? isFree;
  final List<CurrentType>? currentTypes;
  final List<ConnectionType>? connectionTypes;
  final String? rating;

  FilterData({
    required this.latitude,
    required this.longitude,
    required this.boundSw,
    required this.boundsNe,
    required this.power,
    required this.usageTypes,
    required this.amenities,
    required this.isFree,
    required this.currentTypes,
    required this.connectionTypes,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'bounds_sw': boundSw,
      'bounds_ne': boundsNe,
      'power_kw': power,
      'usage_type_ids[]':
          usageTypes!.isEmpty ? null : usageTypes?.map((e) => e.id).toList(),
      'amenity_ids[]':
          amenities!.isEmpty ? null : amenities?.map((e) => e.id).toList(),
      'is_free': isFree,
      'current_type_id[]': currentTypes!.isEmpty
          ? null
          : currentTypes?.map((e) => e.id).toList(),
      'connection_type_ids[]': connectionTypes!.isEmpty
          ? null
          : connectionTypes?.map((e) => e.id).toList(),
      'rating': rating,
    };
  }

  factory FilterData.fromJson(Map<String, dynamic> json) {
    return FilterData(
      latitude: json['lat'] ?? 0.0,
      longitude: json['lng'] ?? 0.0,
      boundSw: json['bounds_sw'] ?? 0.0,
      boundsNe: json['bounds_ne'] ?? 0.0,
      power: json['power_kw'] ?? '',
      usageTypes: json['usage_type_ids[]'] == null
          ? []
          : json['usage_type_ids[]']
              .map<UsageType>((e) => UsageType.fromId(e))
              .toList(),
      amenities: json['amenity_ids[]'] == null
          ? []
          : json['amenity_ids[]']
              .map<Amenity>((e) => Amenity.fromId(e))
              .toList(),
      isFree: json['is_free'] ?? null,
      currentTypes: json['current_type_id[]'] == null
          ? []
          : json['current_type_id[]']
              .map<CurrentType>((e) => CurrentType.fromId(e))
              .toList(),
      connectionTypes: json['connection_type_ids[]'] == null
          ? []
          : json['connection_type_ids[]']
              .map<ConnectionType>((e) => ConnectionType.fromId(e))
              .toList(),
      rating: json['rating'],
    );
  }

  FilterData copyWith({
    String? latitude,
    String? longitude,
    String? boundSw,
    String? boundsNe,
    String? power,
    List<UsageType>? usageTypes,
    List<Amenity>? amenities,
    bool? isFree,
    List<CurrentType>? currentTypes,
    List<ConnectionType>? connectionTypes,
    String? rating,
  }) {
    return FilterData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      boundSw: boundSw ?? this.boundSw,
      boundsNe: boundsNe ?? this.boundsNe,
      power: power ?? this.power,
      usageTypes: usageTypes ?? this.usageTypes,
      amenities: amenities ?? this.amenities,
      isFree: isFree ?? this.isFree,
      currentTypes: currentTypes ?? this.currentTypes,
      connectionTypes: connectionTypes ?? this.connectionTypes,
      rating: rating ?? this.rating,
    );
  }
}
