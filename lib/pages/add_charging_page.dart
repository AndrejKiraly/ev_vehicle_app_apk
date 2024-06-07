import 'package:ev_vehicle_app/models/charging.dart';
import 'package:ev_vehicle_app/models/enode_vehicle.dart';
import 'package:ev_vehicle_app/pages/enode_vehicles_page.dart';
import 'package:ev_vehicle_app/providers/chargings_provider.dart';
import 'package:ev_vehicle_app/providers/enode_vehicle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class AddChargingPage extends StatefulWidget {
  final int connectionId;
  final bool isEditMode;
  Charging? charging;

  @override
  AddChargingPage({
    Key? key,
    required this.connectionId,
    required this.isEditMode,
    this.charging,
  }) : super(key: key);
  @override
  State<AddChargingPage> createState() => _AddChargingPageState();
}

class _AddChargingPageState extends State<AddChargingPage> {
  bool isEditMode = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EnodeVehicleProvider>().fetchEnodeVehicles();
      if (widget.isEditMode) {
        isEditMode = true;
        selectedVehicleId = widget.charging!.vehicleId;
        startDateAndTime = widget.charging!.startTime;
        endDateAndTime = widget.charging!.endTime!;
        chargingRating = widget.charging!.rating!;
        _chargingEnergyController.text = widget.charging!.energyUsed.toString();
        _chargingCostController.text = widget.charging!.price.toString();
        _chargingCommentController.text = widget.charging!.comment!;
        _batteryLevelStartController.text =
            widget.charging!.batteryLevelStart.toString();
        _batteryLevelEndController.text =
            widget.charging!.batteryLevelEnd.toString();
      }
    });
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  final _formKey = GlobalKey<FormState>();
  String selectedVehicleId = '';
  DateTime startDateAndTime = DateTime.now();
  DateTime endDateAndTime = DateTime.now();
  int chargingRating = 0;

  final _chargingEnergyController = TextEditingController();
  final _chargingCostController = TextEditingController();
  final _chargingCommentController = TextEditingController();
  final _batteryLevelStartController = TextEditingController();
  final _batteryLevelEndController = TextEditingController();

  Future<void> saveOrUpdateCharging() async {
    try {
      final charging = Charging(
        id: isEditMode ? widget.charging!.id : 0,
        vehicleId: selectedVehicleId,
        connectionId: widget.connectionId,
        startTime: startDateAndTime,
        endTime: endDateAndTime,
        latitude: 0.0,
        longitude: 0.0,
        energyUsed: int.parse(_chargingEnergyController.text),
        price: double.parse(_chargingCostController.text),
        comment: _chargingCommentController.text,
        batteryLevelStart: int.parse(_batteryLevelStartController.text),
        batteryLevelEnd: int.parse(_batteryLevelEndController.text),
        rating: chargingRating,
        isFinished: true,
      );
      final chargingProvider = context.read<ChargingsProvider>();

      if (isEditMode) {
        await chargingProvider.updateCharging(charging);
      } else {
        await chargingProvider.addCharging(charging);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = context.watch<EnodeVehicleProvider>().enodeVehicles;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Update Charging' : 'Add Charging'),
      ),
      body: context.watch<EnodeVehicleProvider>().isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
              ? Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No vehicles found!'),
                        const SizedBox(height: 20),
                        const Text('Please add a vehicle first!'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EnodeVehiclesPage(),
                                ),
                              );
                            },
                            child: const Text("Go to Vehicles Page"))
                      ]),
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                DropdownButtonFormField<EnodeVehicle>(
                                  value: selectedVehicleId.isEmpty
                                      ? null
                                      : vehicles.firstWhere((vehicle) =>
                                          vehicle.id == selectedVehicleId),
                                  items: vehicles
                                      .map((vehicle) => DropdownMenuItem(
                                            value: vehicle,
                                            child: Row(
                                              children: [
                                                Text(vehicle.brand),
                                                const Text(' '),
                                                Text(vehicle.model),
                                              ],
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (EnodeVehicle? vehicle) {
                                    // Set the selected vehicle
                                    selectedVehicleId = vehicle!.id;
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Select Vehicle',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Start Date & Time: ${startDateAndTime.year}-${startDateAndTime.month}-${startDateAndTime.day} ${startDateAndTime.hour}:${startDateAndTime.minute}',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            final DateTime? pickedDateTime =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate:
                                                        startDateAndTime,
                                                    firstDate:
                                                        DateTime(2023, 1, 1),
                                                    lastDate: DateTime.now());
                                            if (pickedDateTime != null) {
                                              final TimeOfDay? pickedTime =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                                initialEntryMode:
                                                    TimePickerEntryMode.input,
                                              );

                                              if (pickedTime != null) {
                                                startDateAndTime = DateTime(
                                                  pickedDateTime.year,
                                                  pickedDateTime.month,
                                                  pickedDateTime.day,
                                                  pickedTime.hour,
                                                  pickedTime.minute,
                                                );
                                                setState(() {});
                                              }
                                            }
                                          },
                                          child:
                                              const Text('Select Date & Time'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'End Date & Time: ${endDateAndTime.year}-${endDateAndTime.month}-${endDateAndTime.day} ${endDateAndTime.hour}:${endDateAndTime.minute}',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            final pickedDateTime =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: endDateAndTime,
                                              firstDate: DateTime(2023, 1, 1),
                                              lastDate: DateTime(2025, 12, 31),
                                            );

                                            if (pickedDateTime != null) {
                                              final pickedTime =
                                                  await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now(),
                                                initialEntryMode:
                                                    TimePickerEntryMode.input,
                                              );

                                              if (pickedTime != null) {
                                                endDateAndTime = DateTime(
                                                  pickedDateTime.year,
                                                  pickedDateTime.month,
                                                  pickedDateTime.day,
                                                  pickedTime.hour,
                                                  pickedTime.minute,
                                                );
                                                setState(() {});
                                              }
                                            }
                                          },
                                          child:
                                              const Text('Select Date & Time'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  controller: _chargingEnergyController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Charging Energy (kWh)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a charging energy';
                                    }
                                    // Regular expression to match valid integers or doubles
                                    final numberPattern =
                                        RegExp(r'^[0-9]+(\.[0-9]+)?$');

                                    if (!numberPattern.hasMatch(value)) {
                                      return 'Please enter a valid number (e.g., 3 or 3.14)';
                                    }
                                    if (double.parse(value) < 0) {
                                      return 'Please enter a positive number';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _chargingCostController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Charging Cost Euro(€)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a charging cost';
                                    }
                                    if (double.parse(value) < 0) {
                                      return 'Please enter a positive number';
                                    }
                                    // Regular expression to match valid integers OR doubles
                                    final numberPattern =
                                        RegExp(r'^[0-9]+(\.[0-9]+)?$');

                                    if (!numberPattern.hasMatch(value)) {
                                      return 'Please enter a valid number (e.g., 3 or 3.14)';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _chargingCommentController,
                                  decoration: const InputDecoration(
                                    labelText: 'Charging Comment',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a charging comment';
                                    }
                                    if (value.length > 255) {
                                      return 'Please enter a comment with less than 255 characters';
                                    }

                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _batteryLevelStartController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: false, decimal: false),
                                  decoration: const InputDecoration(
                                    labelText: 'Battery Level Start',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a battery level start';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  controller: _batteryLevelEndController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: false, decimal: false),
                                  decoration: const InputDecoration(
                                    labelText: 'Battery Level End  (0-100%)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a battery level end';
                                    }
                                    if (double.parse(value) < 0) {
                                      return 'Please enter a positive number';
                                    }
                                    if (double.parse(value) > 100) {
                                      return 'Please enter a number not above 100';
                                    }
                                    if (double.parse(value) <
                                        double.parse(
                                            _batteryLevelStartController
                                                .text)) {
                                      return 'Please enter a number greater than the battery level start';
                                    }

                                    final numberPattern = RegExp(r'^[0-9]+$');

                                    if (!numberPattern.hasMatch(value)) {
                                      return 'Please enter a integer number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Charging Rating',
                                  style: TextStyle(fontSize: 18),
                                ),
                                RatingBar.builder(
                                  initialRating: chargingRating.toDouble(),
                                  minRating: 0,
                                  maxRating: 5,
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    chargingRating = rating.toInt();
                                  },
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (selectedVehicleId.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please select a vehicle first!'),
                                          ),
                                        );
                                        return;
                                      }
                                      if (startDateAndTime
                                          .isAfter(endDateAndTime)) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'End date and time should be after start date and time!'),
                                          ),
                                        );
                                        return;
                                      }
                                      saveOrUpdateCharging();
                                    }
                                  },
                                  child: Text(
                                    isEditMode
                                        ? 'Update Charging'
                                        : 'Save Charging',
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
