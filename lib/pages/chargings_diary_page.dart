import 'package:ev_vehicle_app/models/charging.dart';
import 'package:ev_vehicle_app/providers/chargings_provider.dart';
import 'package:ev_vehicle_app/widgets/toggleButtonCode/charging_widget_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChargingsDiaryPage extends StatefulWidget {
  @override
  _ChargingsDiaryPageState createState() => _ChargingsDiaryPageState();
}

class _ChargingsDiaryPageState extends State<ChargingsDiaryPage> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<ChargingsProvider>()
          .fetchMonthlyChargingsSummary(selectedYear, selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chargings = context.watch<ChargingsProvider>().chargings;
    final isLoading = context.watch<ChargingsProvider>().isLoading;
    final errorMessage = context.watch<ChargingsProvider>().errorMessage;
    final totalChargingsCost =
        context.watch<ChargingsProvider>().totalChargingsCost;
    final totalChargingsEnergy =
        context.watch<ChargingsProvider>().totalChargingsEnergy;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chargings Diary'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: selectedYear,
                onChanged: (newValue) {
                  setState(() async {
                    selectedYear = newValue!;
                    await context
                        .read<ChargingsProvider>()
                        .fetchMonthlyChargingsSummary(
                            selectedYear, selectedMonth);
                  });
                },
                items: _buildYearDropdownItems(),
              ),
              SizedBox(width: 16),
              DropdownButton<int>(
                value: selectedMonth,
                onChanged: (newValue) {
                  setState(() async {
                    selectedMonth = newValue!;
                    await context
                        .read<ChargingsProvider>()
                        .fetchMonthlyChargingsSummary(
                            selectedYear, selectedMonth);
                  });
                },
                items: _buildMonthDropdownItems(),
              ),
            ],
          ),
          Expanded(
            child: _buildChargingsList(chargings),
          ),
          _buildStatistics(totalChargingsEnergy, totalChargingsCost),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> _buildYearDropdownItems() {
    // Replace with your implementation to get available years from Time library
    List<int> availableYears =
        List.generate(DateTime.now().year - 2019, (index) => 2020 + index);

    return availableYears.map((year) {
      return DropdownMenuItem<int>(
        value: year,
        child: Text(year.toString()),
      );
    }).toList();
  }

  List<DropdownMenuItem<int>> _buildMonthDropdownItems() {
    // Replace with your implementation to get available months from Time library
    List<int> availableMonths = List.generate(12, (index) => index + 1);

    return availableMonths.map((month) {
      return DropdownMenuItem<int>(
        value: month,
        child: Text(month.toString()),
      );
    }).toList();
  }

  Widget _buildChargingsList(List<Charging> chargings) {
    // Replace with your implementation to get chargings from ChargingsProvider.dart

    return ListView.builder(
      itemCount: chargings.length,
      itemBuilder: (context, index) {
        Charging charging = chargings[index];
        return ChargingCard(charging: charging, is_user: true, index: index);
      },
    );
  }

  Widget _buildStatistics(
    int totalChargingsEnergy,
    double totalChargingsCost,
  ) {
    // Replace with your implementation to calculate statistics from ChargingsProvider.dart

    //ChargingsProvider.calculateTotalPrice(selectedYear, selectedMonth);

    //ChargingsProvider.calculateTotalEnergySpend(selectedYear, selectedMonth);

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Total Price: ${totalChargingsCost.toStringAsFixed(2)} €'),
          Text('Total Energy Spend: ${totalChargingsEnergy.toString()} kWh'),
        ],
      ),
    );
  }
}
