import 'package:ev_vehicle_app/pages/chargings_diary_page.dart';
import 'package:flutter/material.dart';

class UserDiaryPage extends StatefulWidget {
  const UserDiaryPage({Key? key}) : super(key: key);

  @override
  _UserDiaryPageState createState() => _UserDiaryPageState();
}

class _UserDiaryPageState extends State<UserDiaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Diary'),
      ),
      body: Row(
        children: [
          // Expanded(
          //   child: ListTile(
          //     onTap: () {
          //       // Open routes history page
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => RoutesHistoryPage()),
          //       );
          //     },
          //     tileColor: Colors.blue,
          //     title: Text(
          //       'Routes',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 20,
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListTile(
              onTap: () {
                // Open chargings history page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChargingsDiaryPage()),
                );
              },
              tileColor: Colors.green,
              title: Text(
                'Chargings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoutesHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Routes History'),
      ),
      body: Center(
        child: Text('Routes History Page'),
      ),
    );
  }
}

class ChargingsHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chargings History'),
      ),
      body: Center(
        child: Text('Chargings History Page'),
      ),
    );
  }
}
