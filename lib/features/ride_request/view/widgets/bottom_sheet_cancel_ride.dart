import 'package:driver_app/features/home/view/widgets/custom_elevated_button.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/models/g_user.dart';
import 'package:driver_app/shared/widgets/user_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CancelRideBottomSheet extends StatelessWidget {
  const CancelRideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    final passengerInfo = rideRequestViewModel.passengerInformation;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Message: Passenger is waiting for you
          if (passengerInfo != null)
            Text(
              "${passengerInfo.name} le está esperando",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
            ),
          if (passengerInfo != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: UserAvatar(imageUrl: passengerInfo.profilePicture),
            ),
          const Text(
            "¿Esta seguro de que quiere cancelar?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          //BUTTON: No
          const SizedBox(height: 5),
          CustomElevatedButton(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Text("No")),
          //BUTTON: Confirm cancel ride
          const SizedBox(height: 5),
          CustomElevatedButton(
            color: const Color.fromARGB(221, 213, 213, 213),
            onTap: () async {
              //Cancel ride
              await rideRequestViewModel
                  .updateDriverStatus(DriverRideStatus.canceled);
              
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Sí cancelar",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showCancelRideBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const CancelRideBottomSheet(),
  );
}
