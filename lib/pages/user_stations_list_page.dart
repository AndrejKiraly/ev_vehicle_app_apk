import 'package:ev_vehicle_app/api/api_services.dart';
import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:ev_vehicle_app/widgets/toggleButtonCode/ev_station_widget_card.dart';
import 'package:ev_vehicle_app/widgets/toggleButtonCode/limited_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UserStationsListPage extends StatefulWidget {
  const UserStationsListPage({Key? key}) : super(key: key);

  @override
  State<UserStationsListPage> createState() => _UserStationsListPageState();
}

class _UserStationsListPageState extends State<UserStationsListPage> {
  int selectedPage = 1;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StationProvider>().fetchUserStations(0);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Stations List'),
      ),
      body: context.watch<StationProvider>().isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                context.watch<StationProvider>().evStation.isEmpty
                    ? const Center(child: Text('No stations found!'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount:
                              context.watch<StationProvider>().evStation.length,
                          itemBuilder: (ctx, index) {
                            final station = context
                                .watch<StationProvider>()
                                .evStation[index];
                            return EvStationCard(
                              station: station,
                              index: index,
                            );
                          },
                        ),
                      ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: LimitedDropdown(
                      itemCount: 1000,
                      initialDisplayCount: selectedPage + 1,
                      itemBuilder: (index) => (index + 1).toString(),
                      selectedValue: selectedPage,
                      onSelected: (newValue) async {
                        setState(() async {
                          selectedPage = newValue;
                          await context
                              .read<StationProvider>()
                              .fetchUserStations(selectedPage);
                        });
                      }),
                ),
              ],
            ),
    );
  }
}
