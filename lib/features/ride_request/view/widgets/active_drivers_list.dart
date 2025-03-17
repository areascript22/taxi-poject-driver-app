import 'package:driver_app/shared/models/realtime_database/driver_model.dart';
import 'package:driver_app/shared/utils/shared_util.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

//Show the Active Driver list
void showDriversDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ActiveDriversList(),
      );
    },
  );
}

//Show vertical menu
void showOptionsDialog(BuildContext context, String phone) {
  SharedUtil sharedUtil = SharedUtil();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // _buildOptionItem(context, "Ver perfil", Icons.person, () {
            //   Navigator.pop(context);
            //   // Add action here
            // }),
            // const Divider(),
            _buildOptionItem(context, "Contactar", Ionicons.chatbubble_ellipses,
                () {
              sharedUtil.sendSMS(phone, '');
              // Add action here
            }),
            //  const  Divider(),
            //   _buildOptionItem(context, "Remover", Icons.delete, () {
            //     Navigator.pop(context);
            //     // Add action here
            //   }),
          ],
        ),
      );
    },
  );
}

class ActiveDriversList extends StatelessWidget {
  ActiveDriversList({super.key});
  final DatabaseReference _driversRef =
      FirebaseDatabase.instance.ref().child('drivers');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Conductore activos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _driversRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Colors.blue,
                  ));
                }
                if (!snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return const Center(
                      child: Text("Aun no hay conductores activos"));
                }

                final data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final driversList = data.entries.map((entry) {
                  final driverData = entry.value as Map<dynamic, dynamic>;
                  // return {
                  //   "id": entry.key,
                  //   "name": driverData["name"] ?? "Unknown",
                  //   "status": driverData["status"] ?? "available",
                  // };
                  return DriverModel.fromMap(
                      driverData['information'], entry.key);
                }).toList();

                return ListView.builder(
                  itemCount: driversList.length,
                  itemBuilder: (context, index) {
                    return _buildDriverTile(driversList[index], context);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

//Bild Tile
  Widget _buildDriverTile(DriverModel driver, BuildContext context) {
    return Card(
      elevation: 5,
      // margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Driver Avatar
            Column(
              children: [
                UserAvatar(
                  imageUrl: driver.profilePicture,
                  radius: 24,
                ),
                Text(
                  driver.name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            //Rest of content
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Car model
                  Text(
                    driver.vehicleModel,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  //Car registration number
                  Text(
                    driver.carRegistrationNumber,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            //Options Button
            IconButton(
              onPressed: () {
                showOptionsDialog(context, driver.phone);
              },
              icon: const Icon(
                Ionicons.ellipsis_vertical_outline,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Menu options
Widget _buildOptionItem(
    BuildContext context, String title, IconData icon, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(title),
    onTap: onTap,
  );
}
