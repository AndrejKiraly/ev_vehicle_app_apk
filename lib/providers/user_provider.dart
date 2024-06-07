import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {
  late User _user;

  bool _isLoading = true;

  bool passwordChanged = false;
  bool get isPasswordChanged => passwordChanged;

  bool get isLoading => _isLoading;

  User get user => _user;

  Future<void> fetchUserInfo() async {
    const storage = FlutterSecureStorage();
    final String? email = await storage.read(key: 'email');
    final String? username = await storage.read(key: 'username');
    final String? isAdmin = await storage.read(key: 'isAdmin');
    final String? name = await storage.read(key: 'name');
    _user = User(
      email: email,
      username: username,
      admin: isAdmin == 'true' ? true : false,
      name: name,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserInfo(String name, String username) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'name', value: name);
    await storage.write(key: 'username', value: username);
  }
}
