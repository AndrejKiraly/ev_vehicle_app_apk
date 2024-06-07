import 'package:ev_vehicle_app/api/api_services.dart';
import 'package:ev_vehicle_app/pages/auth_pages/login_page.dart';
import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:ev_vehicle_app/widgets/toggleButtonCode/auth_widget.dart';
import 'package:flutter/material.dart';

import 'package:ev_vehicle_app/api/client.dart';

import '../../api/api_services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthWidget(
      formKey: formKey,
      isLogin: false,
      isLoading: isLoading,
      nameController: nameController,
      usernameController: usernameController,
      emailController: emailController,
      passwordController: passwordController,
      confirmPasswordController: confirmPasswordController,
      onSignIn: register,
    );
  }

  Future<void> login() async {
    final valueKey = formKey.currentState!.validate();

    if (!valueKey) return;
    final dioClient = Client();

    final apiService = ApiService(dioClient.init());
    await apiService.login(
      context,
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return;
    //Navigator.of(context).push(MaterialPageRoute(

    //));
  }

  void register() {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    final dioClient = Client();

    final apiService = ApiService(dioClient.init());
    apiService.register(
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
      nameController.text,
      usernameController.text,
      context,
    );
    if (!mounted) return;
  }
}
