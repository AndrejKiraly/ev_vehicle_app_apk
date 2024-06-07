// import 'package:flutter/material.dart';

// class ToggleButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final bool isSelected;
//   final String text;

//   const ToggleButton({
//     Key? key,
//     required this.onPressed,
//     required this.isSelected,
//     required this.text,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.all(
//             isSelected ? Colors.blue : Colors.grey[200]),
//         shape: MaterialStateProperty.all(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: isSelected ? Colors.white : Colors.black),
//       ),
//     );
//   }
// }
