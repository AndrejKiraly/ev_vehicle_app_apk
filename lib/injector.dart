import 'package:ev_vehicle_app/api/client.dart';
import 'package:ev_vehicle_app/providers/chargings_provider.dart';
import 'package:ev_vehicle_app/providers/enode_vehicle_provider.dart';
import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:ev_vehicle_app/providers/station_detail_provider.dart';
import 'package:ev_vehicle_app/providers/station_provider.dart';
import 'package:ev_vehicle_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/connection_provider.dart';

class Injector extends StatelessWidget {
  final Widget? router;

  const Injector({Key? key, this.router}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dio = Client().init();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider(dio)),
        ChangeNotifierProvider(create: (_) => StationProvider(dio)),
        ChangeNotifierProvider(create: (_) => LoginProvider(dio)),
        ChangeNotifierProvider(create: (_) => EnodeVehicleProvider(dio)),
        ChangeNotifierProvider(create: (_) => ChargingsProvider(dio)),
        ChangeNotifierProvider(create: (_) => StationDetailProvider(dio)),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: router,
    );
  }
}
