// import 'package:flutter/material.dart';
// import 'package:electric_car_app/widgets/toggleButtonCode/toggle_radionbutton.dart';

// class ToggleButtonGroup extends StatefulWidget {
//   final List<ToggleButton> children;
//   int selectedIndex;

//   ToggleButtonGroup(
//       {Key? key, required this.children, required this.selectedIndex})
//       : super(key: key);

//   @override
//   _ToggleButtonGroupState createState() => _ToggleButtonGroupState();
// }

// class _ToggleButtonGroupState extends State<ToggleButtonGroup> {
//   String? _selectedValue;

//   @override
//   void initState() {
//     super.initState();
//     ; // Set the default selected index
//     _selectedValue = "Unknown"; // Set the default selected value
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: List.generate(widget.children.length, (index) {
//         return Row(
//           // Wrap each ToggleButton and SizedBox in a separate Row
//           children: [
//             ToggleButton(
//               onPressed: () {
//                 setState(() {
//                   widget.selectedIndex = index;
//                   _selectedValue = widget.children[index].text;
//                   widget.children[index].onPressed();
//                 });
//               },
//               isSelected: widget.selectedIndex == index,
//               text: widget.children[index].text,
//             ),
//             //SizedBox(width: 10.0), // Adjust spacing as needed
//           ],
//         );
//       }),
//     );
//   }
// }
