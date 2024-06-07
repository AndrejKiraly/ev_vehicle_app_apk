// import 'package:flares/common/utility.dart';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//const String baseUrl = 'http://10.0.2.2:3000';
const String baseUrl = 'https://electric-vehicle-app.onrender.com';

class Client {
  Dio init() {
    final dio = Dio()
      ..interceptors.add(ApiInterceptors())
      ..options.baseUrl = baseUrl;
    return dio;
  }
}

class ApiInterceptors extends Interceptor {
  @override
  Future<dynamic> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    const secureStorage = FlutterSecureStorage();

    final accessToken = await secureStorage.read(key: 'access_token');
    final tokenType = await secureStorage.read(key: 'token_type');
    final expiry = await secureStorage.read(key: 'expiry');
    final authorization = await secureStorage.read(key: 'authorization');
    final client = await secureStorage.read(key: 'client');
    final uid = await secureStorage.read(key: 'uid');

    options.headers['access_token'] = accessToken;
    options.headers['token_type'] = tokenType;
    options.headers['expiry'] = expiry;
    options.headers['authorization'] = authorization;
    options.headers['client'] = client;
    options.headers['uid'] = uid;

    return super.onRequest(options, handler);
  }

  @override
  Future<dynamic> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    return super.onError(err, handler);
  }

  @override
  Future<dynamic> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401) {
      // final dio = Dio();
      // final apiService = ApiService(dio);
      // await apiService.refreshToken();
    }
//     const secureStorage = FlutterSecureStorage();

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       await secureStorage.write(key: key, value: value);
//       await secureStorage.write(key: 'token_type', value: value);
//       await secureStorage.write(key: 'expiry', value: value);
//       await secureStorage.write(key: 'authorization', value: value);
//       await secureStorage.write(key: 'client', value: value);
//       await secureStorage.write(key: 'uid', value: value);
//     } else if (response.statusCode == 201) {
//       throw AppError(
//           message: jsonDecode(response.data)['data'],
//           code: response.statusCode!);
//     } else if (response.statusCode == 400) {
//       throw AppError(
//           message: jsonDecode(response.data)['message'],
//           code: response.statusCode!);
//     } else if (response.statusCode == 401) {
//       throw AppError(
//           message: jsonDecode(response.data)['message'],
//           code: response.statusCode!);
//     } else if (response.statusCode == 422) {
//       throw AppError(
//           message: jsonDecode(response.data)['message'],
//           code: response.statusCode!);
//     } else {
//       if (response.data.isEmpty) {
//         return Future.value();
//       }

    return super.onResponse(response, handler);
  }
}
// }

// class AppError {
//   String message;
//   int code;
//   AppError({
//     required this.message,
//     this.code = 400,
//   });
// }
