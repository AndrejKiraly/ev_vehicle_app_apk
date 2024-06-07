import 'package:ev_vehicle_app/api/client.dart';
import 'package:ev_vehicle_app/pages/profile_page.dart';
import 'package:ev_vehicle_app/widgets/toggleButtonCode/auth_widget.dart';
import 'package:flutter/material.dart';

import '../../api/api_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AuthWidget(
      formKey: formKey,
      isLogin: true,
      isLoading: isLoading,
      emailController: emailController..text = '',
      passwordController: passwordController..text = '',
      onSignIn: login,
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
}
