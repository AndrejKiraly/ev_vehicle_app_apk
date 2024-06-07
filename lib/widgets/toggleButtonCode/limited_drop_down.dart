import 'package:flutter/material.dart';

class LimitedDropdown extends StatefulWidget {
  final int itemCount;
  final int initialDisplayCount;
  final String Function(int) itemBuilder;
  final ValueChanged<int>? onSelected;
  final int selectedValue;

  const LimitedDropdown({
    Key? key,
    required this.itemCount,
    required this.initialDisplayCount,
    required this.itemBuilder,
    required this.onSelected,
    required this.selectedValue,
  }) : super(key: key);

  @override
  _LimitedDropdownState createState() => _LimitedDropdownState();
}

class _LimitedDropdownState extends State<LimitedDropdown> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    int selectedValue = widget.selectedValue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        // Hide default underline
        child: DropdownButton<int>(
          value: selectedValue,
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue!;
            });
            widget.onSelected?.call(newValue!);
          },
          icon: const Icon(Icons.arrow_drop_down), // Customizable dropdown icon
          iconSize: 32, // Increased icon size
          style: TextStyle(
            // Style for the selected item text
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
          elevation: 4, // Elevated dropdown menu
          items: List.generate(
            widget.itemCount,
            (index) => DropdownMenuItem<int>(
              value: index,
              child: Text(
                widget.itemBuilder(index),
                style: TextStyle(fontSize: 14), // Style for dropdown items
              ),
            ),
          ).toList(),
          selectedItemBuilder: (context) => List.generate(
            widget.itemCount,
            (index) => Padding(
              // Add padding to selected item for better spacing
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.itemBuilder(index)),
            ),
          ).take(widget.initialDisplayCount).toList(),
          menuMaxHeight: 300,
        ),
      ),
    );
  }
}
