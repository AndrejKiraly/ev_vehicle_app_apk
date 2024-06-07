import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../enums/countries_class.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final TextEditingController _textController = TextEditingController();
  Country? selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text('Select Country:', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      setState(() {
                        _textController.text = '';
                      });
                      return const [];
                    }

                    final countryNames = Country.values
                        .map((Country option) => option.name)
                        .toList();

                    return countryNames.where((String option) {
                      return option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Material(
                      elevation: 4.0,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    );
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _textController.text = selection;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _textController.text.isEmpty
                      ? null
                      : () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Generating Stations...'),
                            ),
                          );
                          final stationProvider =
                              context.read<StationProvider>();
                          setState(() {
                            print(_textController.text);
                            selectedCountry = Country.values.firstWhere(
                              (Country element) =>
                                  element.name == _textController.text,
                            );
                          });
                          await stationProvider.generateStations(
                            selectedCountry!,
                            context,
                          );

                          print(
                              'Selected Country: ${selectedCountry!.name ?? ''}');
                        },
                  child: const Text('Generate Stations'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
