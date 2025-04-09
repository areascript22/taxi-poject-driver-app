import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:driver_app/shared/providers/shared_updater.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widget personalizado
class EmergencyButton extends StatelessWidget {
  const EmergencyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    final sharedUpdater = Provider.of<SharedUpdater>(context);
    return FloatingActionButton(
      onPressed: rideRequestViewModel.loading
          ? null
          : () {
              rideRequestViewModel.sendEmergencyNotify(sharedProvider, context);
            },
      backgroundColor:
          sharedUpdater.weAreInDanger ? Colors.red[300] : Colors.green[300],
      child: rideRequestViewModel.loading
          ? const CircularProgressIndicator()
          : const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 35,
            ),
    );
  }
}
