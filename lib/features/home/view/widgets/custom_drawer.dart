//import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/features/admin/view/pages/home_admin.dart';
import 'package:driver_app/features/admin/view/pages/list_drivers.dart';
import 'package:driver_app/features/ride_history/view/pages/ride_history_page.dart';
import 'package:driver_app/features/settings/view/pages/settings_page.dart';
import 'package:driver_app/features/technical_support/view/pages/technical_support.dart';
import 'package:driver_app/features/termns_and_conditions/view/pages/privacy_policy.dart';
import 'package:driver_app/features/termns_and_conditions/view/pages/termns_and_conditions_page.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedProvider = Provider.of<SharedProvider>(context);
    // final homeViewModel = Provider.of<HomeViewModel>(context);
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //User data banner
                const SizedBox(height: 50),
                if (sharedProvider.driver != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserAvatar(
                              imageUrl: sharedProvider.driver!.profilePicture),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Passenger's name
                              if (sharedProvider.driver != null)
                                Text(
                                  sharedProvider.driver!.name,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Color(0xFFFDA503),
                                  ),
                                  Text("4,5")
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // IconButton(
                      //     onPressed: () {
                      //       // Navigator.push(
                      //       //     context,
                      //       //     MaterialPageRoute(
                      //       //       builder: (context) => const EditProfilePage(),
                      //       //     ));
                      //     },
                      //     icon: const Icon(Ionicons.chevron_forward))
                    ],
                  ),

                //Configuración
                //Trips history
                ListTile(
                  leading: const Icon(Ionicons.car),
                  title: const Text("Historial de viajes"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RideHistoryPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Ionicons.settings),
                  title: const Text("Configuración"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ));
                  },
                ),

                //Help for driver
                //Techinical support
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text(
                    "Soporte técnico",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TechnicalSupportContent(),
                      ),
                    );
                  },
                ),
                //Termns and conditions
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text(
                    "Términos y condiciónes",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermnsAndConditionsPage(),
                      ),
                    );
                  },
                ),

                //Politicas de privacidad
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text(
                    "Políticas de privacidad",
                    style: TextStyle(fontSize: 17),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),

                //Administrador
                if (sharedProvider.driver!.role.contains(Roles.admin) ||
                    sharedProvider.driver!.role.contains(Roles.superUser))
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text(
                      "Administrador",
                      style: TextStyle(fontSize: 17),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeAdminPage(),
                        ),
                      );
                    },
                  ),
              ],
            ),
            //Sing Out
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // ListTile(
                  //   leading: const Icon(Icons.logout_outlined),
                  //   title: const Text("Cerrar sesion"),
                  //   onTap: () {
                  //     DialogUtil.messageDialog(
                  //       context: context,
                  //       onAccept: () async {
                  //         //  Navigator.pop(context);
                  //         try {
                  //           homeViewModel.clearListeners();
                  //           await FirebaseAuth.instance.signOut();
                  //         } catch (e) {
                  //           print("ERROR SIGNING OUT: $e");
                  //         }

                  //         if (context.mounted) {
                  //           Navigator.pop(context);
                  //         }
                  //       },
                  //       onCancel: () {
                  //         Navigator.pop(context);
                  //       },
                  //       title: "¿Desea cerrar sesión?",
                  //     );
                  //   },
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('V ${sharedProvider.version}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //version
          ],
        ),
      ),
    );
  }
}
