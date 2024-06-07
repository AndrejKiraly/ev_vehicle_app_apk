import 'package:ev_vehicle_app/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWidget extends StatelessWidget {
  const AuthWidget({
    super.key,
    required this.formKey,
    required this.isLogin,
    required this.isLoading,
    required this.emailController,
    required this.passwordController,
    this.nameController,
    this.usernameController,
    this.confirmPasswordController,
    this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final bool isLogin, isLoading;
  final TextEditingController emailController, passwordController;
  final TextEditingController? nameController, usernameController;
  final TextEditingController? confirmPasswordController;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isLogin)
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16.0),
              if (!isLogin) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                  controller: usernameController!,
                  validator: (username) {
                    if (username!.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (!isLogin) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: true,
                  controller: confirmPasswordController!,
                  validator: (username) {
                    if (username!.isEmpty) {
                      return 'Please enter the confirm password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: onSignIn,
                child: Text(isLogin ? 'Login' : 'Register'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin
                        ? 'Don\'t have an account? '
                        : 'Already have an account ? ',
                  ),
                  InkWell(
                    onTap: () => context.read<LoginProvider>().toggleLogin(),
                    child: Text(
                      isLogin ? 'Register' : 'Login',
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
