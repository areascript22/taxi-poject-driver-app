import 'package:driver_app/shared/models/g_user.dart';
import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final String role;
  const RoleCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    String roleLabel;
    Color backgroundColor;

    switch (role) {
      case Roles.admin:
        roleLabel = "Administrador";
        backgroundColor = Colors.grey;
        break;
      case Roles.driver:
        roleLabel = "Conductor";
        backgroundColor = Colors.blue;
        break;
      case Roles.superUser:
        roleLabel = "Desarrollador";
        backgroundColor = Colors.amber;
        break;
      default:
        roleLabel = "Anonimo";
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(25), // 🔁 Bordes redondeados
      ),
      child: Center(
        child: Text(
          roleLabel,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
