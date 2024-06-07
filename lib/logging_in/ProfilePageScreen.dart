import 'package:ev_vehicle_app/logging_in/authorization_service.dart';
import 'package:ev_vehicle_app/pages/auth_pages/login_page.dart';
import 'package:ev_vehicle_app/pages/profile_page.dart';
import 'package:flutter/material.dart';

class ProfilePageScreen extends StatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  _ProfilePageScreenState createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  @override
  Widget build(BuildContext context) {
    if (LoginService().isLoggedIn() == false) {
      return const LoginPage();
    }
    if (LoginService().isLoggedIn() == true) {
      return const ProfilePage();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Text('Error: Could not load Profile Page'),
    );
  }
}
