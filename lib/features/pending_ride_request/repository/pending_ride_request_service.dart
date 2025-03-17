import 'package:driver_app/shared/models/g_user.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class PendingRideRequestService {
  // Static function to write data to Firebase Realtime Database
  static Future<bool> addDriverToRideRequest(
      String passengerId, String driverId, BuildContext context) async {
    final logger = Logger();
    DatabaseReference rideRef = FirebaseDatabase.instance
        .ref()
        .child('driver_requests/$passengerId/driver');
    DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child('drivers/$driverId/status');

    try {
      // 🔹 First transaction: Check and update driver status to "reserved" if it's "pending"
      bool statusUpdated = await driverRef.runTransaction((currentData) {
        if (currentData == null) {
          return Transaction.abort(); // Do nothing if status isn't "pending"
        }
        var status = currentData as String;
        if (status != DriverRideStatus.pending) {
          return Transaction.abort();
        }
        return Transaction.success("reserved"); // Update to "reserved"
      }).then((transactionResult) => transactionResult.committed);

      if (statusUpdated) {
        logger.i('Driver $driverId status updated to reserved.');
      } else {
        logger.w('Driver $driverId status was not pending. Skipping update.');
      }

      // 🔹 Second transaction: Assign driver to the ride request
      bool rideAssigned = await rideRef.runTransaction((currentData) {
        if (currentData == null) {
          return Transaction.success(driverId); // Assign driver
        }
        return Transaction.abort(); // Another driver is already assigned
      }).then((transactionResult) => transactionResult.committed);

      if (!rideAssigned) {
        logger.w('Driver request already assigned or expired.');
        return false;
      }

      // ✅ Success: Driver is assigned, and status is updated if it was "pending"
      logger.i(
          'Driver $driverId successfully assigned to passenger $passengerId.');
      return true;
    } catch (e) {
      logger.e('Error in transaction: $e');
      return false;
    }
  }

  //Remove request
  static Future<bool> removeRideRequest(String passengerId) async {
    final logger = Logger();
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref().child('driver_requests/$passengerId');

      await ref.remove();

      logger.i('Ride request for passenger $passengerId removed successfully.');
      return true;
    } catch (e) {
      logger.e('Error removing ride request for passenger $passengerId: $e');
      return false;
    }
  }
}
