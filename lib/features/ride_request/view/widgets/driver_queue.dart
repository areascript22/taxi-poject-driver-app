import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
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
    final logger = Logger();
    int queueLength = 10;
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StreamBuilder<int?>(
          stream: rideRequestViewModel.getDriverPositionInQueue(),
          builder: (context, snapshot) {
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const CircularProgressIndicator(color: Colors.blue);
            // }
            if (snapshot.hasError) {
              return const Icon(Icons.error, color: Colors.red);
            }

            final driverPosition = snapshot.data;
            logger.f("Order in queue: $driverPosition");
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(queueLength, (index) {
                int number = index + 1;

                // Check if this button represents the driver's current position
                bool isDriverPosition = driverPosition == number;

                return CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      isDriverPosition ? Colors.green : Colors.blue,
                  child: IconButton(
                    icon: Text(
                      '$number',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () async {
                      // Allow the driver to select a position only if they are not already in the queue
                      if (driverPosition == null) {
                        if (sharedProvider.availavilityState ==
                            Availability.online) {
                          await rideRequestViewModel.bookPositionInQueue();
                          if (context.mounted) {
                            Navigator.of(context).pop(number);
                          }
                        } else {
                          //We are offline
                          ToastMessageUtil.showToast(
                            "Cambia tu estado a disponible para reservar puestos.",
                            context,
                          );
                          Navigator.of(context).pop(number);
                        }
                      }
                      if (driverPosition != null && isDriverPosition) {
                        // rideRequestViewModel.freeUpDriverPositionInQueue();
                        if (context.mounted) {
                          showReleasePositionDialog(
                              context, rideRequestViewModel);
                        }
                      }
                    },
                  ),
                );
              }),
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
