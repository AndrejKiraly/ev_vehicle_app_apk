import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../api/api_services.dart';
import '../../api/client.dart';
import '../../providers/login_provider.dart';
import '../profile_page.dart';

// class RegistrationPage extends StatefulWidget {
//   const RegistrationPage({super.key});

//   @override
//   State<RegistrationPage> createState() => _RegistrationPageState();
// }

// class _RegistrationPageState extends State<RegistrationPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final passwordConfirmationController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Register')),
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
//             TextField(
//               controller: passwordConfirmationController..text = 'password',
//               decoration: const InputDecoration(
//                 labelText: 'Password Confirmation',
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () async {
//                 final dioClient = Client();

//                 final apiService = ApiService(dioClient.init());
//                 try {
//                   await apiService.register(
//                       emailController.text,
//                       passwordController.text,
//                       passwordConfirmationController.text,);
//                 } catch (e) {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: const Text('Error'),
//                         content: Text(e.toString()),
//                         actions: [
//                           TextButton(
//                             onPressed: Navigator.of(context).pop,
//                             child: const Text('OK'),
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }

//                 const secureStorage = FlutterSecureStorage();

//                 if (await secureStorage.read(key: 'isLoggedIn') == 'true') {
//                   if (!mounted) return;
//                   context.read<LoginProvider>().login();
//                 }

//                 if (!mounted) return;
//                 Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => const ProfilePage(),
//                 ));
//               },
//               child: const Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
