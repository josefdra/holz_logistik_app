import 'package:flutter/material.dart';
import 'package:holz_logistik_backend/api/user_api.dart';

class RoleDropdown extends StatefulWidget {
  const RoleDropdown({
    required this.onChanged,
    super.key,
    this.initialValue,
  });

  final ValueChanged<Role> onChanged;
  final Role? initialValue;

  @override
  State<RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  late Role selectedRole;

  @override
  void initState() {
    super.initState();
    selectedRole = widget.initialValue ?? Role.basic;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Role>(
      value: selectedRole,
      onChanged: (Role? newValue) {
        if (newValue != null) {
          setState(() {
            selectedRole = newValue;
          });
          widget.onChanged(newValue);
        }
      },
      items: Role.values.map<DropdownMenuItem<Role>>((Role role) {
        return DropdownMenuItem<Role>(
          value: role,
          child: Text(
            role.name.capitalize(),
          ),
        );
      }).toList(),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
