import 'package:driver_app/shared/models/g_user.dart';
import 'package:flutter/material.dart';

class AccessCard extends StatelessWidget {
  final String access;
  const AccessCard({super.key, required this.access});

  @override
  Widget build(BuildContext context) {
    String accessLabel;
    Color backgroundColor;

    switch (access) {
      case Access.granted:
        accessLabel = "Acceso concedido";
        backgroundColor = Colors.green;
        break;
      case Access.denied:
        accessLabel = "Sin acceso";
        backgroundColor = Colors.red;
        break;
      default:
        accessLabel = "Estado desconocido";
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
          accessLabel,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
