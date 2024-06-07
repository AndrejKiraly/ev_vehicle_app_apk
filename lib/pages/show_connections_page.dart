import 'package:ev_vehicle_app/connection_card.dart';
import 'package:ev_vehicle_app/models/ev_connection.dart';
import 'package:flutter/material.dart';

class ShowConnectionsPage extends StatelessWidget {
  final List<EvConnection> connections;
  final bool isLoggedIn;

  ShowConnectionsPage({required this.connections, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connections'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: connections.map((connection) {
                return ConnectionCard(
                    connection: connection, isLoggedIn: isLoggedIn);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
