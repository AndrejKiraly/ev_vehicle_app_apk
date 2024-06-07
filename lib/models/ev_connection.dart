import 'package:ev_vehicle_app/enums/connection_types_class.dart';
import 'package:ev_vehicle_app/enums/current_type_class.dart';

class EvConnection {
  int? evStationId;
  int? id;
  ConnectionType connectionType;
  bool? isOperationalStatus;
  bool? isFastChargeCapable;
  CurrentType currentType;
  int? amps;
  int? voltage;
  int? powerKW;
  int? quantity;
  DateTime? createdAt;

  EvConnection({
    this.evStationId,
    this.id,
    required this.connectionType,
    required this.isOperationalStatus,
    required this.isFastChargeCapable,
    required this.currentType,
    required this.amps,
    required this.voltage,
    required this.powerKW,
    required this.quantity,
    this.createdAt,
  });

  factory EvConnection.fromJson(Map<String, dynamic> json) {
    //print(json['id'] as int);
    return EvConnection(
      evStationId: json['ev_station_id'] as int,
      id: json['id'] as int,
      connectionType:
          ConnectionType.fromId(json['connection_type']['id'] as int),
      isOperationalStatus: json['is_operational_status'] ?? false,
      isFastChargeCapable: json['is_fast_charge_capable'] ?? false,
      currentType: CurrentType.fromId(json['current_type']['id'] as int),
      amps: json['amps'] as int? ?? 0,
      voltage: json['voltage'] as int? ?? 0,
      powerKW: json['powerKW'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    print(id);
    return {
      "connection": {
        'ev_station_id': evStationId,
        'id': id,
        'connection_type_id': connectionType.id,
        'is_operational_status': isOperationalStatus,
        'is_fast_charge_capable': isFastChargeCapable,
        'current_type_id': currentType.id,
        'amps': amps,
        'voltage': voltage,
        'powerKW': powerKW,
        'quantity': quantity,
        'created_at': createdAt?.toIso8601String(),
      }
    };
  }

  EvConnection copyWith({
    int? evStationId,
    int? id,
    ConnectionType? connectionType,
    bool? isOperationalStatus,
    bool? isFastChargeCapable,
    CurrentType? currentType,
    int? amps,
    int? voltage,
    int? powerKW,
    int? quantity,
    String? priceInfo,
    DateTime? createdAt,
  }) {
    return EvConnection(
      evStationId: evStationId ?? this.evStationId,
      id: id ?? this.id,
      connectionType: connectionType ?? this.connectionType,
      isOperationalStatus: isOperationalStatus ?? this.isOperationalStatus,
      isFastChargeCapable: isFastChargeCapable ?? this.isFastChargeCapable,
      currentType: currentType ?? this.currentType,
      amps: amps ?? this.amps,
      voltage: voltage ?? this.voltage,
      powerKW: powerKW ?? this.powerKW,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
