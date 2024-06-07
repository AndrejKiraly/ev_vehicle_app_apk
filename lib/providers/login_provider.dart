import 'package:dio/dio.dart';
import 'package:ev_vehicle_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../api/api_services.dart';

class LoginProvider extends ChangeNotifier {
  final Dio client;
  final ApiService apiService;

  LoginProvider(this.client) : apiService = ApiService(client);

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String _errorMessage = '';

  bool _isLogin = true;
  bool get isLogin => _isLogin;

  void toggleLogin() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    const storage = FlutterSecureStorage();
    final isLoggedIn = await storage.read(key: 'isLoggedIn');

    if (isLoggedIn == 'true') {
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }

    notifyListeners();
  }

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    const secureStorage = FlutterSecureStorage();
    _isLoggedIn = false;

    await apiService.logout();
    await secureStorage.deleteAll();

    notifyListeners();
  }

  Future<Response?> forgotPassword(
    String password,
    String currentPassword,
    String confirmationPassword,
  ) async {
    try {
      final response = await apiService.changePassword(
        password,
        currentPassword,
        confirmationPassword,
      );

      return response;
    } catch (error) {
      _errorMessage = 'Failed to add charging: $error';
      notifyListeners();
      return null;
    }
  }

  Future<Response?> changeProfileInformation(
    BuildContext context,
    String username,
    String name,
  ) async {
    try {
      final response =
          await apiService.changeProfileInformation(name, username);
      context.read<UserProvider>().saveUserInfo(name, username);
      return response;
    } catch (error) {
      _errorMessage = 'Failed to add charging: $error';
      notifyListeners();
      return null;
    }
  }
}
