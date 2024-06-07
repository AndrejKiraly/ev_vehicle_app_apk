import 'package:flutter/material.dart';

class AdvancedFilterScreen extends StatefulWidget {
  String? rating = '1';
  bool? isMembershipRequired = false;
  bool? isFree = false;
  bool? isPayAtLocation = false;
  bool? isAccessKeyRequired = false;
  String? energySource = 'Unknown';
  String? accessTypeTitle = 'Unknown';

  bool? isOperational = true;
  String? currentType = 'Unknown';
  String? chargingLevel = 'Unknown';
  bool? isFastChargeCapable = false;

  @override
  _AdvancedFilterScreenState createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends State<AdvancedFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Advanced Filter'),
      ),
      body: Column(
        children: [
          // Scrollable widget for filter options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Rating filter
                  ListTile(
                    title: Text('Rating'),
                    trailing: DropdownButton<String>(
                      value: widget.rating,
                      onChanged: (String? newValue) {
                        setState(() {
                          widget.rating = newValue;
                        });
                      },
                      items: <String>['1', '2', '3', '4', '5']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),

                  // Membership required filter
                  CheckboxListTile(
                    title: Text('Membership Required'),
                    value: widget.isMembershipRequired,
                    onChanged: (bool? newValue) {
                      setState(() {
                        widget.isMembershipRequired = newValue;
                      });
                    },
                  ),

                  // Free filter
                  CheckboxListTile(
                    title: Text('Free'),
                    value: widget.isFree,
                    onChanged: (bool? newValue) {
                      setState(() {
                        widget.isFree = newValue;
                      });
                    },
                  ),

                  // Pay at location filter
                  CheckboxListTile(
                    title: Text('Pay at Location'),
                    value: widget.isPayAtLocation,
                    onChanged: (bool? newValue) {
                      setState(() {
                        widget.isPayAtLocation = newValue;
                      });
                    },
                  ),

                  // Access key required filter
                  CheckboxListTile(
                    title: Text('Access Key Required'),
                    value: widget.isAccessKeyRequired,
                    onChanged: (bool? newValue) {
                      setState(() {
                        widget.isAccessKeyRequired = newValue;
                      });
                    },
                  ),

                  // Energy source filter
                  ListTile(),

                  // Button to apply filters
                  ElevatedButton(
                    child: Text('Apply Filters'),
                    onPressed: () {
                      // Perform filtering logic here
                      // You can access the selectedOptions list to get the selected filter parameters
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
