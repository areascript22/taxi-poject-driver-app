import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/shared/models/passenger_request.dart';
import 'package:driver_app/shared/models/ride_history_model.dart';
import 'package:driver_app/shared/utils/configuration_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';

class RideRequestService {
  //To book position, driver is added to queue
  static Future<bool> bookDriverPositionInQueue({
    required String idUsuario,
  }) async {
    final Logger logger = Logger();
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref('positions');

    // Prepare the data to write
    final Map<String, dynamic> data = {
      'timestamp': ServerValue.timestamp, // Add Firebase server timestamp
      'driver_id': idUsuario,
      // 'profilePicture':,
    };

    try {
      // Use push() to create a new unique key under the 'positions' node
      final newDriverRef = dbRef.push();
      await newDriverRef.set(data);

      logger.i('Data successfully booked for $idUsuario!');
      return true;
    } catch (e) {
      logger.e('Failed to book driver position: $e');
      return false;
    }
  }

//DELETE
  static Future<bool> bookDriverPositionInQueueTest({
    required String idUsuario,
  }) async {
    final Logger logger = Logger();
    final DatabaseReference dbRef = FirebaseDatabase.instance.ref('positions');

    // Prepare the data to write
    final Map<String, dynamic> data = {
      'timestamp': ServerValue.timestamp, // Add Firebase server timestamp
      'driver_id': idUsuario,
      // 'profilePicture':,
    };

    try {
      // Use push() to create a new unique key under the 'positions' node
      final newDriverRef = dbRef.push();
      await newDriverRef.set(data);

      logger.i('Data successfully booked for $idUsuario!');
      return true;
    } catch (e) {
      logger.e('Failed to book driver position: $e');
      return false;
    }
  }

  // Static function to remove the 'passenger' node
  static Future<void> removePassengerInfo() async {
    final logger = Logger();
    //get driver id
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      logger.e("Driver is not authenticated..");
      return;
    }

    try {
      // Reference to the 'drivers/driverId/passenger' node
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("drivers/$uid/passenger");

      // Remove the 'passenger' node
      await ref.remove();
      logger.i("Passenger node removed successfully.");
    } catch (e) {
      // Handle any errors
      logger.e("Error removing passenger node: $e");
    }
  }

  //Deleto second driver
  // Static function to remove data from Firebase Realtime Database
  static Future<void> removesecondPassengerInfo() async {
    final logger = Logger();
    //get driver id
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      logger.e("Driver is not authenticated..");
      return;
    }
    try {
      // Reference to the 'drivers/driverId/passenger' node
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("drivers/$uid/secondPassenger");

      // Remove the 'passenger' node
      await ref.remove();
      logger.i("Passenger node removed successfully.");
    } catch (e) {
      // Handle any errors
      logger.e("Error removing passenger node: $e");
    }
  }

  //Covert second driver to first driver
  static Future<void> addPassengerDataToRequest(
      PassengerRequest passenger) async {
    final logger = Logger();
    String? driverId = FirebaseAuth.instance.currentUser?.uid;
    if (driverId == null) {
      logger.e("Driver is not authenticated..");
      return;
    }
    try {
      final DatabaseReference mainNodeRef =
          FirebaseDatabase.instance.ref('drivers/$driverId/passenger');
      await mainNodeRef.set(passenger.toMap());
      logger.i("Second passenger turned into Passenger: ${passenger.toMap()}");
    } catch (e) {
      logger.e("Error trying to write data: $e");
    }
  }

  // Upload the ride data to Firestore
  static Future<void> uploadRideHistory(RideHistoryModel rideHistory) async {
    final logger = Logger();
    try {
      final rideCollection =
          FirebaseFirestore.instance.collection('ride_history');
      final rideDoc = await rideCollection.add(rideHistory.toMap());
      logger.i("Ride uploaded successfully with ID: ${rideDoc.id}");
    } catch (e) {
      logger.e("Error uploading ride history: $e");
    }
  }

  //Update "status" field under 'driver/driverId' node
  static Future<bool> updateDriverStatus(String driverId, String status) async {
    final Logger logger = Logger();
    try {
      final DatabaseReference databaseRef =
          FirebaseDatabase.instance.ref('drivers/$driverId');
      // Update the status
      await databaseRef.update({
        'status': status,
        //  'status_availability': '${status}_$availability',
      });
      logger.i(
          'Successfully updated driver status to :$status for driverId: $driverId');
      return true;
    } catch (e) {
      logger.e('Failed to update driver status: $e');
      return false;
    }
  }

  //Update status_availability status
  static Future<bool> updateDriverAvailability(
    String driverId,
    String driverRideStatus,
    String availability,
  ) async {
    final logger = Logger();
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    try {
      await database.child('drivers/$driverId').update({
        'status_availability': "${driverRideStatus}_$availability",
      }).timeout(ConfigF.timeOut);
      logger.i("Driver availability updated successfully.");
      return true;
    } catch (e) {
      logger.e("Error updating availability: $e");
      return false;
    }
  }

  //NOtify all drivers
  static Future<void> notifyAllDrivers(String driverId) async {
    final logger = Logger();
    final DatabaseReference database = FirebaseDatabase.instance.ref();
    try {
      await database
          .child('assignedRequests/$driverId')
          .update({'timestamp': ServerValue.timestamp});
      await FirebaseDatabase.instance
          .ref('assignedRequests/$driverId')
          .remove();
      logger.i("Driver availability updated successfully.");
    } catch (e) {
      logger.e("Error updating availability: $e");
    }
  }
}
