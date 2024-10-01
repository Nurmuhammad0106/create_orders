import 'package:flutter/material.dart';

class DropdownMenu {
  static List<DropdownMenuItem<int>> buildDropdownItems(List<Map<String, dynamic>> items) {
    return items.map((item) {
      return DropdownMenuItem<int>(
        value: item['value'],
        child: Center(
          child: Text(
            item['label'],
          ),
        ),
      );
    }).toList();
  }
}

class CustomDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int? value;
  final Function(int?) onChanged;

  CustomDropdown({
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      onChanged: onChanged,
      items: DropdownMenu.buildDropdownItems(items),
      decoration: InputDecoration(
        labelText: 'Манзилингиз',
        border: InputBorder.none,
        prefixIcon: Icon(Icons.location_on_outlined),
      ),
    );
  }
}