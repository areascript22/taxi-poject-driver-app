import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/ride_history/view/widgets/custom_devider.dart';
import 'package:driver_app/features/ride_request/view/widgets/driver_avatar_queue.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

Future<int?> showDriverQueueDialog(BuildContext context) async {
  return showDialog<int?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Selecciona un puesto'),
        content: const DriverQueueDialog(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cerrar',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      );
    },
  );
}

class DriverQueueDialog extends StatelessWidget {
  const DriverQueueDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);
    DatabaseReference ref = FirebaseDatabase.instance.ref("positions");
    bool dataInQueue = false;
    // int currentPosition = 0;
    final logger = Logger();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //add button
        StreamBuilder(
          stream: ref.onValue,
          builder: (context, snapshot) {
            final data = snapshot.data?.snapshot.value;
            int order = 0;
            List<MapEntry<String, dynamic>> driverPositions = [];

            if (data == null) {
              dataInQueue = false;
            } else {
              // Parse positions data
              final Map<dynamic, dynamic> positions =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

              positions.forEach((driverId, driverData) {
                driverPositions.add(MapEntry(driverId, driverData));
              });
              driverPositions.sort((a, b) => a.key.compareTo(b.key));
              order = driverPositions.indexWhere((entry) =>
                      entry.value['driver_id'] == sharedProvider.driver!.id) +
                  1;
              logger.i('ORDER: $order');
              if (order > 0) {
                dataInQueue = true;
              }
            }
            return Column(
              children: [
                //
                Row(
                  children: [
                    //Book/Free up button
                    GestureDetector(
                      onTap: () async {
                        if (sharedProvider.availavilityState ==
                            Availability.offline) {
                          ToastMessageUtil.showToast(
                            "Cambia tu estado a encendido para reservar puestos",
                            context,
                          );
                          return;
                        }
                        if (dataInQueue) {
                          rideRequestViewModel.freeUpDriverPositionInQueue();
                        } else {
                          await rideRequestViewModel
                              .bookPositionInQueue(sharedProvider);
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Icon(dataInQueue
                                ? Icons.auto_delete
                                : Icons.add_alarm_outlined),
                          ),
                          Text(
                            dataInQueue ? "Liberar puesto" : "Reservar puesto",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    //Current Position
                    if (order != 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          order.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
                //
                const CustomDevider(),
                //////
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(driverPositions.length, (index) {
                    final taxiCode =
                        driverPositions[index].value['taxiCode'] ?? '';
                    final profilePicture =
                        driverPositions[index].value['profilePicture'] ?? '';

                    return Column(
                      children: [
                        DriverAvatarQueue(
                          imageUrl: profilePicture,
                          radius: 30,
                          color:
                              order == index + 1 ? Colors.green : Colors.blue,
                          position: (index + 1).toString(),
                        ),
                        Text(
                          taxiCode,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

//Dialod to free up position in queue
  void showReleasePositionDialog(
      BuildContext context, RideRequestViewModel rideRequestViewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 40), // Warning icon
              SizedBox(width: 10),
              Expanded(
                child: Text('Desea liberar este puesto?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
          content: const Text(
            'El conductor anterior pasará a ocupar tu puesto.',
            style: TextStyle(fontSize: 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            // No button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              child: const Text(
                'No',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ),
            // Yes button
            ElevatedButton(
              onPressed: () {
                //Free up its queue position
                rideRequestViewModel.freeUpDriverPositionInQueue();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Sí',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
