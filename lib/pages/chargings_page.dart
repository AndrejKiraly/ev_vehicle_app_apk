import 'package:ev_vehicle_app/providers/chargings_provider.dart';
import 'package:ev_vehicle_app/widgets/toggleButtonCode/charging_widget_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChargingsPage extends StatefulWidget {
  bool is_user = false;
  int? stationId;

  ChargingsPage({Key? key, required this.is_user, required this.stationId})
      : super(key: key);
  @override
  State<ChargingsPage> createState() => _ChargingsPageState();
}

class _ChargingsPageState extends State<ChargingsPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.is_user == true) {
        await context.read<ChargingsProvider>().fetchUserChargings();
      } else if (widget.is_user == false && widget.stationId != null) {
        await context
            .read<ChargingsProvider>()
            .fetchStationsChargings(widget.stationId!);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chargings = context.watch<ChargingsProvider>().chargings;
    final isLoading = context.watch<ChargingsProvider>().isLoading;
    final errorMessage = context.watch<ChargingsProvider>().errorMessage;
    return Scaffold(
      appBar: AppBar(
        title: widget.is_user == true
            ? const Text('User Chargings')
            : const Text('Station Chargings'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != ''
              ? Center(
                  child: Text(errorMessage),
                )
              : chargings.isEmpty
                  ? const Center(
                      child: Text('No chargings found!'),
                    )
                  : ListView.builder(
                      itemCount: chargings.length,
                      itemBuilder: (ctx, index) {
                        final charging = chargings[index];
                        return ChargingCard(
                          charging: charging,
                          is_user: widget.is_user,
                          index: index,
                        );
                      },
                    ),
    );
  }
}
