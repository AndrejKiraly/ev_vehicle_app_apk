import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({Key? key}) : super(key: key);

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  String _currentPassword = "";
  String _newPassword = "";
  String _confirmPassword = "";
  bool _obscureText = true; // Flag to control password visibility

  // Function to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Colors.red,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Current Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Current password is required";
                  }
                  return null;
                },
                onChanged: (value) => setState(() => _currentPassword = value),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "New password is required";
                  }
                  // Add additional validation for password strength (optional)
                  return null;
                },
                onChanged: (value) => setState(() => _newPassword = value),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                obscureText: _obscureText,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Confirm new password is required";
                  }
                  if (value != _newPassword) {
                    return "Passwords do not match";
                  }
                  return null;
                },
                onChanged: (value) => setState(() => _confirmPassword = value),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response =
                        await context.read<LoginProvider>().forgotPassword(
                              _newPassword,
                              _currentPassword,
                              _confirmPassword,
                            );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response!.statusMessage.toString()),
                      ),
                    );
                  }
                },
                child: const Text("Change Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
