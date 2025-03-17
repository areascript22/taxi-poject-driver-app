import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //header
            const SizedBox(),
            //Content
            Column(
              children: [
                //image
                Center(
                  child: Image.asset(
                    'assets/img/location.png', // Replace with your image asset
                    height: 250,
                  ),
                ),

                //Title
                const Text(
                  "Se necesita permisos para acceseder a tu ubicación",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                //Subtitle
                const SizedBox(height: 10),
                Text(
                  "Podrás verte en el mapa y los conductores pueden verte en el mapa",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),

            //Buttons
            Column(
              children: [
                //Accept Button

                CustomElevatedButton(
                  onTap: () async {
                    await homeViewModel
                        .requestPermissionsAtUserLevel(sharedProvider);
                  },
                  child: const Text("Activar los servicios"),
                ),
                const SizedBox(height: 10),
                CustomElevatedButton(
                  color: Colors.black38,
                  onTap: () {},
                  child: const Text("Omitir"),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
