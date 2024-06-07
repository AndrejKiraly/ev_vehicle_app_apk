// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ev_vehicle_app/enums/countries_class.dart';
import 'package:ev_vehicle_app/enums/data_source_class.dart';
import 'package:ev_vehicle_app/enums/usage_type_class.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../models/ev_station.dart';
import '../pages/add_connection_page.dart';
import '../pages/connections_page.dart';
import '../providers/connection_provider.dart';
import '../providers/station_provider.dart';
import '../services/location_service.dart';

class AddStationPage extends StatefulWidget {
  final bool isEditing;
  EvStation? station;
  double? latitudeFromCharging;
  double? longitudeFromCharging;

  AddStationPage(
      {Key? key,
      required this.isEditing,
      this.station,
      this.latitudeFromCharging,
      this.longitudeFromCharging})
      : super(key: key);

  @override
  State<AddStationPage> createState() => _AddStationPageState();
}

class _AddStationPageState extends State<AddStationPage> {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();

  GoogleMapController? controller;
  Position? currentLocation;
  EvStation? originalEvStatEion;

  int currentStep = 0;
  bool isCompleted = false;

  UsageType selectedUsageType = UsageType.unknown;

  final nameController = TextEditingController();
  final addressLineController = TextEditingController();
  final cityController = TextEditingController();
  final countryStringController = TextEditingController();
  final postcodeController = TextEditingController();

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final wesiteUrlController = TextEditingController();
  final priceController = TextEditingController();

  Country? selectedCountry = Country.slovakia;

  final workingHoursController = TextEditingController();

  final workingHourInfoController = TextEditingController();

  bool isFreeCharging = false;
  bool isOpenNonStop = false;

  final Set<Marker> markers = {};
  LatLng? selectedPoints;

  Future<void> onSaveOrUpdateStation(BuildContext context) async {
    final stationProvider = context.read<StationProvider>();

    final evStation = EvStation(
      name: nameController.text,
      latitude: selectedPoints!.latitude,
      longitude: selectedPoints!.longitude,
      addressLine: addressLineController.text,
      email: emailController.text,
      countryString: countryStringController.text,
      city: cityController.text,
      postCode: postcodeController.text,
      country: selectedCountry!,
      source: Source.mobileApp,
      phoneNumber: phoneController.text,
      operatorWebsite: wesiteUrlController.text,
      priceInformation: priceController.text,
      isFree: isFreeCharging,
      openHours: workingHoursController.text,
      usageType: selectedUsageType,
      instructionForUsers: '',
      amenities: stationProvider.selectedAmenities,
    );

    if (editMode) {
      evStation.id = widget.station!.id;
      if (isUpdated(evStation, originalEvStatEion!)) {
        await stationProvider.updateStation(evStation, context);
      }
    }

    final provider = context.read<ConnectionProvider>();
    if (widget.isEditing == false) {
      provider.clearConnections();
    }
    final stationId =
        editMode ? null : await stationProvider.addStation(evStation, context);

    if (!context.mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ConnectionsPage(
          stationId: editMode ? widget.station!.id : stationId,
          isEditMode: editMode,
        ),
      ),
      result: true,
    );

