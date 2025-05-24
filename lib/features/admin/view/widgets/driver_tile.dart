import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/admin/view/pages/edit_driver_data.dart';
import 'package:driver_app/features/admin/view/widgets/acccess_card.dart';
import 'package:driver_app/features/admin/view/widgets/role_card.dart';
import 'package:driver_app/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DriverTile extends StatelessWidget {
  final GUser driver;
  final int indexInArray;

  DriverTile({
    super.key,
    required this.driver,
    required this.indexInArray,
  });

  final sharedUtil = SharedUtil();

  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    final adminViewModel = Provider.of<AdminViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    return GestureDetector(
      onTap: () async {},
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Profile picture

              UserAvatar(imageUrl: driver.profilePicture),
              //Content
              const SizedBox(width: 25),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //name
                    Text(
                      '${driver.name} ${driver.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    //Taxi code
                    Text("Unidad: ${driver.vehicle?.taxiCode ?? "Sin código"}"),
                    //Access
                    Row(
                      children: [
                        Expanded(
                            flex: 5, child: AccessCard(access: driver.access)),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 3,
                            child: RoleCard(role: driver.getHighestRole()))
                      ],
                    ),
                  ],
                ),
              ),

              //Option buttons

              PopupMenuButton(
                itemBuilder: (context) => [
                  if (sharedProvider.driver!.role.contains(Roles.superUser) ||
                      sharedProvider.driver!.role.contains(Roles.admin))
                    PopupMenuItem(
                      value: "asdf",
                      onTap: () {
                        //Chech permissions
                        if (!sharedProvider.driver!.canManageUser(driver)) {
                          ToastMessageUtil.showToast(
                              "No se puede editar esta cuenta", context);
                          return;
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditDriverDataPage(
                                driver: driver,
                                indexInArray: indexInArray,
                              ),
                            ));
                      },
                      child: const Text("Editar perfil"),
                    ),
                  if (driver.access == Access.denied)
                    PopupMenuItem(
                      value: "Dar acceso",
                      onTap: () async {
                        await adminViewModel.updateAccess1(
                            driver,
                            Access.granted,
                            context,
                            indexInArray,
                            sharedProvider);
                      },
                      child: const Text("Dar acceso"),
                    ),
                  if (driver.access == Access.granted)
                    PopupMenuItem(
                      value: "Quitar acceso",
                      onTap: () async {
                        await adminViewModel.updateAccess1(
                            driver,
                            Access.denied,
                            context,
                            indexInArray,
                            sharedProvider);
                      },
                      child: const Text("Quitar acceso"),
                    ),
                  if (sharedProvider.driver!.role.contains(Roles.superUser))
                    PopupMenuItem(
                      value: "Asignar roles",
                      onTap: () async {},
                      child: const Text(
                        "Asignar roles",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  if (sharedProvider.driver!.role.contains(Roles.superUser) ||
                      sharedProvider.driver!.role.contains(Roles.admin))
                    PopupMenuItem(
                      value: "Eliminar cuenta",
                      onTap: () async {
                        // adminViewModel.deleteDriverAccount(
                        //     driver, context, sharedProvider);
                        _deleteAccountDialog(
                          context: context,
                          adminVM: adminViewModel,
                          driverToDelete: driver,
                          sharedVM: sharedProvider,
                        );
                      },
                      child: const Text(
                        "Eliminar cuenta",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //delete accout alert
  Future<void> _deleteAccountDialog({
    required BuildContext context,
    required AdminViewModel adminVM,
    required SharedProvider sharedVM,
    required GUser driverToDelete,
  }) async {
    // Show confirmation dialog
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar cuenta",
              style: TextStyle(color: Colors.red)),
          icon:
              const Icon(Icons.warning_rounded, color: Colors.orange, size: 40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Estas a punto de eliminar de manera permanente la cuenta de ${driver.name}"),
              const SizedBox(height: 8),
              const Text("Esto borrará:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("• Usuario autenticado"),
              const Text("• Todos los datos del perfil"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancelar",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) return;

    // Show processing indicator
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text("Eliminando cuenta..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: Colors.blue,
              ),
              SizedBox(height: 16),
              Text("Esto puede tardar unos segundos."),
            ],
          ),
        ),
      );
    }

    // Call Cloud Function
    if (!context.mounted) return;

    final response =
        await adminVM.deleteDriverAccount(driverToDelete, context, sharedVM);
    if (!context.mounted) return;
    // Show success
    Navigator.pop(context); // Close loading dialog
    if (!context.mounted) return;

    if (response == null) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Realizado", style: TextStyle(color: Colors.green)),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
          content: const Text(
              "Se eliminaron la cuenta y todos los datos asociados."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Alerta", style: TextStyle(color: Colors.red)),
          icon: const Icon(Icons.error, color: Colors.red, size: 60),
          content: Text(
            response,
            style: const TextStyle(fontSize: 23),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }
  }
}
