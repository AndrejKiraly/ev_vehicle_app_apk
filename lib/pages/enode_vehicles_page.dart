import 'package:ev_vehicle_app/pages/enode_vehicle_page.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ev_vehicle_app/models/enode_vehicle.dart';
import 'package:url_launcher/url_launcher.dart';
import '/providers/enode_vehicle_provider.dart';

class EnodeVehiclesPage extends StatefulWidget {
  const EnodeVehiclesPage({Key? key}) : super(key: key);

  @override
  _EnodeVehiclesPageState createState() => _EnodeVehiclesPageState();
}

class _EnodeVehiclesPageState extends State<EnodeVehiclesPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EnodeVehicleProvider>().fetchEnodeVehicles();

      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final enodeVehicles = context.watch<EnodeVehicleProvider>().enodeVehicles;
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Page'),
      ),
      body: context.watch<EnodeVehicleProvider>().isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: enodeVehicles.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20),
                            Text('No vehicles found!'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () async {
                                  var link = await context
                                      .read<EnodeVehicleProvider>()
                                      .linkEnodeVehicle();

                                  Uri uri = Uri.parse(link['link']);
                                  await launchUrl(uri);
                                },
                                child: Text("Connect car with Enode API"))
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: enodeVehicles.length,
                              itemBuilder: (context, index) {
                                final enodeVehicle = enodeVehicles[index];
                                return Card(
                                  child: ListTile(
                                    title: Text('${enodeVehicle.brand}'),
                                    subtitle: Text('${enodeVehicle.id}'),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return EnodeVehiclePage(
                                            enodeVehicleId: enodeVehicle.id);
                                      }));
                                    },
                                    // trailing: IconButton(
                                    //   icon: const Icon(Icons.delete),
                                    //   onPressed: () async {},
                                    // ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () async {
                                  var link = await context
                                      .read<EnodeVehicleProvider>()
                                      .linkEnodeVehicle();

                                  Uri uri = Uri.parse(link['link']);
                                  await launchUrl(uri);
                                },
                                child: Text("Connect car with Enode API")),
                            SizedBox(height: 20),
                            ElevatedButton(
                                onPressed: () async {
                                  await context
                                      .read<EnodeVehicleProvider>()
                                      .unlinkEnodeIntegration();
                                },
                                child: Text("Unlink Enode Integration"))
                          ],
                        ),
                ),
              ),
            ),
    );
  }
}
