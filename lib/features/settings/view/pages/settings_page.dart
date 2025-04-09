import 'package:driver_app/core/utils/dialog/dialog_util.dart';
import 'package:driver_app/features/settings/view/widgets/delete_account_dialog.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/repositorie/local_stogare_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:ionicons/ionicons.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withOpacity(0.2),
                blurRadius: 1,
                offset: const Offset(0, 5), // creates the soft blur effect
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Configuración',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
              maxLines: 2,
            ),
            iconTheme: const IconThemeData(color: Colors.purple),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            //About app
            // _buildButton(() {}, "Modo oscuro", subtitle: 'Desactivado'),
            //About app
            _buildButton(() {}, 'Acerca de la aplicación'),

            //Cerrar ceson
            ListTile(
              title: const Text(
                "Cerrar sesión",
              ),
              onTap: () {
                DialogUtil.messageDialog(
                  context: context,
                  onAccept: () async {
                    //  Navigator.pop(context);
                    try {
                      final service = FlutterBackgroundService();
                      await sharedProvider.goOnlineOrOffline(
                          Availability.offline,
                          sharedProvider.driverRideStatus,
                          sharedProvider);
                      service.invoke('stopService');
                      await LocalStorageService.saveIsThereDataInDB(false);
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print("ERROR SIGNING OUT: $e");
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  title: "¿Desea cerrar sesión?",
                );
              },
            ),

            //Delete accout
            ListTile(
              title: const Text(
                "Eliminar cuenta",
                style: TextStyle(fontSize: 17, color: Colors.red),
              ),
              onTap: () => dialogDeleteAccount(context: context),
            ),
          ],
        ),
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
