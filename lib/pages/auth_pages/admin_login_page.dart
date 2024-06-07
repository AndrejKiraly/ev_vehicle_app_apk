import 'package:ev_vehicle_app/providers/admin_login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../api/api_services.dart';
import '../../api/client.dart';
import '../../providers/login_provider.dart';
import '../profile_page.dart';

// class AdminLoginPage extends StatefulWidget {
//   const AdminLoginPage({super.key});

//   @override
//   State<AdminLoginPage> createState() => _AdminLoginPageState();
// }

// class _AdminLoginPageState extends State<AdminLoginPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: emailController..text = 'test@gmail.com',
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             TextField(
//               controller: passwordController..text = 'password',
//               decoration: const InputDecoration(
//                 labelText: 'Password',
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () async {
//                 final dioClient = Client();

//                 final apiService = ApiService(dioClient.init());

//                 await apiService.adminLogin(
//                   emailController.text,
//                   passwordController.text,
//                 );

//                 const secureStorage = FlutterSecureStorage();

//                 if (await secureStorage.read(key: 'isLoggedIn') == 'true') {
//                   if (!mounted) return;
//                   context.read<AdminLoginProvider>().isLoggedIn;
//                 }

//                 if (!mounted) return;
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => const ProfilePage(),
//                 ));
//               },
//               child: const Text('Login Admin'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
