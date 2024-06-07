import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';
import 'register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<LoginProvider>().isLogin;
    return isLogin ? const LoginPage() : const RegisterPage();
  }
}
