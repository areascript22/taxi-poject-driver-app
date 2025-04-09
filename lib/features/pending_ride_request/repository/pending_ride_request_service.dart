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

    try {
      bool rideAssigned = await rideRef.runTransaction((currentData) {

        if (currentData == null) {
          return Transaction.success(driverId); // Assign driver
        }
        return Transaction.abort(); // Another driver is already assigned
      }).then((transactionResult) => transactionResult.committed);
      return rideAssigned;
    } catch (e) {
      logger
          .e('Error assigning driver $driverId to passenger $passengerId: $e');
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
