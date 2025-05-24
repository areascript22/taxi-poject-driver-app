import 'package:driver_app/features/admin/view/pages/list_canceled_trips.dart';
import 'package:driver_app/features/admin/view/pages/list_drivers.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class HomeAdminPage extends StatelessWidget {
  const HomeAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withValues(alpha: 0.2),
                blurRadius: 1,
                offset: const Offset(0, 5), // creates the soft blur effect
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Administrador',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
              maxLines: 2,
            ),
            iconTheme: const IconThemeData(color: Colors.purple),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildButton(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ListDriversPage(),
              ),
            );
          }, "Gestionar conductores",
              subtitle: "Concede acceso, quita acceso y edita los datos"),
          _buildButton(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CanceledRidesPage(),
              ),
            );
          }, "Historial de carreras canceladas",
              subtitle:
                  "Registro de todas las carreras canceladas de todos los conductores")
        ],
      ),
    );
  }

  //Build Listile
  ListTile _buildButton(void Function()? onTap, String title,
      {String? subtitle}) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(
        Ionicons.chevron_forward,
        size: 28,
        color: Colors.grey,
      ),
    );
  }
}