    clearData();
  }

  bool isUpdated(EvStation originalStation, EvStation updatedStation) {
    if (originalStation.name == updatedStation.name &&
        originalStation.addressLine == updatedStation.addressLine &&
        originalStation.city == updatedStation.city &&
        originalStation.countryString == updatedStation.countryString &&
        originalStation.postCode == updatedStation.postCode &&
        originalStation.phoneNumber == updatedStation.phoneNumber &&
        originalStation.email == updatedStation.email &&
        originalStation.operatorWebsite == updatedStation.operatorWebsite &&
        originalStation.priceInformation == updatedStation.priceInformation &&
        originalStation.openHours == updatedStation.openHours &&
        originalStation.isFree == updatedStation.isFree &&
        originalStation.usageType == updatedStation.usageType &&
        originalStation.latitude == updatedStation.latitude &&
        originalStation.longitude == updatedStation.longitude &&
        originalStation.amenities == updatedStation.amenities) {
      return false;
    }
    return true;
  }

  bool editMode = false;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      originalEvStatEion = widget.station;
      editMode = widget.isEditing;
      final provider = context.read<StationProvider>();
      await provider.fetchAmenities();

      if (editMode) {
        final station = widget.station!;
        nameController.text = station.name!;
        addressLineController.text = station.addressLine!;
        cityController.text = station.city!;
        countryStringController.text = station.countryString!;
        postcodeController.text = station.postCode!;
        phoneController.text = station.phoneNumber!;
        emailController.text = station.email!;
        wesiteUrlController.text = station.operatorWebsite!;
        priceController.text = station.priceInformation!;
        workingHoursController.text = station.openHours!;
        workingHourInfoController.text = station.openHours!;

        selectedUsageType = station.usageType;
        isFreeCharging = station.isFree!;
        isOpenNonStop = station.openHours == 'NONSTOP';

        for (final amenity in station.amenities) {
          provider.toggleAmenity(amenity);
        }
        selectedPoints = LatLng(station.latitude!, station.longitude!);

        setState(() {});
      }

      if (widget.latitudeFromCharging != null &&
          widget.longitudeFromCharging != null) {
        await setLocationToChargingCoordinates();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    clearData();
    super.dispose();
  }

  void clearData() {
    setState(() {
      nameController.clear();
      addressLineController.clear();
      cityController.clear();
      countryStringController.clear();
      postcodeController.clear();
      phoneController.clear();
      emailController.clear();
      wesiteUrlController.clear();
      priceController.clear();

      workingHoursController.clear();

      workingHourInfoController.clear();
    });
  }

  void handleTap(LatLng tappedPoint) {
    markers.clear();
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          icon: BitmapDescriptor.defaultMarker,
        ),
      );

      selectedPoints = tappedPoint;
      print(selectedPoints);
    });
  }

  void fetchSelectedPointsFromAddress() {
    final locationService = LocationService();
    final completeAddress =
        '${addressLineController.text} ${cityController.text} ${countryStringController.text} ${postcodeController.text}';
    locationService.getCoordsFromAddress(completeAddress).then((place) {
      final lat = place['latitude'];
      final lng = place['longitude'];
      final selectedPoint = LatLng(lat, lng);
      setState(() {
        selectedPoints = selectedPoint;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editMode ? 'Update Station' : 'Add Station'),
        centerTitle: true,
      ),
      body: isCompleted
          ? buildCompleted()
          : Stepper(
              type: StepperType.horizontal,
              steps: getSteps(),
              currentStep: currentStep,
              onStepContinue: () {
                setState(() {
                  if (currentStep < 1) {
                    if (currentStep == 0 && formKey1.currentState!.validate()) {
                      if (editMode) {
                        final oldAddressLine = widget.station!.addressLine;
                        final oldCity = widget.station!.city;
                        final oldCountry = widget.station!.countryString;
                        final oldPostcode = widget.station!.postCode;
                        final newAddressLine = addressLineController.text;
                        final newCity = cityController.text;
                        final newCountry = countryStringController.text;
                        final newPostcode = postcodeController.text;

                        if (oldAddressLine != newAddressLine ||
                            oldCity != newCity ||
                            oldCountry != newCountry ||
                            oldPostcode != newPostcode) {
                          fetchSelectedPointsFromAddress();
                        }
                      }

                      if (selectedPoints == null) {
                        fetchSelectedPointsFromAddress();
                        currentStep++;
                      } else {
                        currentStep++;
                      }
                    }
                  } else if (currentStep < 2 && currentStep >= 1) {
                    currentStep++;
                  } else {
                    if (formKey2.currentState!.validate()) {
                      showConfirmationDialog(context);
                    }
                  }
                  return;
                });
              },
              onStepTapped: (step) => setState(() => currentStep = step),
              onStepCancel: currentStep == 0
                  ? null
                  : () => setState(() => currentStep -= 1),
              controlsBuilder: (context, controlDetails) {
                final isLastStep = currentStep == getSteps().length - 1;

                return Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controlDetails.onStepContinue,
                          child: Text(isLastStep ? 'CONFIRM' : 'Next'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (currentStep != 0)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: controlDetails.onStepCancel,
                            child: const Text('BACK'),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (currentContext) {
        return AlertDialog(
          title: Text(editMode ? 'Update Station' : 'Add Station'),
          content: Text(editMode
              ? 'Are you sure to update this station?'
              : 'Are you sure to save this station?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(currentContext).pop();
                onSaveOrUpdateStation(context);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: Navigator.of(currentContext).pop,
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  List<Step> getSteps() {
    return [
      buildStepOne(formKey1),
      buildStepTwo(),
      buildStepThree(formKey2),
    ];
  }

  Step buildStepOne(GlobalKey<FormState> formKey) {
    return Step(
      state: StepState.disabled,
      isActive: currentStep >= 0,
      title: const Text(''),
      content: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Step 1: Name and Address Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                if (value.length < 5 && value.length < 100) {
                  return 'Please enter a name between 5 and 99 characters long';
                }
                if (!value.contains(RegExp(r'(?=.{3,})(?=.*[a-zA-Z])'))) {
                  return 'name must contain at least 3 letters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: addressLineController,
              decoration: const InputDecoration(labelText: 'Address Line'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                if (value.length < 5 && value.length < 256) {
                  return 'Please enter an address between 5 and 255 characters long';
                }
                if (!value.contains(RegExp(r'(?=.{3,})(?=.*[a-zA-Z])'))) {
                  return 'address must contain at least 3 letters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'City'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a city';
                }
                if (value.length < 2 && value.length < 100) {
                  return 'Please enter a city between 2 and 99 characters long';
                }
                if (!value.contains(RegExp(r'(?=.{3,})(?=.*[a-zA-Z])'))) {
                  return 'city must contain at least 3 letters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: countryStringController,
              decoration: const InputDecoration(labelText: 'Country'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a country';
                }
                if (value.length < 5 && value.length < 100) {
                  return 'Please enter a country between 5 and 99 characters long';
                }
                if (!value.contains(RegExp(r'(?=.{3,})(?=.*[a-zA-Z])'))) {
                  return 'country must contain at least 3 letters';
                }
                return null;
              },
            ),
            //     const SizedBox(height: 20),
            //     const Text("Country", style: TextStyle(fontSize: 16)),
            //     Autocomplete<String>(
            //       initialValue: countryStringController.value,
            //       optionsBuilder: (TextEditingValue textEditingValue) {
            //         if (textEditingValue.text == '') {
            //           return const [];
            //         }

            //         final countryNames = Country.values
            //             .map((Country option) => option.name)
            //             .toList();

            //         return countryNames.where((String option) {
            //           return option
            //               .toLowerCase()
            //               .contains(textEditingValue.text.toLowerCase());
            //         });
            //       },
            //       optionsViewBuilder: (context, onSelected, options) {
            //         return Material(
            //           elevation: 4.0,
            //           child: ListView.builder(
            //             padding: EdgeInsets.zero,
            //             itemCount: options.length,
            //             itemBuilder: (context, index) {
            //               final option = options.elementAt(index);
            //               return ListTile(
            //                 title: Text(option),
            //                 onTap: () => onSelected(option),
            //               );
            //             },
            //           ),
            //         );
            //       },
            //       onSelected: (String selection) {
            //         countryStringController.text = selection;
            //       },
            //     ),

            const SizedBox(height: 20),
            TextFormField(
              controller: postcodeController,
              decoration: const InputDecoration(labelText: 'Postcode'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a postcode';
                }
                if (value.length < 4 && value.length < 20) {
                  return 'Please enter a postcode between 4 and 20 characters long';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: fetchCurrentLocation,
                child: const Text('Get My Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isDraggable = true;
  Step buildStepTwo() {
    return Step(
      state: StepState.disabled,
      isActive: currentStep >= 1,
      title: const Text(''),
      content: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          const Text(
            'Step 2: Pin Location on Map',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            height: 400,
            color: Colors.grey,
            child: selectedPoints == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    onMapCreated: (controller) {
                      this.controller = controller;
                      setState(() {
                        selectedPoints = LatLng(
                          currentLocation!.latitude,
                          currentLocation!.longitude,
                        );
                      });
                    },
                    initialCameraPosition: CameraPosition(
                      target: selectedPoints!,
                      zoom: 12,
                    ),

                    markers: {
                      Marker(
                        markerId: const MarkerId('current'),
                        position: selectedPoints!,
                        draggable: isDraggable,
                        onDragEnd: (dragEndPosition) {
                          setState(() {
                            selectedPoints = dragEndPosition;
                          });
                        },
                      ),
                    },
                    //     onTap: handleTap,
                  ),
          ),
        ],
      ),
    );
  }

  Step buildStepThree(GlobalKey<FormState> formKey) {
    final stationProvider = context.watch<StationProvider>();
    return Step(
      state: StepState.disabled,
      isActive: currentStep >= 2,
      title: const Text(''),
      content: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Step 3: Contact info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              controller: phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (widget.isEditing == false || value != "unknown") {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  if (value.length < 7 && value.length < 50) {
                    return 'Phone number information must be between 7 and 49 characters long';
                  }
                  return null;
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              validator: (value) {
                if (widget.isEditing == false || value != "unknown") {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email';
                  }
                  if (value.length < 6 && value.length < 100) {
                    return 'Email must be between 6 and 99 characters long';
                  }
                  return null;
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Operator Website URL (Optional)',
                labelStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              keyboardType: TextInputType.url,
              controller: wesiteUrlController,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Free Charging?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text("No"),
                Switch(
                  value: isFreeCharging,
                  onChanged: (value) {
                    setState(() {
                      isFreeCharging = value;
                    });
                  },
                ),
                const Text("Yes"),
              ],
            ),
            Visibility(
              visible: !isFreeCharging,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 100,
                  minWidth: 300,
                ),
                child: TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price Information',
                      helperText:
                          "Enter exact price or link to pricing information",
                      labelStyle: TextStyle(fontSize: 15),
                      floatingLabelStyle: TextStyle(fontSize: 24),
                      hintText: '',
                    ),
                    validator: (value) {
                      if ((value == null || value.isEmpty || !isFreeCharging) &&
                          widget.isEditing == false) {
                        return 'Please enter a price';
                      }
                      return null;
                    }),
              ),
            ),
            Row(
              children: [
                const Text(
                  'Opened NONSTOP?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const Text("No"),
                Switch(
                    value: isOpenNonStop,
                    onChanged: (bool value) {
                      if (value == true) {
                        workingHourInfoController.text = "NONSTOP";
                      } else {
                        workingHourInfoController.text = "";
                      }
                      setState(() {
                        isOpenNonStop = value;
                      });
                    }),
                const Text("Yes"),
              ],
            ),
            Visibility(
              visible: !isOpenNonStop,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 100,
                  minWidth: 300,
                ),
                child: TextFormField(
                  controller: workingHourInfoController,
                  decoration: const InputDecoration(
                    labelText: 'Working Hours Information',
                    helperText: "Enter information about working hours",
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  validator: (value) {
                    if ((value == null || value.isEmpty) &&
                        isOpenNonStop == false &&
                        widget.isEditing == false) {
                      return 'Please enter information about working hours';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Usage Type", style: TextStyle(fontSize: 15)),
            const SizedBox(height: 5),
            DropdownButton<UsageType>(
              hint: const Text('Select Usage Type'),
              value: selectedUsageType,
              items: UsageType.values.map((UsageType usageType) {
                return DropdownMenuItem<UsageType>(
                  value: usageType,
                  child: Text(usageType.title),
                );
              }).toList(),
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (value) {
                setState(() {
                  selectedUsageType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              children: stationProvider.amenities.map((currentAmenity) {
                final isSelected =
                    stationProvider.selectedAmenities.contains(currentAmenity);

                return ChoiceChip(
                  label: Text(currentAmenity.title),
                  selected: isSelected,
                  onSelected: (value) =>
                      stationProvider.toggleAmenity(currentAmenity),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCompleted() {
    final provider = context.watch<ConnectionProvider>();
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Step 4: Add Connections',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: provider.evConnections.length,
            itemBuilder: (context, index) {
              final evConnection = provider.evConnections[index];
              return InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddConnectionPage(
                      isEditMode: true,
                      connection: evConnection,
                    ),
                  ),
                ),
                child: Card(
                  child: ListTile(
                    title: Text(evConnection.connectionType.title),
                    subtitle: Text('${evConnection.powerKW} kW'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          provider.deleteConnection(evConnection.id!, index),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddConnectionPage(isEditMode: false),
                  ),
                );
              },
              child: const Text('Add Connection')),
        ],
      ),
    );
  }

  Future<void> fetchCurrentLocation() async {
    final locationService = LocationService();
    currentLocation = await locationService.getCurrentLocation();
    selectedPoints =
        LatLng(currentLocation!.latitude, currentLocation!.longitude);
    final addressDetails = await locationService.getAddressFromLatLng(
      context,
      currentLocation!.latitude,
      currentLocation!.longitude,
    );

    addressLineController.text = addressDetails['address'];
    cityController.text = addressDetails['city'];
    countryStringController.text = addressDetails['country'];
    postcodeController.text = addressDetails['postcode'];
  }

  Future<void> setLocationToChargingCoordinates() async {
    if (widget.latitudeFromCharging != null &&
        widget.longitudeFromCharging != null) {
      final locationService = LocationService();
      selectedPoints = LatLng(
        widget.latitudeFromCharging!,
        widget.longitudeFromCharging!,
      );
      final addressDetails = await locationService.getAddressFromLatLng(
        context,
        widget.latitudeFromCharging!,
        widget.longitudeFromCharging!,
      );
      if (addressDetails.isEmpty) {
        print("No location from charging");
      }
      addressLineController.text = addressDetails['address'];
      cityController.text = addressDetails['city'];
      countryStringController.text = addressDetails['country'];
      postcodeController.text = addressDetails['postcode'];
      setState(() {});
    } else {
      print("No location from charging");
    }
  }
}
