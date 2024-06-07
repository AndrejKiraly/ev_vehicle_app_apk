// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ev_vehicle_app/enums/connection_types_class.dart';
import 'package:ev_vehicle_app/enums/current_type_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/ev_connection.dart';
import '../providers/connection_provider.dart';

class AddConnectionPage extends StatefulWidget {
  final bool isEditMode;
  final int? stationId;
  EvConnection? connection;

  @override
  AddConnectionPage({
    Key? key,
    required this.isEditMode,
    this.connection,
    this.stationId,
  }) : super(key: key);

  @override
  State<AddConnectionPage> createState() => _AddConnectionPageState();
}

class _AddConnectionPageState extends State<AddConnectionPage> {
  final formKey = GlobalKey<FormState>();

  bool isOperationalStatus = false;
  bool isFastChargeCapable = false;

  List<String> currentType = [
    'AC Single-Phase',
    'AC Three-Phase',
    'DC Direct Current'
  ];

  CurrentType selectedCurrentType = CurrentType.acSinglePhase;
  ConnectionType selectedConnectionType = ConnectionType.unknown;

  final ampsController = TextEditingController();
  final voltageController = TextEditingController();
  final powerController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  EvConnection? originalConnection;

  @override
  void initState() {
    if (widget.isEditMode) {
      originalConnection = widget.connection;
      selectedConnectionType = widget.connection!.connectionType;

      selectedCurrentType = widget.connection!.currentType;
      isOperationalStatus = widget.connection!.isOperationalStatus!;
      isFastChargeCapable = widget.connection!.isFastChargeCapable!;
      ampsController.text = widget.connection!.amps.toString();
      voltageController.text = widget.connection!.voltage.toString();
      powerController.text = widget.connection!.powerKW.toString();
      quantityController.text = widget.connection!.quantity.toString();
    }
    super.initState();
  }

  Future<void> onSaveOrUpdateConnection(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    if (widget.isEditMode) {
      await updateConnection();
    } else {
      await saveConnection();
    }

    clearData();
  }

  Future<void> saveConnection() async {
    try {
      final evConnection = EvConnection(
        evStationId: widget.stationId!,
        connectionType: selectedConnectionType,
        isOperationalStatus: isOperationalStatus,
        isFastChargeCapable: isFastChargeCapable,
        currentType: selectedCurrentType,
        amps:
            int.parse(ampsController.text.isEmpty ? '0' : ampsController.text),
        voltage: int.parse(
            voltageController.text.isEmpty ? '0' : voltageController.text),
        powerKW: int.parse(
            powerController.text.isEmpty ? '0' : powerController.text),
        quantity: int.parse(
            quantityController.text.isEmpty ? '0' : quantityController.text),
      );

      final connectionProvider = context.read<ConnectionProvider>();
      connectionProvider.addConnection(evConnection);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
    }
  }

  bool isUpdated(
      EvConnection originalConnection, EvConnection updatedConnection) {
    if (originalConnection.connectionType.id ==
            updatedConnection.connectionType.id &&
        originalConnection.currentType.id == updatedConnection.currentType.id &&
        originalConnection.amps == updatedConnection.amps &&
        originalConnection.voltage == updatedConnection.voltage &&
        originalConnection.powerKW == updatedConnection.powerKW &&
        originalConnection.quantity == updatedConnection.quantity &&
        originalConnection.isOperationalStatus ==
            updatedConnection.isOperationalStatus &&
        originalConnection.isFastChargeCapable ==
            updatedConnection.isFastChargeCapable) {
      return false;
    }
    return true;
  }

  Future<void> updateConnection() async {
    if (originalConnection == null) return;
    try {
      final evConnection = widget.connection!.copyWith(
        id: widget.connection!.id,
        connectionType: selectedConnectionType,
        isOperationalStatus: isOperationalStatus,
        isFastChargeCapable: isFastChargeCapable,
        currentType: selectedCurrentType,
        amps: int.parse(ampsController.text),
        voltage: int.parse(voltageController.text),
        powerKW: int.parse(powerController.text),
        quantity: int.parse(quantityController.text),
        priceInfo: priceController.text,
      );
      final connectionProvider = context.read<ConnectionProvider>();
      if (!isUpdated(originalConnection!, evConnection)) {
        Navigator.pop(context);
        return;
      }
      connectionProvider.updateConnection(evConnection, context);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
      ));
    }
  }

  @override
  void dispose() {
    clearData();
    super.dispose();
  }

  void clearData() {
    setState(() {
      ampsController.clear();
      voltageController.clear();
      powerController.clear();
      quantityController.clear();
      priceController.clear();
      selectedCurrentType = CurrentType.acSinglePhase;
      selectedConnectionType = ConnectionType.unknown;
      isOperationalStatus = false;
      isFastChargeCapable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Update Connection' : 'Add Connection'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                DropdownButtonFormField<ConnectionType>(
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  decoration: const InputDecoration(
                    labelText: 'Connection Type',
                  ),
                  value: selectedConnectionType,
                  hint: const Text('Select an item'),
                  onChanged: (value) {
                    setState(() {
                      selectedConnectionType = value!;
                    });
                  },
                  items: ConnectionType.values.map((connectionType) {
                    return DropdownMenuItem<ConnectionType>(
                      value: connectionType,
                      child: Text(connectionType.title),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a connection type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: ampsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(labelText: 'Amps'),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: TextFormField(
                        controller: voltageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Voltage',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<CurrentType>(
                  value: selectedCurrentType,
                  hint: const Text('Select an item'),
                  onChanged: (value) {
                    setState(() {
                      selectedCurrentType = value!;
                    });
                  },
                  items: CurrentType.values.map((currentType) {
                    return DropdownMenuItem<CurrentType>(
                      value: currentType,
                      child: Text(currentType.title),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a current type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: powerController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Power (KW)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: TextFormField(
                        controller: quantityController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    const Text('Fast Charge Capable'),
                    const Spacer(),
                    const Text('No'),
                    Switch(
                      thumbIcon: MaterialStateProperty.resolveWith(
                          (states) => const Icon(Icons.flash_on)),
                      value: isFastChargeCapable,
                      onChanged: (value) {
                        setState(() {
                          isFastChargeCapable = value;
                        });
                      },
                      inactiveTrackColor: Colors.red,
                      activeTrackColor: Colors.lime,
                    ),
                    const Text('Yes'),
                  ],
                ),
                Row(
                  children: [
                    const Text('Operational Status'),
                    const Spacer(),
                    const Text('No'),
                    Switch(
                      thumbIcon: MaterialStateProperty.resolveWith(
                          (states) => const Icon(Icons.thumb_up)),
                      value: isOperationalStatus,
                      onChanged: (value) {
                        setState(() {
                          isOperationalStatus = value;
                        });
                      },
                      inactiveTrackColor: Colors.red,
                      activeTrackColor: Colors.green,
                    ),
                    const Text('Yes'),
                  ],
                ),
                // TextFormField(
                //   controller: priceController,
                //   decoration: const InputDecoration(labelText: 'Price Info'),
                // ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => onSaveOrUpdateConnection(context),
                      child: Text(widget.isEditMode ? 'Update' : 'Save'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
