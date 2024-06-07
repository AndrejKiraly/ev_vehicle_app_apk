import 'dart:convert';

import 'package:ev_vehicle_app/enums/amenities_types_class.dart';
import 'package:ev_vehicle_app/enums/current_type_class.dart';
import 'package:ev_vehicle_app/enums/usage_type_class.dart';
import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:provider/provider.dart';

import '../enums/connection_types_class.dart';
import '../models/filter_data.dart';

class FilterPage extends StatefulWidget {
  final String latitude;
  final String longitude;
  final LatLng? swBounds;
  final LatLng? neBound;

  const FilterPage({
    Key? key,
    required this.latitude,
    required this.longitude,
    this.swBounds,
    this.neBound,
  }) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final powerController = TextEditingController();
  List<UsageType> selectedUsageTypes = [];
  List<Amenity> selectedAmenities = [];
  bool? isFree;
  List<CurrentType> selectedCurrentTypes = [];
  List<ConnectionType> selectedConnectionTypes = [];
  bool seeMoreClicked = false;
  String? selectedRating;
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<StationProvider>().fetchAmenities();
      await checkFilter();
    });
    super.initState();
  }

  Future<void> checkFilter() async {
    final filterData = await storage.read(key: 'filterData');

    if (filterData != null) {
      final filter = FilterData.fromJson(json.decode(filterData));

      powerController.text = filter.power ?? '';
      selectedUsageTypes = filter.usageTypes!;
      selectedAmenities = filter.amenities!;
      isFree = filter.isFree;
      selectedCurrentTypes = filter.currentTypes!;
      selectedConnectionTypes = filter.connectionTypes!;
      selectedRating = filter.rating;
      setState(() {});
    }
  }

  Future<void> clearFilter() async {
    isFree = null;
    selectedRating = null;
    await storage.delete(key: 'filterData');
  }

  @override
  Widget build(BuildContext context) {
    final stationProvider = context.watch<StationProvider>();

    return Scaffold(
        appBar: AppBar(
          title: const Text('Filter Options'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Power (kw)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: TextFormField(
                        controller: powerController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          hintText: 'Enter Power in kw (e.g. 50)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Usage Types',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0,
                  children: UsageType.values.map((currentUsageType) {
                    final isSelected =
                        selectedUsageTypes.contains(currentUsageType);

                    return ChoiceChip(
                      label: Text(currentUsageType.title),
                      selected: isSelected,
                      onSelected: (value) {
                        setState(() {
                          if (isSelected) {
                            selectedUsageTypes.remove(currentUsageType);
                          } else {
                            selectedUsageTypes.add(currentUsageType);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),
                const Text('Amenities', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0,
                  children: stationProvider.amenities.map((currentAmenity) {
                    final isSelected =
                        selectedAmenities.contains(currentAmenity);

                    return ChoiceChip(
                        label: Text(currentAmenity.title),
                        selected: isSelected,
                        onSelected: (value) {
                          setState(() {
                            if (isSelected) {
                              selectedAmenities.remove(currentAmenity);
                            } else {
                              selectedAmenities.add(currentAmenity);
                            }
                          });
                        });
                  }).toList(),
                ),
                const SizedBox(height: 10),
                const Text('Free Charging', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0,
                  children: [
                    ChoiceChip(
                      label: const Text("Free"),
                      selected: isFree == true,
                      onSelected: (selected) {
                        setState(() {
                          isFree = true;
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text("Paid"),
                      selected: isFree == false,
                      onSelected: (selected) {
                        setState(() {
                          isFree = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Current Types',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8.0,
                  children: CurrentType.values.map((currentConnectionType) {
                    final isSelected =
                        selectedCurrentTypes.contains(currentConnectionType);

                    return ChoiceChip(
                      label: Text(currentConnectionType.title),
                      selected: isSelected,
                      onSelected: (value) {
                        setState(() {
                          if (isSelected) {
                            selectedCurrentTypes.remove(currentConnectionType);
                          } else {
                            selectedCurrentTypes.add(currentConnectionType);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                const Text('Connection Type', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                  ),
                  itemCount: seeMoreClicked ? ConnectionType.values.length : 6,
                  itemBuilder: (context, index) {
                    final currentConnectionType = ConnectionType.values[index];
                    final isSelected =
                        selectedConnectionTypes.contains(currentConnectionType);
                    return ChoiceChip(
                        label: Text(currentConnectionType.title),
                        selected: isSelected,
                        onSelected: (value) {
                          setState(() {
                            if (isSelected) {
                              selectedConnectionTypes
                                  .remove(currentConnectionType);
                            } else {
                              selectedConnectionTypes
                                  .add(currentConnectionType);
                            }
                          });
                        });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: seeMoreClicked
                            ? () {
                                setState(() {
                                  seeMoreClicked = false;
                                });
                              }
                            : () {
                                setState(() {
                                  seeMoreClicked = true;
                                });
                              },
                        child: Text(
                            seeMoreClicked ? 'See Less' : 'More Connections')),
                  ],
                ),

                //dropdown for rating
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Rating',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(),
                        ),
                        value: selectedRating,
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('1'),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('2'),
                          ),
                          DropdownMenuItem(
                            value: '3',
                            child: Text('3'),
                          ),
                          DropdownMenuItem(
                            value: '4',
                            child: Text('4'),
                          ),
                          DropdownMenuItem(
                            value: '5',
                            child: Text('5'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            selectedRating = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    setState(() {
                      powerController.clear();
                      selectedUsageTypes.clear();
                      selectedAmenities.clear();
                      isFree = null;
                      selectedCurrentTypes.clear();
                      selectedConnectionTypes.clear();
                      seeMoreClicked = false;
                      selectedRating = null;
                    });
                    await storage.delete(key: 'filterData');
                  },
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final filterData = FilterData(
                      latitude: widget.latitude,
                      longitude: widget.longitude,
                      boundSw:
                          '${widget.swBounds!.latitude.toString()},${widget.swBounds!.longitude.toString()}',
                      boundsNe:
                          '${widget.neBound!.latitude.toString()},${widget.neBound!.longitude.toString()}',
                      power: powerController.text == ''
                          ? null
                          : powerController.text,
                      usageTypes: selectedUsageTypes,
                      amenities: selectedAmenities,
                      isFree: isFree,
                      currentTypes: selectedCurrentTypes,
                      connectionTypes: selectedConnectionTypes,
                      rating: selectedRating,
                    );

                    await context
                        .read<StationProvider>()
                        .filterStations(filterData: filterData);
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ));
  }
}
