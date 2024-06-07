class EnodeVehicle {
  final String id;
  final double batteryLevel;
  final double batteryCapacity;
  final String vendor;
  final String brand;
  final String model;
  final double latitude;
  final double longitude;
  final double maxCurrent;
  final String powerDeliveryState;
  final double chargeLimit;

  EnodeVehicle({
    required this.id,
    required this.batteryLevel,
    required this.batteryCapacity,
    required this.vendor,
    required this.brand,
    required this.model,
    required this.latitude,
    required this.longitude,
    required this.maxCurrent,
    required this.powerDeliveryState,
    required this.chargeLimit,
  });

  factory EnodeVehicle.fromJson(Map<String, dynamic> json) {
    return EnodeVehicle(
      id: json['id'] ?? '',
      batteryLevel: json['chargeState']['batteryLevel']?.toDouble() ?? 0.0,
      batteryCapacity:
          json['chargeState']['batteryCapacity']?.toDouble() ?? 0.0,
      vendor: json['vendor'] ?? '',
      brand: json['information']['brand'] ?? '',
      model: json['information']['model'] ?? '',
      latitude: json['location']['latitude']?.toDouble() ?? 0.0,
      longitude: json['location']['longitude']?.toDouble() ?? 0.0,
      maxCurrent: json['chargeState']['maxCurrent']?.toDouble() ?? 0.0,
      powerDeliveryState: json['chargeState']['powerDeliveryState'] ?? '',
      chargeLimit: json['chargeState']['chargeLimit']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'battery_level': batteryLevel,
      'battery_capacity': batteryCapacity,
      'vendor': vendor,
      'brand': brand,
      'model': model,
      'latitude': latitude,
      'longitude': longitude,
      'max_current': maxCurrent,
      'power_delivery_state': powerDeliveryState,
      'charge_limit': chargeLimit,
    };
  }

  static EnodeVehicle emptyEnodeVehicle() {
    return EnodeVehicle(
      id: '',
      batteryLevel: 0.0,
      batteryCapacity: 0.0,
      vendor: '',
      brand: '',
      model: '',
      latitude: 0.0,
      longitude: 0.0,
      maxCurrent: 0.0,
      powerDeliveryState: '',
      chargeLimit: 0.0,
    );
  }
}
