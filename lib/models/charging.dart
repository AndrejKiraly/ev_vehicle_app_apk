class Charging {
  final int id;
  final int? evStationId;
  final double? latitude;
  final double? longitude;
  final int? connectionId;
  final String vehicleId;
  final int batteryLevelStart;
  final int? batteryLevelEnd;
  final double? price;
  final int? energyUsed;
  final int? rating;
  final String? comment;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isFinished;

  Charging(
      {required this.id,
      //required this.evStationId,
      this.evStationId,
      required this.connectionId,
      required this.vehicleId,
      required this.batteryLevelStart,
      required this.latitude,
      required this.longitude,
      this.batteryLevelEnd,
      this.price,
      this.energyUsed,
      this.rating,
      this.comment,
      required this.startTime,
      this.endTime,
      required this.isFinished});

  factory Charging.fromJson(Map<String, dynamic> json) {
    return Charging(
      id: json['id'] as int,
      evStationId: json['ev_station_id'] as int? ?? -1,
      connectionId: json['connection_id'] as int? ?? -1,
      vehicleId: json['vehicle_id'] as String,
      batteryLevelStart: json['battery_level_start'] as int,
      batteryLevelEnd: json['battery_level_end'] as int?,
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      price: json['price'] as double? ?? 0.0,
      energyUsed: json['energy_used'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      isFinished: json['is_finished'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "charging": {
        'id': id,
        //'ev_station_id': evStationId,

        'connection_id': connectionId,
        'vehicle_id': vehicleId,
        'battery_level_start': batteryLevelStart,
        'battery_level_end': batteryLevelEnd,
        'price': price,
        'energy_used': energyUsed,
        'rating': rating,
        'comment': comment,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime?.toIso8601String(),
        'is_finished': isFinished,
      }
    };
  }

  static Charging emptyCharging() {
    return Charging(
      id: 0,
      evStationId: 0,
      connectionId: 0,
      vehicleId: '',
      latitude: 0.0,
      longitude: 0.0,
      batteryLevelStart: 0,
      batteryLevelEnd: 0,
      price: 0.0,
      energyUsed: 0,
      rating: 0,
      comment: '',
      startTime: DateTime.now(),
      endTime: null,
      isFinished: false,
    );
  }
}
