import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ChangeProfileInfo extends StatefulWidget {
  final String username;
  final String name;
  const ChangeProfileInfo({
    Key? key,
    required this.username,
    required this.name,
  }) : super(key: key);

  @override
  State<ChangeProfileInfo> createState() => _ChangeProfileInfoState();
}

class _ChangeProfileInfoState extends State<ChangeProfileInfo> {
  final _formKey = GlobalKey<FormState>();
  FlutterSecureStorage storage = const FlutterSecureStorage();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      nameController.text = widget.name;
      usernameController.text = widget.username;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Change Profile Information"),
          backgroundColor: Colors.red,
          centerTitle: true,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(false),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                // Set initial value (fetch from user data)
                decoration: const InputDecoration(
                  labelText: "New Username",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Username cannot be empty";
                  }
                  // Add additional validation for username format (optional)
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                // Set initial value (fetch from user data)
                decoration: const InputDecoration(
                  labelText: "New Name",
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await context
                        .read<LoginProvider>()
                        .changeProfileInformation(
                          context,
                          usernameController.text,
                          nameController.text,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response!.statusMessage.toString()),
                      ),
                    );
                  }
                },
                child: const Text("Update Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
