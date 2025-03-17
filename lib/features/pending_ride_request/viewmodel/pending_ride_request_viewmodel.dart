import 'package:driver_app/core/utils/toast_message_util.dart';
import 'package:driver_app/features/home/viewmodel/home_view_model.dart';
import 'package:driver_app/features/pending_ride_request/repository/pending_ride_request_service.dart';
import 'package:driver_app/shared/providers/shared_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class PendingRideRequestViewModel extends ChangeNotifier {
  final logger = Logger();
  bool _loading = false;

  //GETTERS
  bool get loading => _loading;
  //SETTERS
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //LOGIC
  Future<void> addDriverToRideRequest(
      String passengerId, BuildContext context) async {
    loading = true;
    final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    final sharedProvider = Provider.of<SharedProvider>(context, listen: false);
    //get driver Id
    final driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Driver is not authenticated.");
      return;
    }
    if (sharedProvider.secondPassenger != null) {
      ToastMessageUtil.showToast(
          "Ya tiene una carrera pendiente en camino.", context);
      return;
    }
    bool response = await PendingRideRequestService.addDriverToRideRequest(
        passengerId, driverId, context);

    if (response) {
      //Pending
      homeViewModel.currentPageIndex = 0;
      await PendingRideRequestService.removeRideRequest(passengerId);
    } else {
      if (context.mounted) {
        ToastMessageUtil.showToast("Peticion expirada", context);
      }
    }
    loading = false;
  }
}
