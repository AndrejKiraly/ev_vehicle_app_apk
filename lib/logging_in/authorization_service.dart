import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final String apiUrl =
      'http://10.0.2.2:3000/auth'; // Replace with your API URL
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/sign_in'),
      headers: {
        'Content-Type': 'application/json',
        "email": email,
        "password": password
      },
    );

    if (response.statusCode == 200) {
      final accessToken = response.headers['access-token']!;
      final uid = jsonDecode(response.body)["data"]['uid'];
      final client = response.headers['client'];
      final expiry = response.headers['expiry'];
      final tokenType = response.headers['token-type'];
      final authorization = response.headers['authorization'];

      await secureStorage.write(key: 'access_token', value: accessToken);
      await secureStorage.write(key: 'token_type', value: tokenType);
      await secureStorage.write(key: 'expiry', value: expiry);
      await secureStorage.write(key: 'authorization', value: authorization);
      await secureStorage.write(key: 'client', value: client);
      await secureStorage.write(key: 'uid', value: uid);

      print("response.body: ${response.body}");

      print("access token: $accessToken");
      print("token type: $tokenType");
      print("expiry: $expiry");
      print("authorization: $authorization");
      print("client: $client");
      print("uid: $uid");

      return accessToken;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> register(String email, String password,
      String passwordConfirmation, String name, String username) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        "name": name,
        "username": username,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'access_token');
    await secureStorage.delete(key: 'token_type');
    await secureStorage.delete(key: 'expiry');
    await secureStorage.delete(key: 'authorization');
    await secureStorage.delete(key: 'client');
    await secureStorage.delete(key: 'uid');
  }

  Future<bool> isLoggedIn() async {
    final accessToken = await secureStorage.read(key: "access_token");
    print(accessToken);
    return accessToken != null;
  }

  Future<bool> isAccessTokenValid() async {
    final accessToken = await secureStorage.read(key: 'access_token');

    if (accessToken == null) {
      return false;
    }

    final response = await http.get(
      Uri.parse('$apiUrl/check_token'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
