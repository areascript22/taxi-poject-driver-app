import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ByCoordinatesInfo extends StatelessWidget {
  const ByCoordinatesInfo({
    super.key,
    required this.rideRequestViewModel,
  });

  final RideRequestViewModel rideRequestViewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Ionicons.location,
              color: Colors.green,
            ),
            Expanded(
              child: Text(
                rideRequestViewModel.passengerInformation!.pickUpLocation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Row(
        //   children: [
        //     const Icon(
        //       Ionicons.location,
        //       color: Colors.blue,
        //     ),
        //     Expanded(
        //       child: Text(
        //         rideRequestViewModel.passengerInformation!.dropOffLocation,
        //         maxLines: 1,
        //         overflow: TextOverflow.ellipsis,
        //       ),
        //     ),
        //   ],
        // ),
      ],
    );
  }
}
