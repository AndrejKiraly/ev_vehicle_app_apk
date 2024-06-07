import 'package:ev_vehicle_app/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/vehicle_provider.dart';

class VehiclePage extends StatefulWidget {
  const VehiclePage({Key? key}) : super(key: key);

  @override
  State<VehiclePage> createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  final vehicleNameController = TextEditingController();
  Vehicle vehicle = Vehicle.emptyVehicle();
  double bateryCapacity = 0;
  double stateOfCharge = 0;
  double chargingPower = 0;
  double chargingEfficiency = 0;
  double averageEnergyConsumption = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      vehicle = await context.read<VehicleProvider>().fetchVehicles();
      if (vehicle.vehicleId == null) return;

      setState(() {
        vehicleNameController.text = vehicle.vehicleName;
        bateryCapacity = vehicle.bateryCapacity;
        stateOfCharge = vehicle.stateOfCharge;
        chargingPower = vehicle.chargingPower;
        chargingEfficiency = vehicle.chargingEfficiency;
        averageEnergyConsumption = vehicle.averageEnergyConsumption;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Name',
                  ),
                  controller: vehicleNameController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a vehicle name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text("Batery Capacity ${bateryCapacity.round()} kWh"),
                Slider(
                  value: bateryCapacity,
                  onChanged: (double value) {
                    setState(() {
                      bateryCapacity = value;
                    });
                  },
                  min: 0,
                  max: 300,
                  label: bateryCapacity.round().toString(),
                  activeColor: Colors.blue,
                ),
                Text("State of Charge ${stateOfCharge.round()}%"),
                Slider(
                  value: stateOfCharge,
                  onChanged: (double value) {
                    setState(() {
                      stateOfCharge = value;
                    });
                  },
                  min: 0,
                  max: 100,
                  label: stateOfCharge.round().toString(),
                  activeColor: Colors.blue,
                ),
                Text("Charging Power ${chargingPower.round()} kW"),
                Slider(
                  value: chargingPower,
                  onChanged: (double value) {
                    setState(() {
                      chargingPower = value;
                    });
                  },
                  min: 0,
                  max: 350,
                  label: chargingPower.round().toString(),
                  activeColor: Colors.blue,
                ),
                Text("Charging Efficiency ${chargingEfficiency.round()}%"),
                Slider(
                  value: chargingEfficiency,
                  onChanged: (double value) {
                    setState(() {
                      chargingEfficiency = value;
                    });
                  },
                  min: 0,
                  max: 100,
                  label: chargingEfficiency.round().toString(),
                  activeColor: Colors.blue,
                ),
                Text(
                    "Average Energy Consumption ${averageEnergyConsumption.round()} kWh/100km"),
                Slider(
                  value: averageEnergyConsumption,
                  onChanged: (double value) {
                    setState(() {
                      averageEnergyConsumption = value;
                    });
                  },
                  min: 0,
                  max: 150,
                  label: averageEnergyConsumption.round().toString(),
                  activeColor: Colors.blue,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => saveOrUpdateVehicle(context),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveOrUpdateVehicle(BuildContext context) async {
    if (vehicle.vehicleId != null) {
      await updateVehicle();
    } else {
      await saveVehicle();
    }

    clearData();
  }

  Future<void> updateVehicle() async {
    final newVehicle = vehicle.copyWith(
      vehicleName: vehicleNameController.text,
      bateryCapacity: bateryCapacity,
      stateOfCharge: stateOfCharge,
      chargingPower: chargingPower,
      chargingEfficiency: chargingEfficiency,
      averageEnergyConsumption: averageEnergyConsumption,
    );
    context.read<VehicleProvider>().updateVehicle(newVehicle);
  }

  Future<void> saveVehicle() async {
    final vehicle = Vehicle(
      vehicleName: vehicleNameController.text,
      bateryCapacity: bateryCapacity,
      stateOfCharge: stateOfCharge,
      chargingPower: chargingPower,
      chargingEfficiency: chargingEfficiency,
      averageEnergyConsumption: averageEnergyConsumption,
    );
    context.read<VehicleProvider>().addVehicle(vehicle);
  }

  void clearData() {
    vehicleNameController.clear();
    bateryCapacity = 0;
    stateOfCharge = 0;
    chargingPower = 0;
    chargingEfficiency = 0;
    averageEnergyConsumption = 0;
  }
}
