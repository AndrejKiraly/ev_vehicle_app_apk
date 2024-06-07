import 'package:ev_vehicle_app/BottomNavBar.dart';
import 'package:ev_vehicle_app/injector.dart';
import 'package:flutter/material.dart';

void main() => runApp(const Injector(router: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electric Vehical',
      theme: ThemeData(useMaterial3: true),
      home: const BottomNavBar(),
    );
  }
}
