import 'package:ev_vehicle_app/pages/admin_panel_page.dart';
import 'package:ev_vehicle_app/pages/auth_pages/change_password_page.dart';
import 'package:ev_vehicle_app/pages/chargings_page.dart';
import 'package:ev_vehicle_app/pages/enode_vehicles_page.dart';
import 'package:ev_vehicle_app/pages/user/change_profile_information_page.dart';
import 'package:ev_vehicle_app/pages/user_stations_list_page.dart';
import 'package:ev_vehicle_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/add_station_page.dart';
import '../providers/login_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      await userProvider.fetchUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildProfileHeader(userProvider),
                  _buildDivider(),
                  _buildActionTile('Edit Profile', Icons.person_outline,
                      () async {
                    final response = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChangeProfileInfo(
                          username: userProvider.user.username ?? '',
                          name: userProvider.user.name ?? '',
                        ),
                      ),
                    );

                    if (response != null) {
                      await userProvider.fetchUserInfo();
                    }
                  }),
                  _buildActionTile('Change Password', Icons.lock_outline, () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChangePasswordForm(),
                    ));
                  }),
                  _buildActionTile('Add Station', Icons.electrical_services,
                      () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddStationPage(isEditing: false),
                    ));
                  }),
                  _buildActionTile('Enode Vehicles', Icons.electric_car, () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EnodeVehiclesPage(),
                    ));
                  }),
                  _buildActionTile('My Chargings', Icons.charging_station, () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChargingsPage(
                        is_user: true,
                        stationId: null,
                      ),
                    ));
                  }),
                  _buildActionTile('My Stations', Icons.ev_station, () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserStationsListPage(),
                    ));
                  }),
                  _buildDivider(),
                  if (userProvider.user.admin!)
                    _buildActionTile('Admin Panel', Icons.admin_panel_settings,
                        () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AdminPanelPage(),
                      ));
                    }),
                  _buildDivider(),
                  _buildActionTile('Logout', Icons.logout, () async {
                    final loginProvider = context.read<LoginProvider>();
                    await loginProvider.logout();
                  }),
                ],
              ),
            ),
    );
  }
}

Widget _buildProfileHeader(UserProvider userProvider) {
  return Column(
    children: [
      const SizedBox(height: 16),
      Text(
        userProvider.user.username ?? 'Username',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        userProvider.user.email ?? 'Email',
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    ],
  );
}

// Helper function to build action tiles
Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: onTap,
  );
}

// Helper function to build dividers
Widget _buildDivider() {
  return const Divider(
    height: 24,
    thickness: 1,
    indent: 16,
    endIndent: 16,
  );
}
