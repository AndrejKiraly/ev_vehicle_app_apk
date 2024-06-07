import 'package:ev_vehicle_app/pages/chargings_diary_page.dart';
import 'package:ev_vehicle_app/pages/profile_page.dart';
import 'package:ev_vehicle_app/pages/stations_page.dart';
import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/auth_pages/auth_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loginProvider = context.read<LoginProvider>();
      await loginProvider.checkLogin();
    });
  }

  int _currentIndex = 0;
  final screens = [
//     const EvStationsMap(), //Center(child: Text('Routes', style: TextStyle(fontSize: 60))),
    const StationsPage(),
    const ProfilePage(),

//     const RoutePage(),
    //const CreateRoutePage(),
    //const RegistrationPage(),
    ChargingsDiaryPage(),
  ];

  void _changeIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<LoginProvider>().isLoggedIn;
    return Scaffold(
      appBar: _currentIndex == 1 || (_currentIndex == 2 && !isLoggedIn)
          ? AppBar(
              title: const Text('EV Car APP'),
              backgroundColor: Colors.red,
              centerTitle: true,
              foregroundColor: Colors.white,
            )
          : null,
      body: _currentIndex == 1 || _currentIndex == 2
          ? isLoggedIn
              ? _currentIndex == 1
                  ? const ProfilePage()
                  : ChargingsDiaryPage()
              : _currentIndex == 1
                  ? const AuthPage()
                  : () {
                      _changeIndex(1);
                      return const AuthPage();
                    }()
          : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: isLoggedIn ? "Profile" : "Login",
            backgroundColor: Colors.grey,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "User Diary",
            backgroundColor: Colors.grey,
          ),
        ],
        onTap: _changeIndex,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
