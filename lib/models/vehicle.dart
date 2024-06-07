class Vehicle {
  int? vehicleId;
  int? userId;
  String vehicleName;
  double bateryCapacity;
  double stateOfCharge;
  double chargingPower;
  double chargingEfficiency;
  double averageEnergyConsumption;

  Vehicle(
      {this.vehicleId,
      this.userId,
      required this.vehicleName,
      required this.bateryCapacity,
      required this.stateOfCharge,
      required this.chargingPower,
      required this.chargingEfficiency,
      required this.averageEnergyConsumption});

  static Vehicle empty() {
    return Vehicle(
      vehicleId: 0,
      userId: 0, //TODO GET USER ID STORED IN SHARED PREFERENCES
      vehicleName: '',
      bateryCapacity: 0.0,
      stateOfCharge: 0.0,
      chargingPower: 0.0,
      chargingEfficiency: 0.0,
      averageEnergyConsumption: 0.0,
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicle_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      vehicleName: json['vehicle_name'] ?? '',
      bateryCapacity: json['battery_capacity'] ?? 0.0,
      stateOfCharge: json['state_of_charge'] ?? 0.0,
      chargingPower: json['charging_power'] ?? 0.0,
      chargingEfficiency: json['charging_efficiency'] ?? 0.0,
      averageEnergyConsumption: json['average_energy_consumption'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_id': vehicleId,
      'user_id': userId,
      'vehicle_name': vehicleName,
      'battery_capacity': bateryCapacity,
      'state_of_charge': stateOfCharge,
      'charging_power': chargingPower,
      'charging_efficiency': chargingEfficiency,
      'average_energy_consumption': averageEnergyConsumption,
    };
  }

  static Vehicle emptyVehicle() {
    return Vehicle(
      vehicleId: null,
      userId: null,
      vehicleName: '',
      bateryCapacity: 0.0,
      stateOfCharge: 0.0,
      chargingPower: 0.0,
      chargingEfficiency: 0.0,
      averageEnergyConsumption: 0.0,
    );
  }

  Vehicle copyWith(
      {int? vehicleId,
      int? userId,
      String? vehicleName,
      double? bateryCapacity,
      double? stateOfCharge,
      double? chargingPower,
      double? chargingEfficiency,
      double? averageEnergyConsumption}) {
    return Vehicle(
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      vehicleName: vehicleName ?? this.vehicleName,
      bateryCapacity: bateryCapacity ?? this.bateryCapacity,
      stateOfCharge: stateOfCharge ?? this.stateOfCharge,
      chargingPower: chargingPower ?? this.chargingPower,
      chargingEfficiency: chargingEfficiency ?? this.chargingEfficiency,
      averageEnergyConsumption:
          averageEnergyConsumption ?? this.averageEnergyConsumption,
    );
  }
}
