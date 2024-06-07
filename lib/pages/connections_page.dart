import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/add_connection_page.dart';
import '../providers/connection_provider.dart';

class ConnectionsPage extends StatefulWidget {
  final int? stationId;
  final bool isEditMode;
  const ConnectionsPage({
    super.key,
    required this.stationId,
    this.isEditMode = false,
  });

  @override
  State<ConnectionsPage> createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ConnectionProvider>();
      if (widget.isEditMode) await provider.fetchConnections(widget.stationId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConnectionProvider>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: const Text('Connections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddConnectionPage(
                    isEditMode: false,
                    stationId: widget.stationId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: provider.evConnections.length,
                itemBuilder: (context, index) {
                  final evConnection = provider.evConnections[index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddConnectionPage(
                          isEditMode: true,
                          connection: evConnection,
                        ),
                      ),
                    ),
                    child: Card(
                      child: ListTile(
                        title: Text(evConnection.connectionType.title),
                        subtitle: Text('${evConnection.voltage} Volts'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider.deleteConnection(
                              evConnection.id!, index),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
